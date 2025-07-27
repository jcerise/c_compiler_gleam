import filepath
import gleam/io
import gleam/result
import simplifile

pub type CompilerOperations {
  CompilerOperations(
    run_lexer: fn() -> Result(String, String),
    run_parser: fn() -> Result(String, String),
    run_codegen: fn() -> Result(String, String),
    create_output_file: fn(String) -> Result(String, String),
  )
}

pub fn create_output_file(path: String) -> Result(String, String) {
  let dir = filepath.directory_name(path)
  let base_name = filepath.base_name(path)
  let name_without_ext = filepath.strip_extension(base_name)

  let new_path = filepath.join(dir, name_without_ext)

  let _ = simplifile.copy_file(path, new_path)
  Ok("Executable written to " <> new_path)
}

pub fn compile_with_options(
  input_path: String,
  lexer: Bool,
  parse: Bool,
  codegen: Bool,
  ops: CompilerOperations,
) {
  case lexer, parse, codegen {
    True, _, _ -> ops.run_lexer()
    False, True, _ -> {
      use _ <- result.try(ops.run_lexer())
      ops.run_parser()
    }
    False, False, True -> {
      use _ <- result.try(ops.run_lexer())
      use _ <- result.try(ops.run_parser())
      ops.run_codegen()
    }
    False, False, False -> {
      io.println("Compiling...")
      ops.create_output_file(input_path)
    }
  }
}
