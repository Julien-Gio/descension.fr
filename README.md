# DESCENSION.FR - Static Site Generator

# Running the generator
Install SBCL (or equivalent) and run the `run.lisp` file.
```
sbcl --script run.lisp
```

# Overview
There are 4 parts to the generator:
1. The `content`, which describes the meaningful data to display in the pages. The data is stored in a custom textfile format (see below).
2. The `src/interpreter`, that lexes and parses the input data into an internal data structure.
3. The `src/pages`, which lay out how to render each page.
4. The `src/renderer`, that takes in a layout and outputs HTML.


# Custom data format
## Types and Grammar
Data types:
- Numbers (e.g. `123`, `3.1415`, `+12`, `-31`, `2.`, `.99`)
- Dates (e.g. `(2025-11-04)`)
- Strings (e.g. `single-word`, `dots.dont.split.identifiers`, `"string with spaces need quotes"`, also strings can be multiline)
- Tags (e.g. `#tags-start-with-hashtags`)
- Participants (e.g. `@Pastaga`, `@P.M`, `@404`)
- Lists (e.g. `[...]`)
- Ranges (e.g. `from ... to ...`)
- Maps (e.g. `... set ...`)
- Comments (e.g. `; comments start with semi-colon. Also, I know comments aren't datatype, whatever.`)

Tokens (grammar):
```EBNF
ALPHA: "a" | "b" ... | "z" | "A" | "B" ... | "Z" | "_"
SIGN: "+" | "-"
DIGIT: "0" | "1" ... | "9"
NUMBER: SIGN? (DIGIT+ "."? DIGIT*) |
DATE: "(" DIGIT DIGIT DIGIT DIGIT "-" DIGIT DIGIT "-" DIGIT DIGIT ")"
SPECIAL: "." | "-" 
IDENTIFIER: ALPHA (ALPHA | DIGIT | SPECIAL)*
STRING: "\"" <anything but a double-quote>* "\""
TAG: "#" (ALPHA | DIGIT | SPECIAL)+
PARTICIPANT: "@" (ALPHA | DIGIT | SPECIAL)+

// Keywords and other syntax
TYPE: "type"
EDITION: "edition"
PARTICIPANTS: "participants"
PARTICIPANT: "participant"
DATES: "dates"
FROM: "from"
TO: "to"
DEFINE: "define"
END: "end"
NAME: "name"
DESCRIPTION: "description"
GAME-GROUP: "game-group"
POINTS: "points"
SET: "set"
GAME: "game"
RESULTS: "results"
TOURNAMENT: "tournament"
WINNERS_BRACKET: "winners-bracket"
LOSERS_BRACKET: "losers-bracket"
FINAL_BRACKET: "final-bracket"
```

Grammar :
```yaml
expression: type-expression
           | define-block
           | game-expression
           | set-expression
           | assignment-expression

type-expression: "type" "edition"

define-block: "define" IDENTIFIER STRING TAG* expression* "end"

game-expression: "game" STRING ("points" STRING)? "results" array TAG*

set-expression: IDENTIFIER "set" IDENTIFIER? litteral

assignment-expression: IDENTIFIER literal

literal: array | range | primary

array: "[" litteral* "]"

range: "from" DATE "to" DATE

primary: BOOLEAN | NUMBER | DATE | STRING | PARTICIPANT
```


## Lexer

The lexer takes the raw text file and turns it into a list of tokens.

Here is an example:
```
type edition ; this is a comment and is ignored.
name "2025"
dates from (2025-09-05) to (2025-09-08)
participants [@Parapluie @404 @P.M @Catapulte @Pastaga @Dua @Otho @Barbeer @Lintendo @JMM]

description "
Bla bla bla.
This is a multi-line text example.
"

define game-group "FFA (4 joueurs)" #individual-games
	description "Règles : chaque canditat joue à 4 jeux dans la liste."
	points set [+5 +3 +2 +1]
	game "Blaze Rush" results [@Pastaga @Otho @Lintendo @404]
	game "Tricky Towers" results [@P.M @Catapulte @Dua @Barbeer]
end

--- EXPECTED OUTPUT TOKENS ---

(TYPE)
(EDITION)
(NAME)
(STRING 2025)
(DATES)
(FROM)
(DATE 2025-09-05)
(TO)
(DATE 2025-09-08)
(PARTICIPANTS)
(OPEN_BRACKET [)
(PARTICIPANT Parapluie)
(PARTICIPANT 404)
(PARTICIPANT P.M)
(PARTICIPANT Catapulte)
(PARTICIPANT Pastaga)
(PARTICIPANT Dua)
(PARTICIPANT Otho)
(PARTICIPANT Barbeer)
(PARTICIPANT Lintendo)
(PARTICIPANT JMM)
(CLOSE_BRACKET ])
(DESCRIPTION)
(STRING Bla bla bla.
This is a multi-line text example.
)
(DEFINE)
(GAME-GROUP)
(STRING FFA (4 joueurs))
(TAG individual-games)
(DESCRIPTION)
(STRING Règles : chaque canditat joue à 4 jeux dans la liste.)
(POINTS)
(SET)
(OPEN_BRACKET [)
(NUMBER +5)
(NUMBER +3)
(NUMBER +2)
(NUMBER +1)
(CLOSE_BRACKET ])
(GAME)
(STRING Blaze Rush)
(RESULTS)
(OPEN_BRACKET [)
(PARTICIPANT Pastaga)
(PARTICIPANT Otho)
(PARTICIPANT Lintendo)
(PARTICIPANT 404)
(CLOSE_BRACKET ])
(GAME)
(STRING Tricky Towers)
(RESULTS)
(OPEN_BRACKET [)
(PARTICIPANT P.M)
(PARTICIPANT Catapulte)
(PARTICIPANT Dua)
(PARTICIPANT Barbeer)
(CLOSE_BRACKET ])
(END)
```


## Parsing

After passing the input file through the lexer, the tokens are turned into fixed lisp structures.
 
The file must start with the `type` keyword followed by `edition` to determine the structure.
- Currently, this is the only allowed type, but this opens the door to more types later on.

Example of decoded edition structure:  
```
#S(EDITION
	:NAME "2025"
	:DATES #S(RANGE :START (2025 09 05) :END (2025 09 08))
	:PARTICIPANTS (#S(PARTICIPANT-REF :NAME "Parapluie") 
			  #S(PARTICIPANT-REF :NAME "404")
			  #S(PARTICIPANT-REF :NAME "P.M")
			  #S(PARTICIPANT-REF :NAME "Catapulte")
			  #S(PARTICIPANT-REF :NAME "Pastaga")
			  #S(PARTICIPANT-REF :NAME "Otho")
			  #S(PARTICIPANT-REF :NAME "Barbeer")
			  #S(PARTICIPANT-REF :NAME "Lintendo")
			  #S(PARTICIPANT-REF :NAME "JMM"))
    :DESCRIPTION "..."
	:GAME-GROUPS <list of> #S(GAME-GROUP :NAME "groupname" :TAGS ("highlight"))
	:GAMES <list of> #S(GAME :NAME "name"
	                         :GROUP "groupname"
	                         :TAGS NIL
							             :POINTS (5 3 2 1)
							             :RESULTS (<list of> #S(PARTICIPANT-REF))))
```

