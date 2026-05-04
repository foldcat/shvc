package tokens

// operators
Eof :: struct {}
Colon :: struct {} // :
Arrow :: struct {} // ->
Caret :: struct {} // ^
Ampersand :: struct {} // &
Assign :: struct {} // =
Comma :: struct {} // ,
Semi_Colon :: struct {} // ;
Plus :: struct {} // +
Minus :: struct {} // -
Star :: struct {} // *
Slash :: struct {} // /
Equal :: struct {} // ==
Not_Equal :: struct {} // !=
Less :: struct {} // <
Greater :: struct {} // >

// brackets
Open_Paren :: struct {} // (
Close_Paren :: struct {} // )
Open_Bracket :: struct {} // {
Close_Bracket :: struct {} // }
Open_SB :: struct {} // [
Close_SB :: struct {} // ]


// identifiers
Val :: struct {}
Mut :: struct {}
Fn :: struct {}
Return :: struct {}
If :: struct {}
Struct :: struct {}
For :: struct {}
Defer :: struct {}
In :: struct {}
Break :: struct {}
Continue :: struct {}

Identifier :: struct {
	content: string, // distinct also works
}

// numebers
Int_Literal :: struct {
	content: i32,
} // TODO: consider

// strings
String_Literal :: struct {
	content: string,
}

Token :: union {
	// operators
	Eof,
	Colon,
	Arrow,
	Caret,
	Ampersand,
	Assign,
	Comma,
	Semi_Colon,
	Plus,
	Minus,
	Star,
	Slash,
	Equal,
	Not_Equal,
	Less,
	Greater,

	// brackets
	Open_Paren,
	Close_Paren,
	Open_Bracket,
	Close_Bracket,
	Open_SB,
	Close_SB,

	// identifiers
	Val,
	Mut,
	Fn,
	Return,
	If,
	Struct,
	For,
	Identifier,
	Defer,
	In,
	Break,
	Continue,

	// numbers
	Int_Literal,

	// strings
	String_Literal,
}
