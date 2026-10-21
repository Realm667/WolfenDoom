use std::{collections::{HashMap, HashSet}, error::Error, path::{Path, PathBuf}, fs};
use image::{ImageReader, GenericImageView, Pixel};

#[derive(Debug, Clone, Default)]
struct FontCharImageInfo {
    path: PathBuf,
    char_cells: (u32, u32),
    chars_contained: HashSet<char>,
}

impl FontCharImageInfo {
    pub fn len(&self) -> u32 {
        self.char_cells.0 * self.char_cells.1
    }
}

#[derive(Debug, Clone, Default)]
pub struct FontChars {
    // Key is u32 to account for font character sheets.
    images: HashMap<u32, FontCharImageInfo>,
}

#[derive(Debug, Clone)]
pub enum Font {
    Variable { chars: FontChars },
    Monospace {
        sheets: FontChars,
        cell_width: u32,
        cell_height: u32
    },
}

#[derive(Debug, Clone, Copy)]
pub struct CharOnSheet {
    pub ch: char,
    pub cell_x: u32,
    pub cell_y: u32,
    pub x: u32,
    pub y: u32,
    pub sheet: u32,
}

impl Font {
    pub fn import<P: AsRef<Path>>(path: P) -> Result<Self, Box<dyn Error>> {
        let path = path.as_ref();
        let font_dir = path.read_dir()?;
        let mut chars = FontChars::default();
        let mut monospace_info = None;
        chars.images = font_dir.filter_map(Result::ok).filter_map(|fentry| {
            let fpath = path.join(fentry.file_name());
            let ftype = fentry.file_type().inspect_err(|e| {eprintln!("{e:?}");}).ok()?;
            if !ftype.is_dir() && fentry.file_name() == "font.inf" {
                // See if font.inf has "CellSize" in it. If it does, it's a monospace font
                let Ok(font_info) = fs::read_to_string(fpath) else {
                    return None;
                };
                monospace_info = crate::font_inf::get_cell_size(&font_info);
                None
            } else if !ftype.is_dir() {
                // It's probably an image
                let codepoint = fpath.file_stem().unwrap(); // SAFETY: fpath comes from the entry
                let Some(codepoint) = codepoint.to_str() else {
                    return None;
                };
                let Ok(codepoint) = u32::from_str_radix(&codepoint, 16) else {
                    eprintln!("codepoint was {codepoint}");
                    return None;
                };
                Some((codepoint, FontCharImageInfo { path: fpath, char_cells: (1, 1), chars_contained: HashSet::default() }))
            } else {
                None
            }
        }).collect();
        match monospace_info {
            Some(xy) => {
                // And now to scan the sheets for characters
                let (cell_width, cell_height) = xy;
                {
                    // First, load and decode the image
                    chars.images.iter_mut().filter_map(|(charcode, image_info)| {
                        let imudj = ImageReader::open(&image_info.path)
                            .inspect_err(|e| {eprintln!("{e:?}");}).ok()?;
                        let image = imudj.decode()
                            .inspect_err(|e| eprintln!("{e:?}")).ok()?;
                        Some((charcode, image_info, image))
                    }).for_each(|(charcode, image_info, image)| {
                        // Calculate the number of cells in the sheet
                        let xcells = image.width() / cell_width as u32;
                        let ycells = image.height() / cell_height as u32;
                        image_info.char_cells = (xcells, ycells);
                        // Scan each cell for opaque pixels, and if there are,
                        // add the corresponding character to the set of
                        // characters in the sheet.
                        for x in 0..xcells {
                            let xx = x * cell_width;
                            for y in 0..ycells {
                                let yy = y * cell_height;
                                let Some(charcode) = char::from_u32(charcode + (y * xcells + x)) else {
                                    continue;
                                };
                                let view = image.view(xx, yy, cell_width, cell_height);
                                if view.pixels().any(|(_x, _y, px)| {
                                    px.alpha() > 0
                                }) {
                                    // There's a pixel with an alpha > 0, that
                                    // must mean that it's an actual character!
                                    image_info.chars_contained.insert(charcode);
                                }
                            }
                        }
                    });
                }
                Ok(Font::Monospace { sheets: chars, cell_width, cell_height })
            },
            None => {
                Ok(Font::Variable { chars })
            }
        }
    }
    pub fn sheet_for(&self, ch: char) -> Option<CharOnSheet> {
        match self {
            Font::Variable { .. } => None,
            Font::Monospace { sheets, cell_width, cell_height } => {
                let codepoint = ch as u32;
                // Each image (font sheet in case of monospace characters) must
                // be checked for whether it contains the character.
                //
                // Get all image filenames, and sort them.
                let mut image_start_at: Vec<u32> = sheets.images
                    .keys().copied().collect();
                // All HashMap keys are unique.
                image_start_at.sort_unstable();
                let image_start_at = image_start_at;
                // Find first image before the given codepoint, using a reverse
                // iterator to model my requirements more accurately.
                image_start_at.into_iter().rev()
                    .find(|&image| image < codepoint)
                    .and_then(|sheet| {
                        // SAFETY: 'sheet' was taken from the keys of 'sheets'
                        let sheet_info = sheets.images.get(&sheet).unwrap();
                        let index_on_sheet = codepoint - sheet;
                        (
                            index_on_sheet
                            <
                            sheet_info.len()
                        ).then(|| {
                            let cell_y = index_on_sheet / sheet_info.char_cells.0;
                            let cell_x = index_on_sheet % sheet_info.char_cells.0;
                            let x = cell_x * cell_width;
                            let y = cell_y * cell_height;
                            CharOnSheet { ch, cell_x, cell_y, x, y, sheet }
                        })
                    })
            }
        }
    }
    pub fn char_available(&self, codepoint: char) -> bool {
        use Font::*;
        let codepoint = codepoint as u32;
        match self {
            Variable { chars } => {
                // For a variable width/height font where every character is a
                // separate image, this is easy: just check whether or not the
                // set of images contains the codepoint.
                chars.images.contains_key(&codepoint)
            },
            Monospace { sheets, .. } => {
                // Each image (font sheet in case of monospace characters) must
                // be checked for whether it contains the character.
                //
                // Get all image filenames, and sort them.
                let mut image_start_at: Vec<u32> = sheets.images
                    .keys().copied().collect();
                // All HashMap keys are unique.
                image_start_at.sort_unstable();
                let image_start_at = image_start_at;
                // Find first image before the given codepoint, using a reverse
                // iterator to model my requirements more accurately.
                image_start_at.into_iter().rev()
                    .find(|&image| image <= codepoint)
                    .map(|image| {
                        // SAFETY: 'codepoint' was a char to begin with
                        let codepoint = unsafe { char::from_u32_unchecked(codepoint) };
                        sheets.images
                        .get(&image)
                        .unwrap() // SAFETY: image was calculated from existing entries
                        .chars_contained
                        .contains(&codepoint)
                    }).unwrap_or(false)
            },
        }
    }
}