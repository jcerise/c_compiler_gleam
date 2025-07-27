import argv
import gleam/io
import glint
import shiny_cc/internal

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

fn run_lexer() -> Result(Nil, String) {
  Ok(io.println("Running lexer..."))
}

fn run_parser() -> Result(Nil, String) {
  Ok(io.println("Running parser..."))
}

fn run_codegen() -> Result(Nil, String) {
  Ok(io.println("Running codegen..."))
}

fn set_compiler_operations() -> internal.CompilerOperations {
  internal.CompilerOperations(
    run_lexer: run_lexer,
    run_parser: run_parser,
    run_codegen: run_codegen,
    create_output_file: internal.create_output_file,
  )
}

pub fn driver() -> glint.Command(Result(Nil, String)) {
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

  let _ =
    internal.compile_with_options(
      input_path,
      lexer,
      parse,
      codegen,
      set_compiler_operations(),
    )
  Ok(io.println("Completed"))
}

pub fn main() {
  glint.new()
  |> glint.with_name("shiny_cc")
  |> glint.pretty_help(glint.default_pretty_help())
  |> glint.add(at: [], do: driver())
  |> glint.run(argv.load().arguments)
}
