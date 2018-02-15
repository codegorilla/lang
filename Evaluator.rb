class Evaluator
  
    def initialize (chain)
      @chain = chain
      pp @chain
      #puts @chain

      @globals = {}

      @stack = []

    end

    def start
      program(@chain)
    end

    def stack
      @stack
    end

    def program (chain)
      chain.each do |inst|
        case inst.kind

        when :ADD then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('add')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :BAND then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('band')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :BEGIN then
          puts "<BEGIN>"

        when :BNOT then
          obj = @stack.pop
          classObj = obj.type
          methodObj = classObj.getMember('bnot')
          method = methodObj.value[1]
          result = method.call([obj])
          @stack << result

        when :BOR then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('bor')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :BXOR then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('bxor')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :CALL then
          # Process as a native function
          functionObj = @stack.pop
          numParams = functionObj.value[0]
          code = functionObj.value[1]

          # Add a dummy argument
          args = []
          args << TauObject.new($Int, 4)

          result = code.call(args)
          @stack << result

        when :DIV then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('div')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result
          puts result.value

        when :EQU then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('equ')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :GE then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('ge')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :GET then
          # take TOP
          obj = @stack.pop
          # get its member
          obj1 = obj.getMember(inst.text)
          @stack << obj1

        when :GT then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('gt')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :HALT then
          puts "<HALT>"

        when :LE then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('le')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :LOAD then
          obj = @globals[inst.text]
          if !obj then obj = $builtins[inst.text] end
          @stack << obj
          #if obj != nil then puts obj.value end

        when :LT then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('lt')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :MUL then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('mul')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :NEG then
          obj = @stack.pop
          classObj = obj.type
          methodObj = classObj.getMember('neg')
          method = methodObj.value[1]
          result = method.call([obj])
          @stack << result

        when :NEQ then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('neq')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :NOT then
          obj = @stack.pop
          classObj = obj.type
          methodObj = classObj.getMember('not')
          method = methodObj.value[1]
          result = method.call([obj])
          @stack << result

        when :POP then
          @stack.pop

        when :PUSH_NULL then
          obj =$null
          @stack << obj

        when :PUSH_UNIT then
          obj = $unit
          @stack << obj

        when :PUSH_BOOL then
          # Need to use if statement to choose $true or $false
          obj = if inst.text == "false" then $false else $true end
          @stack << obj

        when :PUSH_INT then
          obj = TauObject.new($Int, inst.text.to_i)
          @stack << obj

        when :PUSH_FLOAT then
          obj = TauObject.new($Float, inst.text.to_f)
          @stack << obj
        
        when :STORE then
          @globals[inst.text] = @stack.pop

        when :SHL then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('shl')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :SHR then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('shr')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

        when :SUB then
          xObj = @stack.pop
          thisObj = @stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('sub')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @stack << result

          else
          puts "Some other instruction!"
        end
      end
    end

end # class
