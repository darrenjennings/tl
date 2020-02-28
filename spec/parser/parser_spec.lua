local tl = require("tl")

local function strip_typeids(t)
   for k,v in pairs(t) do
      if type(v) == "table" then
         strip_typeids(v)
      elseif k == "typeid" then
         t[k] = nil
      end
   end
   return t
end

describe("parser", function()
   it("accepts an empty file (regression test for #43)", function ()
      local tokens = tl.lex("")
      local syntax_errors = {}
      local _, ast = tl.parse_program(tokens, syntax_errors, "foo.tl")
      assert.same({}, syntax_errors)
      assert.same({
         kind = "statements",
         tk = "$EOF$",
         x = 1,
         y = 1,
      }, ast)
   end)

   it("accepts 'return;' (regression test for #52)", function ()
      local tokens = tl.lex("return;")
      local syntax_errors = {}
      local _, ast = tl.parse_program(tokens, syntax_errors, "foo.tl")
      assert.same({}, syntax_errors)
      assert.same(1, #ast)
      assert.same("return", ast[1].kind)
   end)

   it("accepts semicolons in tables (regression test for #54)", function ()
      local tokens = tl.lex([[
         local t = {
            foo = "bar";
            foo = "baz";
         }
      ]])
      local syntax_errors = {}
      local _, ast = tl.parse_program(tokens, syntax_errors, "foo.tl")
      assert.same({}, syntax_errors)
      assert.same(1, #ast)
      assert.same("local_declaration", ast[1].kind)

      tokens = tl.lex([[
         local t = {
            foo = "bar",
            foo = "baz",
         }
      ]])
      local _, ast2 = tl.parse_program(tokens, syntax_errors, "foo.tl")
      assert.same({}, syntax_errors)
      assert.same(1, #ast)
      assert.same(strip_typeids(ast), strip_typeids(ast2))
   end)
end)
