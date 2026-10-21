use nom::{IResult, Parser, Finish, bytes::complete::tag_no_case, character::complete::{char, digit1, multispace0, multispace1}, combinator::map_res};

pub(crate) fn get_cell_size(font_info: &str) -> Option<(u32, u32)> {
    match font_info.rfind("CellSize") {
        Some(pos) => {
            // I know it's there, so make sure it isn't commented.
            let line_break = font_info[0..pos].rfind(|c| c == '\n' || c == '\r');
            let _line_pos = match line_break {
                Some(line_break) => {
                    if font_info[line_break..pos].contains("//") {
                        // It's within a line comment
                        return None;
                    } else {
                        line_break
                    }
                },
                None => 0usize
            };
            let comment_open = font_info[0..pos].rfind("/*");
            let comment_close = font_info[0..pos].rfind("*/");
            if let (Some(open_pos), Some(close_pos)) = (comment_open, comment_close) {
                if close_pos < open_pos {
                    // It's within a long comment
                    return None;
                }
            } else if comment_open.is_some() && comment_close.is_none() {
                // It's within a long comment
                return None;
            }
            match cell_size(&font_info[pos..]).finish() {
                Ok((_, xy)) => {
                    return Some(xy);
                },
                Err(e) => {
                    eprintln!("{e:?}");
                    return None;
                }
            }
        },
        None => None
    }
}

fn cell_size(input: &str) -> IResult<&str, (u32, u32)> {
    let (input, _) = (tag_no_case("CellSize"), multispace1).parse(input)?;
    let (input, width) = map_res(digit1, |s: &str| s.parse::<u32>()).parse(input)?;
    let (input, _) = (multispace0, char(','), multispace0).parse(input)?;
    let (input, height) = map_res(digit1, |s: &str| s.parse::<u32>()).parse(input)?;
    Ok((input, (width, height)))
}
