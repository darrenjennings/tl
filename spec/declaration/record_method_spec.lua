local tl = require("tl")

describe("record method", function()
   it("valid declaration", function()
      local tokens = tl.lex([[
         local r = {
            x = 2,
            b = true,
         }
         function r:f(a: number, b: string): boolean
            if self.b then
               return #b == 3
            else
               return a > self.x
            end
         end
         local ok = r:f(3, "abc")
      ]])
      local _, ast = tl.parse_program(tokens)
      local errors = tl.type_check(ast)
      assert.same({}, errors)
   end)

   it("nested declaration", function()
      local tokens = tl.lex([[
         local r = {
            z = {
               x = 2,
               b = true,
            },
         }
         function r.z:f(a: number, b: string): boolean
            if self.b then
               return #b == 3
            else
               return a > self.x
            end
         end
         local ok = r.z:f(3, "abc")
      ]])
      local _, ast = tl.parse_program(tokens)
      local errors = tl.type_check(ast)
      assert.same({}, errors)
   end)

   it("nested declaration in {}", function()
      local tokens = tl.lex([[
         local r = {
            z = {},
         }
         function r.z:f(a: number, b: string): boolean
            return true
         end
         local ok = r.z:f(3, "abc")
      ]])
      local _, ast = tl.parse_program(tokens)
      local errors = tl.type_check(ast)
      assert.same({}, errors)
   end)

   it("deep nested declaration", function()
      local tokens = tl.lex([[
         local r = {
            a = {
               b = {
                  x = true
               }
            },
         }
         function r.a.b:f(a: number, b: string): boolean
            return self.x
         end
         local ok = r.a.b:f(3, "abc")
      ]])
      local _, ast = tl.parse_program(tokens)
      local errors = tl.type_check(ast)
      assert.same({}, errors)
   end)

   it("resolves self", function()
      local tokens = tl.lex([[
         local r = {
            x = 2,
            b = true,
         }
         function r:f(a: number, b: string): boolean
            return self.invalid
         end
         local ok = r:f(3, "abc")
      ]])
      local _, ast = tl.parse_program(tokens)
      local errors = tl.type_check(ast)
      assert.match("invalid key 'invalid' in record 'self'", errors[1].err, 1, true)
   end)

   it("catches invocation style", function()
      local tokens = tl.lex([[
         local r = {
            x = 2,
            b = true,
         }
         function r:f(a: number, b: string): boolean
            return self.b
         end
         local ok = r.f(3, "abc")
      ]])
      local _, ast = tl.parse_program(tokens)
      local errors = tl.type_check(ast)
      assert.match("invoked method as a regular function", errors[1].err, 1, true)
   end)

   it("allows invocation when properly used with '.'", function()
      local tokens = tl.lex([[
         local r = {
            x = 2,
            b = true,
         }
         function r:f(a: number, b: string): boolean
            return self.b
         end
         local ok = r.f(r, 3, "abc")
      ]])
      local _, ast = tl.parse_program(tokens)
      local errors = tl.type_check(ast)
      assert.same({}, errors)
   end)

   it("allows invocation when properly used with ':'", function()
      local tokens = tl.lex([[
         local r = {
            x = 2,
            b = true,
         }
         function r:f(a: number, b: string): boolean
            return self.b
         end
         local ok = r:f(3, "abc")
      ]])
      local _, ast = tl.parse_program(tokens)
      local errors = tl.type_check(ast)
      assert.same({}, errors)
   end)
end)
