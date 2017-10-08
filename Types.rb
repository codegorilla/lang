# Need some kind of type registry instead of global variables
$Class = TauObject.new
$Any = TauObject.new($Class)
$Null = TauObject.new($Class)
$Exception = TauObject.new($Class)
$Bool = TauObject.new($Class)
$Int = TauObject.new($Class)
$Float = TauObject.new($Class)

