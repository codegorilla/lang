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
      #chain.each do |inst|
      done = false
      pc = 0
      while !done do
        inst = chain[pc]
        case inst.kind

        when :ADD then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('add')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1

        when :BAND then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('band')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :BEGIN then
          puts "<BEGIN>"
          pc += 1
          
        when :BF then
          obj = @fp.stack.pop
          if obj == $false then
            pc = inst.text
          else
            pc += 1
          end
          
        when :BNOT then
          obj = @fp.stack.pop
          classObj = obj.type
          methodObj = classObj.getMember('bnot')
          method = methodObj.value[1]
          result = method.call([obj])
          @fp.stack << result
          pc += 1
          
        when :BOR then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('bor')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :BXOR then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('bxor')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
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
          pc += 1
          
        when :DIV then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('div')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          puts result.value
          pc += 1
          
        when :EQU then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('equ')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :GE then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('ge')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :GET then
          # take TOP
          obj = @fp.stack.pop
          # get its member
          obj1 = obj.getMember(inst.text)
          @fp.stack << obj1
          pc += 1
          
        when :GT then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('gt')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :HALT then
          puts "<HALT>"
          done = true
        
        when :JUMP then
          pc = inst.text
        
        when :LAB then
          # Labels are pseudo-instructions and become NOPs
          pc += 1

        when :LE then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('le')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :LOAD then
          obj = @globals[inst.text]
          if !obj then obj = $builtins[inst.text] end
          @fp.stack << obj
          #if obj != nil then puts obj.value end
          pc += 1
          
        when :LOADL then
          obj = @fp.locals[inst.text.to_i]
          @fp.stack << obj
          pc += 1
          
        when :LT then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('lt')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :MUL then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('mul')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :NEG then
          obj = @fp.stack.pop
          classObj = obj.type
          methodObj = classObj.getMember('neg')
          method = methodObj.value[1]
          result = method.call([obj])
          @fp.stack << result
          pc += 1
          
        when :NEQ then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('neq')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :NOT then
          obj = @fp.stack.pop
          classObj = obj.type
          methodObj = classObj.getMember('not')
          method = methodObj.value[1]
          result = method.call([obj])
          @fp.stack << result
          pc += 1
          
        when :POP then
          @fp.stack.pop
          pc += 1
          
        when :POP_BLOCK then
          @fp.popBlock
          pc += 1
          
        when :PUSH_BLOCK then
        @fp.pushBlock
        pc += 1
        
        when :PUSH_NULL then
          obj =$null
          @fp.stack << obj
          pc += 1
          
        when :PUSH_UNIT then
          obj = $unit
          @fp.stack << obj
          pc += 1
          
        when :PUSH_BOOL then
          # Need to use if statement to choose $true or $false
          obj = if inst.text == "false" then $false else $true end
          @fp.stack << obj
          pc += 1
          
        when :PUSH_INT then
          obj = TauObject.new($Int, inst.text.to_i)
          @fp.stack << obj
          pc += 1
          
        when :PUSH_FLOAT then
          obj = TauObject.new($Float, inst.text.to_f)
          @fp.stack << obj
          pc += 1
          
        when :SHL then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('shl')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :SHR then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('shr')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
        when :STORE then
          @globals[inst.text] = @fp.stack.pop
          pc += 1
          
        when :STORL then
          @fp.locals[inst.text.to_i] = @fp.stack.pop
          #puts "Local value stored is #{@fp.locals[inst.text.to_i].value}"
          pc += 1
          
        when :SUB then
          xObj = @fp.stack.pop
          thisObj = @fp.stack.pop
          classObj = thisObj.type
          methodObj = classObj.getMember('sub')
          method = methodObj.value[1]
          result = method.call([thisObj, xObj])
          @fp.stack << result
          pc += 1
          
          else
          puts "Some other instruction!"
        end
      end
    end

end # class
