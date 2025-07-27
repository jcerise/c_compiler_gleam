# shiny_cc

A C compiler written in Gleam, following the implementation guide from [Writing a C Compiler](https://nostarch.com/writing-c-compiler) by Nora Sandler.

[![Package Version](https://img.shields.io/hexpm/v/shiny_cc)](https://hex.pm/packages/shiny_cc)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/shiny_cc/)

## About

This project implements a complete C compiler using Gleam, structured as a traditional compiler pipeline with stages for lexical analysis, parsing, code generation, and executable creation. The compiler supports staged execution through command-line flags, allowing you to stop at any stage of the compilation process for debugging and educational purposes.

## Features

- **Staged Compilation**: Run individual compiler phases independently
- **CLI Interface**: Command-line tool with intuitive flags
- **Testable Architecture**: Uses dependency injection for isolated testing
- **Educational Focus**: Clear separation of compiler phases for learning

## Usage

```sh
# Compile a C file to an executable
gleam run -- input.c

# Run only the lexer
gleam run -- input.c --lexer

# Run lexer and parser only
gleam run -- input.c --parse

# Run lexer, parser, and code generation
gleam run -- input.c --codegen
```

Further documentation can be found at <https://hexdocs.pm/shiny_cc>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
