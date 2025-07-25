import argv
import filepath
import gleam/io
import glint
import simplifile

fn lex_flag() -> glint.Flag(Bool) {
  glint.bool_flag("lexer")
  |> glint.flag_default(False)
  |> glint.flag_help("Run the lexer, but stop before parsing")
}

fn parse_flag() -> glint.Flag(Bool) {
  glint.bool_flag("parse")
  |> glint.flag_default(False)
  |> glint.flag_help(
    "Run the lexer and parser, but stop before assembly generation",
  )
}

fn codegen_flag() -> glint.Flag(Bool) {
  glint.bool_flag("codegen")
  |> glint.flag_default(False)
  |> glint.flag_help(
    "Run the lexer and parser, and assembly generation, but stop before code emission",
  )
}

fn create_output_file(path: String) {
  let dir = filepath.directory_name(path)
  let base_name = filepath.base_name(path)
  let name_without_ext = filepath.strip_extension(base_name)

  let new_path = filepath.join(dir, name_without_ext)

  io.println("Executable written to " <> new_path)
  simplifile.copy_file(path, new_path)
}

pub fn driver() -> glint.Command(Result(Nil, simplifile.FileError)) {
  use <- glint.command_help("Shiny CC 'C' compiler")
  use <- glint.unnamed_args(glint.MinArgs(1))
  use lexer <- glint.flag(lex_flag())
  use parse <- glint.flag(parse_flag())
  use codegen <- glint.flag(codegen_flag())
  use _, args, flags <- glint.command()

  let assert [input_path, ..] = args
  let assert Ok(lexer) = lexer(flags)
  let assert Ok(parse) = parse(flags)
  let assert Ok(codegen) = codegen(flags)
  io.println("Shiny CC Compiler")

  case lexer, parse, codegen {
    True, _, _ -> "Running the lexer"
    False, True, _ -> "Running the lexer and parser"
    False, False, True -> "Running the lexer, parser, and codegen"
    False, False, False -> "Compiling..."
  }
  |> io.println

  create_output_file(input_path)
}

pub fn main() {
  glint.new()
  |> glint.with_name("shiny_cc")
  |> glint.pretty_help(glint.default_pretty_help())
  |> glint.add(at: [], do: driver())
  |> glint.run(argv.load().arguments)
}
