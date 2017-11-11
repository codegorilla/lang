# Need some kind of type registry instead of global variables
$Class = TauObject.new
$Any = TauObject.new($Class)
$Null = TauObject.new($Class)
$Unit = TauObject.new($Class)
$Exception = TauObject.new($Class)
$Bool = TauObject.new($Class)
$Int = TauObject.new($Class)
$Float = TauObject.new($Class)

$String = TauObject.new($Class)
$Array = TauObject.new($Class)
# Function objects might need more work, different one based on number of
# parameters
# $Function1, $Function2, etc...
$Function = TauObject.new($Class)

# Singletons
$true = TauObject.new($Bool, true)
$false = TauObject.new($Bool, false)

$unit = TauObject.new($Unit, "()")

