# Gecko
Gecko is a language where every statement is a regex substitution or a conditional based on a regex match,
applied to a single global string. It aims to make the process of programming in regexes as pleasant as could reasonably be expected.

## Syntax
There is one operation that changes the current value of the global string - transformation:
```
"<regex>" -> "<substitution>"

// current value is "hello world"
"([a-z]+) world" -> "\1 universe"
// now "hello universe"
```
The left hand part is a regular expression which will be applied to the current value. The right hand part is a substitution string, where \x
will be replaced with the xth capture group from the left hand part. If the left hand part doesn't match then no transformation occurs. If
not enough capture groups are provided the rest are replaced with empty strings.

There are a couple of special cases:
```
-> "to" // set the current value to "to", discarding whatever it was

// the . operator means 'everything'. on the left hand side of a transformation it's a shorthand for ".*", on the right "\0"
. -> "...\0..." // just capture the entire current value and use it whole to construct the new one
. -> . // do nothing
// you can say
"..." -> .
// but it's a nop too

"..." -> "\@" // \@ takes a line of user input and inserts it. more than one \@ in a single transform takes input once and replaces each one with the same thing
```

There are also three statements: if, while and map.


If statements take a regex to test the current value against, and two operations - which may be statements themselves - to do the first if the regex matches and the second if it doesn't.
```
if "regex"
  "a" -> "b"
  "c" -> "d"
```
The indentation is optional, and in fact you may want to write
```
if "a"
  "b" -> "c"
  if "d"
    "e" -> "f"
    "g" -> "h"
```
as
```
if "a"
  "b" -> "c"
if "d"
  "e" -> "f"
  "g" -> "h"
```

While statements take a regex to test against the current value and an operation, and do the operation repeatedly until the regex no longer matches.
```
while "a.*b"
  "a(.*)b" -> "\1"
// strip all a ... b pairs from around the current value
```

Map statements take a regex and a substitution like transformations do, and also a further operation to apply to each capture group
before actually making the substitution. This is the only case where an operation can be applied to something other than the current value.
```
map "(.*):(.*)"
  . -> "[\0]" // operation to perform on the capture groups
  "\2\1"
// maps hello:world to [world][hello]
```

## Installation
should be as simple as `raco pkg install path/to/gecko`, then you'll be able to use it in racket as `#lang gecko`
