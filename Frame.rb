class Frame

    def initialize (link = nil)
        @link = link
        @locals = {}
    end

    # Probably need to keep a table of variables here.
    # The table is a runtime table, so should be independent of scopes I think.
    def define (name, value)
        @locals[name] = value
    end

end
