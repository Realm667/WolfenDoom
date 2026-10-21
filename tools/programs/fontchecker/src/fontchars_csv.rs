use std::{error::Error, fmt::Write};
use indexmap::IndexSet;
use csv::Writer;
use crate::Font;
use crate::font::CharOnSheet;

fn char_codepoint(ch: char) -> Result<String, std::fmt::Error> {
    let mut sf = String::new();
    let cn = ch as u32;
    write!(sf, "{ch} - {cn:04X}")?;
    Ok::<String, std::fmt::Error>(sf)
}

fn char_status(font: &Font, ch: char) -> Result<String, std::fmt::Error> {
    let status = font.char_available(ch);
    let mut sf = String::with_capacity(32);
    let cn = ch as u32;
    if status {
        write!(sf, "✓")?;
    } else {
        match font {
            Font::Variable { .. } => write!(sf, "U -> {cn:04X}.png")?,
            Font::Monospace { .. } => {
                match font.sheet_for(ch) {
                    Some(on_sheet) => {
                        let CharOnSheet {ch: _ch, cell_x, cell_y, x, y, sheet} = on_sheet;
                        write!(sf, "U -> {sheet:04X}.png@{cell_x},{cell_y} ({x},{y})")?
                    },
                    None => {
                        write!(sf, "U -> {cn:04X}.png")?
                    }
                }
            }
        };
    }
    Ok(sf)
}

pub fn char_table(needed: &IndexSet<char>, fonts: &[(String, Font)]) -> Result<Vec<u8>, Box<dyn Error>> {
    let csv_text = Vec::<u8>::new();
    let mut wtr = Writer::from_writer(csv_text);
    let comments = ["✓ = Finished", "U = Unfinished", "Finished chars may need offsets", "Updated by GitHub Actions"].map(String::from);
    let mut font_names = vec![String::from("Char & codepoint"), String::from("Comments")];
    let fonts: Vec<_> = fonts.iter().map(|(name, font)| {
        font_names.push(name.clone());
        font
    }).collect();
    let font_names = font_names;
    wtr.write_record(font_names)?;
    needed.iter().zip(
        comments.into_iter()
            .map(Option::from)
            .chain(std::iter::repeat(None))
    ).try_for_each(|(&ch, comment)| {
        let mut record = vec![char_codepoint(ch)?, comment.unwrap_or_else(|| String::new())];
        let font_stati: Result<Vec<String>, std::fmt::Error> = fonts.iter().copied().map(|font| { char_status(font, ch) }).collect();
        let font_stati = font_stati?;
        record.extend(font_stati);
        let record = record;
        wtr.write_record(record)?;
        Ok::<(), Box::<dyn Error>>(())
    })?;
    wtr.flush()?;
    wtr.into_inner().map_err(Box::from)
}