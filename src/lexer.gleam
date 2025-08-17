import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type Token {
  Identifier(String)
  Number(String)
  String(String)
  KeywordReturn
  KeywordInt
  KeywordVoid
  LParen
  RParen
  LBrace
  RBrace
  Semicolon
  Plus
  Minus
  Assign
  EOF
  Error(String)
}

pub type Lexer {
  Lexer(source: String, position: Int, line: Int, column: Int)
}

pub fn token_to_string(token: Token) -> String {
  case token {
    Identifier(name) -> "Identifier(" <> name <> ")"
    Number(value) -> "Number(" <> value <> ")"
    String(value) -> "String(" <> value <> ")"
    KeywordReturn -> "KeywordReturn"
    KeywordInt -> "KeywordInt"
    KeywordVoid -> "KeywordVoid"
    LParen -> "LParen"
    RParen -> "RParen"
    LBrace -> "LBrace"
    RBrace -> "RBrace"
    Semicolon -> "Semicolon"
    Plus -> "Plus"
    Minus -> "Minus"
    Assign -> "Assign"
    EOF -> "EOF"
    Error(msg) -> "Error(" <> msg <> ")"
  }
}

pub fn print_tokens(tokens: List(Token)) {
  tokens
  |> list.map(token_to_string)
  |> string.join("\n")
  |> io.println
}

pub fn tokenize(filename: String) -> Result(List(Token), String) {
  simplifile.read(filename)
  |> result.map_error(fn(_) { "Failed to read file: " <> filename })
  |> result.map(fn(content) {
    let lexer = Lexer(source: content, position: 0, line: 1, column: 1)
    lex_all(lexer, [])
  })
}

fn lex_all(lexer: Lexer, tokens: List(Token)) -> List(Token) {
  case next_token(lexer) {
    #(EOF, _) -> list.reverse([EOF, ..tokens])
    #(token, new_lexer) -> lex_all(new_lexer, [token, ..tokens])
  }
}

fn next_token(lexer: Lexer) -> #(Token, Lexer) {
  let lexer = skip_whitespace(lexer)

  case current_char(lexer) {
    "" -> #(EOF, lexer)
    "(" -> #(LParen, advance(lexer))
    ")" -> #(RParen, advance(lexer))
    "{" -> #(LBrace, advance(lexer))
    "}" -> #(RBrace, advance(lexer))
    ";" -> #(Semicolon, advance(lexer))
    "+" -> #(Plus, advance(lexer))
    "-" -> #(Minus, advance(lexer))
    "\"" -> lex_string(advance(lexer), "")
    char -> {
      case is_digit(char) {
        True -> lex_number(lexer, "")
        False ->
          case is_alpha(char) || char == "_" {
            True -> lex_identifier(lexer, "")
            False -> #(Error("Unexpected character: " <> char), advance(lexer))
          }
      }
    }
  }
}

fn skip_whitespace(lexer: Lexer) -> Lexer {
  case current_char(lexer) {
    char ->
      case is_whitespace(char) {
        True -> skip_whitespace(advance(lexer))
        False -> lexer
      }
  }
}

fn lex_string(lexer: Lexer, acc: String) -> #(Token, Lexer) {
  case current_char(lexer) {
    "" -> #(Error("unterminated string"), lexer)
    "\"" -> #(String(acc), advance(lexer))
    "\\" -> {
      let lexer = advance(lexer)
      case current_char(lexer) {
        "n" -> lex_string(advance(lexer), acc <> "\n")
        "t" -> lex_string(advance(lexer), acc <> "\t")
        "r" -> lex_string(advance(lexer), acc <> "\r")
        "\\" -> lex_string(advance(lexer), acc <> "\\")
        "\"" -> lex_string(advance(lexer), acc <> "\"")
        char -> lex_string(advance(lexer), acc <> char)
      }
    }
    char -> lex_string(advance(lexer), acc <> char)
  }
}

fn lex_number(lexer: Lexer, acc: String) -> #(Token, Lexer) {
  case current_char(lexer) {
    char ->
      case is_digit(char) {
        True -> lex_number(advance(lexer), acc <> char)
        False -> #(Number(acc), lexer)
      }
  }
}

fn lex_identifier(lexer: Lexer, acc: String) -> #(Token, Lexer) {
  case current_char(lexer) {
    char ->
      case is_alphanumeric(char) || char == "_" {
        True -> lex_identifier(advance(lexer), acc <> char)
        False -> {
          let token = case acc {
            "return" -> KeywordReturn
            "int" -> KeywordInt
            "void" -> KeywordVoid
            _ -> Identifier(acc)
          }
          #(token, lexer)
        }
      }
  }
}

fn current_char(lexer: Lexer) -> String {
  case lexer.position >= string.length(lexer.source) {
    True -> ""
    False -> string.slice(lexer.source, lexer.position, 1)
  }
}

fn advance(lexer: Lexer) -> Lexer {
  case current_char(lexer) {
    "\n" ->
      Lexer(
        source: lexer.source,
        position: lexer.position + 1,
        line: lexer.line + 1,
        column: 1,
      )
    _ ->
      Lexer(
        source: lexer.source,
        position: lexer.position + 1,
        line: lexer.line,
        column: lexer.column + 1,
      )
  }
}

fn is_digit(char: String) -> Bool {
  string.contains("0123456789", char)
}

fn is_alpha(char: String) -> Bool {
  string.contains("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", char)
}

fn is_alphanumeric(char: String) -> Bool {
  { is_alpha(char) || is_digit(char) }
}

fn is_whitespace(char: String) -> Bool {
  { char == " " || char == "\t" || char == "\n" || char == "\r" }
}
