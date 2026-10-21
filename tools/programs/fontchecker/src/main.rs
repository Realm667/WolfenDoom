use std::{env, error::Error, path::PathBuf};
use fontchecker::Font;

fn main() -> Result<(), Box<dyn Error>> {
    let dev_path = PathBuf::from(env::args_os().nth(1)
        .expect("Please give me a path to a UZDoom mod development folder."));
    let language_path = dev_path.join("language.csv");
    let fonts_path = dev_path.join("fonts");
    let mut fonts: Vec<_> = fonts_path.read_dir()?.filter_map(|entry| {
        entry.map(|en| {
            en.file_type().map(|ft| {
                if ft.is_dir() {
                    Some(en.path())
                } else {
                    None
                }
            }).ok().flatten()
        }).ok().flatten()
    }).filter_map(|path| {
        let name = path.file_name().unwrap().to_string_lossy().into_owned();
        Font::import(&path).inspect_err(|e| eprintln!("{e:?}")).ok().map(|fo| (name, fo))
    }).collect();
    fonts.sort_unstable_by(|(namea, _fonta), (nameb, _fontb)| namea.cmp(nameb));
    let fonts = fonts;
    let mut chars_required = fontchecker::chars_used(language_path)?;
    chars_required.sort_unstable();
    let chars_required = chars_required;
    let fontchars_csv = fontchecker::char_table(&chars_required, &fonts)?;
    let fontchars_csv = String::from_utf8(fontchars_csv)?;
    println!("{fontchars_csv}");
    Ok(())
}
