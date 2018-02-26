

def fun0 ():
  x = 1
  def fun1 ():
    def fun2 (t):
      nonlocal x
      x = t
    fun2(10)
  print(x)
  fun1()
  print(x)

fun0()

