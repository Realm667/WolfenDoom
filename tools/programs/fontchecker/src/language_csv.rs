use std::path::Path;
use indexmap::IndexSet;

pub fn chars_used<P: AsRef<Path>>(path: P) -> Result<IndexSet<char>, std::io::Error> {
    let mut reader = csv::Reader::from_path(path)?;
    let mut ignore_columns = [0usize, 0usize]; // Entry ID
    let mut first_row = false;
    let mut chars_required = IndexSet::<char>::default();
    for result in reader.records() {
        let record = result?;
        if !first_row {
            record.iter().enumerate().for_each(|(index, strew)| {
                match strew {
                    "Identifier" => { ignore_columns[0] = index; },
                    "Remarks" => { ignore_columns[1] = index; },
                    _ => (),
                }
            });
            first_row = true;
        } else {
            record.iter().enumerate().filter_map(|(index, straw)| {
                (!ignore_columns.contains(&index)).then_some(straw)
            }).for_each(|straw| {
                straw.chars().filter(|kar| !kar.is_whitespace()).for_each(|kar| {
                    chars_required.insert(kar);
                });
            });
        }
    }
    Ok(chars_required)
}