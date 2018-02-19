require './Block'

class Evaluator

    def initialize (chain)
      @chain = chain
      pp @chain
      #puts @chain

      @globals = {}
      @fp = nil
    end

    def start
      @fp = Frame.new
      program(@chain)
    end

    def program (chain)
      chain.each do |inst|
        case inst.kind

        when :ADD then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('add')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :BAND then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('band')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :BEGIN then
          puts "<BEGIN>"

        when :BNOT then
          obj = @fp.stack.pop
          classObj = obj.type
          methodObj = classObj.getMember('bnot')
          method = methodObj.value[1]
          result = method.call([obj])
          @fp.stack << result

        when :BOR then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('bor')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :BXOR then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('bxor')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :CALL then
          # Process as a native function
          functionObj = @fp.stack.pop
          numParams = functionObj.value[0]
          code = functionObj.value[1]

          # Add a dummy argument
          args = []
          args << TauObject.new($Int, 4)

          result = code.call(args)
          @fp.stack << result

        when :DIV then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('div')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          puts result.value

        when :EQU then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('equ')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :GE then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('ge')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :GET then
          # take TOP
          obj = @fp.stack.pop
          # get its member
          obj1 = obj.getMember(inst.text)
          @fp.stack << obj1

        when :GT then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('gt')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :HALT then
          puts "<HALT>"

        when :LE then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('le')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :LOAD then
          obj = @globals[inst.text]
          if !obj then obj = $builtins[inst.text] end
          @fp.stack << obj
          #if obj != nil then puts obj.value end

        when :LOADL then
          obj = @fp.currentBlock.locals[inst.text.to_i]
          @fp.stack << obj

        when :LT then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('lt')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :MUL then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('mul')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :NEG then
          obj = @fp.stack.pop
          classObj = obj.type
          methodObj = classObj.getMember('neg')
          method = methodObj.value[1]
          result = method.call([obj])
          @fp.stack << result

        when :NEQ then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('neq')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :NOT then
          obj = @fp.stack.pop
          classObj = obj.type
          methodObj = classObj.getMember('not')
          method = methodObj.value[1]
          result = method.call([obj])
          @fp.stack << result

        when :POP then
          @fp.stack.pop

        when :POP_BLOCK then
          @fp.popBlock

        when :PUSH_BLOCK then
        @fp.pushBlock

        when :PUSH_NULL then
          obj =$null
          @fp.stack << obj

        when :PUSH_UNIT then
          obj = $unit
          @fp.stack << obj

        when :PUSH_BOOL then
          # Need to use if statement to choose $true or $false
          obj = if inst.text == "false" then $false else $true end
          @fp.stack << obj

        when :PUSH_INT then
          obj = TauObject.new($Int, inst.text.to_i)
          @fp.stack << obj

        when :PUSH_FLOAT then
          obj = TauObject.new($Float, inst.text.to_f)
          @fp.stack << obj
        
        when :STORE then
          @globals[inst.text] = @fp.stack.pop
        
        when :STORL then
          #@fp.locals[inst.text.to_i] = @fp.stack.pop
          #puts "Local value stored is #{@fp.locals[inst.text.to_i].value}"
          @fp.currentBlock.locals[inst.text.to_i] = @fp.stack.pop

        when :SHL then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('shl')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :SHR then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('shr')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

        when :SUB then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('sub')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result

          else
          puts "Some other instruction!"
        end
      end
    end

end # class
