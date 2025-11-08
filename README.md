Data types:
- Numbers (`123`, `3.1415`, `+12`, `-31`, `2.`, `.99`)
- Dates (`2025-11-04`)
- Strings (`single-word`, `dots.dont.split.identifiers`, `"string with spaces"`, strings can be multiline)
- Tags (`#tags-start-with-hashtags`)
- Participants (`@Pastaga`, `@P.M`, `@404`)
- Arrays (`[...]`)
- Ranges (`from ... to ...`)

Tokens (grammar):
```yaml
NUMBER: "+"? "-"? DIGIT+ "."? DIGIT*
DATE: "(" DIGIT DIGIT DIGIT DIGIT "-" DIGIT DIGIT "-" DIGIT DIGIT ")"
STRING: "\"" <anything but a double-quote>* "\""
TAG: "#" (ALPHA | DIGIT | SPECIAL)+
PARTICIPANT: "@" (ALPHA | DIGIT | SPECIAL)+
IDENTIFIER: ALPHA (ALPHA | DIGIT | SPECIAL)*
ALPHA: "a" | "b" ... | "z" | "A" | "B" ... | "Z" | "_"
SPECIAL: "." | "-" 
DIGIT: "0" | "1" ... | "9"

// Other syntax
OPEN_BRACKET: "["
CLOSE_BRACKET: "]"
```

Grammar :
```yaml
expression: define-block
           | type-expression
           | game-expression
           | set-expression
           | assignment-expression

define-block: "define" IDENTIFIER STRING TAG* expression* "end"

type-expression: "type" ("edition" | "participant")

game-expression: "game" STRING "results" array TAG*

set-expression: IDENTIFIER "set" IDENTIFIER litteral

assignment-expression: IDENTIFIER literal

literal: array | range | primary

array: "[" (litteral TAG*)* "]"

range: "from" DATE "to" DATE

primary: BOOLEAN | NUMBER | DATE | STRING | PARTICIPANT
```


# Lexer

The lexer takes the raw text file and turns it into an array of tokens.

Here is an example:
```
type edition
name 2025
dates from (2025-09-05) to (2025-09-08)
standing [@Parapluie @404 @P.M @Catapulte @Pastaga @Dua @Otho @Barbeer @Lintendo @JMM]

description "
Bla bla bla.
This is a multi-line text example.
"

define game-group "FFA (4 joueurs)" #individual-games
	description "Règles : chaque canditat joue à 4 jeux dans la liste."
	points [+5 +3 +2 +1]
	game "Blaze Rush" results   [@Pastaga   @Otho      @Lintendo @404]
	game "Tricky Tower" results [@P.M       @Catapulte @Dua      @Barbeer]
end

--- EXPECTED OUTPUT TOKENS ---

(TYPE)
(EDITION)
(IDENTIFIER page-name)
(NUMBER 2025)
(IDENTIFIER dates)
(FROM)
(DATE 2025-09-05)
(TO)
(DATE 2025-09-08)
(IDENTIFIER standing)
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
(IDENTIFIER description)
(STRING Bla bla bla.
This is a multi-line text example.
)
(DEFINE)
(GAME-GROUP)
(STRING FFA (4 joueurs))
(TAG individual-games)
(IDENTIFIER description)
(STRING Règles : chaque canditat joue à 4 jeux dans la liste.)
(IDENTIFIER points)
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
(STRING Tricky Tower)
(RESULTS)
(OPEN_BRACKET [)
(PARTICIPANT P.M)
(PARTICIPANT Catapulte)
(PARTICIPANT Dua)
(PARTICIPANT Barbeer)
(CLOSE_BRACKET ])
(END)
```


# Parsing

After passing the input file through the lexer, the tokens are turned into fixed lisp structures.

Files can be turned into 2 types of structures: editions and participants. 
The file must start with the `type` keyword followed by `edition` or `participant` to determine the structure.

```lisp
(defstruct EDITION
  :NAME nil  ; string 
  :DATES nil  ; #S(RANGE)
  :STANDING nil  ; list of #S(PARTICIPANT-REF)
  :DESCRIPTION nil  ; string
  :GAME-GROUPS nil  ; list of #S(GAME-GROUP)
  :GAMES nil)  ; list of #S(GAME)
```

```lisp
(defstruct PARTICIPANT
  :NAMES nil  ; string
  :DESCRIPTION nil)  ; string
```

With substructures:
```lisp
(defstruct DATE
  :YEAR 0  ; number
  :MONTH 0  ; number (1 is january)
  :DAY-OF-MONTH 0)  ; number

(defstruct RANGE 
  :START nil  ; date
  :END nil)  ; date 

(defstruct PARTICIPANT-REF
  :NAME nil)  ; string

(defstruct GAME-GROUP 
  :NAME nil  ; string
  :TAGS nil)  ; list of symbol

(defstruct GAME 
  :NAME nil  ; string
  :DESCRIPTION nil  ; string
  :GROUP nil  ; string
  :TAGS nil  ; list of string
  :POINTS 0  ; number
  :RESULTS nil)  ; list of #S(PARTICIPANT-REF)
```

Example of decoded edition structure:  
```
#S(EDITION
	:NAME "2025"
	:DATES #S(RANGE :START (2025 09 05) :END (2025 09 08))
	:STANDING (#S(PARTICIPANT :NAME "Parapluie") 
			  #S(PARTICIPANT :NAME "404")
			  #S(PARTICIPANT :NAME "P.M")
			  #S(PARTICIPANT :NAME "Catapulte")
			  #S(PARTICIPANT :NAME "Pastaga")
			  #S(PARTICIPANT :NAME "Otho")
			  #S(PARTICIPANT :NAME "Barbeer")
			  #S(PARTICIPANT :NAME "Lintendo")
			  #S(PARTICIPANT :NAME "JMM"))
    :DESCRIPTION "..."
	:GAME-GROUPS <list of> #S(GAME-GROUP :NAME "groupname" :TAGS <list of symbols>)
	:GAMES <list of> #S(GAME :NAME "name"
	                         :DESCRIPTION "desc"
	                         :GROUP "groupname"
	                         :TAGS <list of symbols>
							 :POINTS <number or list or hashtable>
							 :RESULTS (<list of> #S(PARTICIPANT))))
```

