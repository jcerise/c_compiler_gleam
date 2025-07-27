import gleeunit
import gleeunit/should
import shiny_cc/internal

pub fn mock_compiler_operations() -> internal.CompilerOperations {
  internal.CompilerOperations(
    run_lexer: fn() { Ok("Lexer ran") },
    run_parser: fn() { Ok("Parser ran") },
    run_codegen: fn() { Ok("Codegen ran") },
    create_output_file: fn(_path) { Ok("Output created") },
  )
}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn driver_lexer_only_test() {
  let ops = mock_compiler_operations()

  internal.compile_with_options("test.c", True, False, False, ops)
  |> should.be_ok
  |> should.equal("Lexer ran")
}

pub fn driver_parser_lexer_only_test() {
  let ops = mock_compiler_operations()

  internal.compile_with_options("test.c", False, True, False, ops)
  |> should.be_ok
  |> should.equal("Parser ran")
}

pub fn driver_codegen_parser_lexer_test() {
  let ops = mock_compiler_operations()

  internal.compile_with_options("test.c", False, False, True, ops)
  |> should.be_ok
  |> should.equal("Codegen ran")
}

pub fn driver_no_flags_test() {
  let ops = mock_compiler_operations()

  internal.compile_with_options("test.c", False, False, False, ops)
  |> should.be_ok
  |> should.equal("Output created")
}
