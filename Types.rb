# Raw objects don't have any class
$Object = TauObject.new

# Need some kind of type registry instead of global variables

# Provide (type, value) as parameters

$Bool = TauObject.new($Class)
$Int = TauObject.new($Class)
$Float = TauObject.new($Class)

$String = TauObject.new($Class)
$Array = TauObject.new($Class)
# Function objects might need more work, different one based on number of
# parameters
# $Function1, $Function2, etc...
$Function = TauObject.new($Class, "<FunctionClass>")

$NativeFunction = TauObject.new($Class, "<NativeFunctionClass>")

# Singletons
$true = TauObject.new($Bool, true)
$false = TauObject.new($Bool, false)

$unit = TauObject.new($Unit, "()")

