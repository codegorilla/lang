# lang
A programming language

## Lexical Structure

### Keywords

break
class
continue
def
do
else
extends
false
for
if
import
new
null
print
return
super
this
true
val
var
while

## Syntactic Structure

lx has a mostly-LL(1) grammar that is designed to be easy to parse by a top-down recursive descent parser.

## Declarations

Declarations are used to introduce names into program.
A declaration will cause a symbol table entry to be made in the current scope.
There are four kinds of declarations:

* variable declarations

* value declarations

A value declaration is just a special kind of variable declaration that prevents
the name from being re-bound to a different value. You can think of it as a
shorthand for something that would look like this in another language:

````javascript
const var x = 1;
````

Instead, you just have to type:

````javascript
val x = 1;
````

* function declarations

* class declarations

## Statements

lx has nine kinds of statements.

* break statement

* continue statement

* do statement

* empty statement

This statement does nothing. It is a "no-op".

* for statement

* print statement

This statement is used to output the result of an expression

* return statement

This statement causes an early return from a function.

* while statement

* expression statement

This statement consists of an expression followed by a semicolon.

## Types

Built-in Types

* Bool

* Int

* Float


## TODO

* Floating point DFA

* if statements

* nested symbol tables / scopes

* Panic-mode error handling

* +=, -=, operators

