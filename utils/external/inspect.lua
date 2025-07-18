local a
if (tonumber(_VERSION or (""):match "[%d.]*$") or 0) < 5.3 then
  local b, c = pcall(require, "compat53.module")
  if b then
    a = c
  end
end
local math = a and a.math or math
local string = a and a.string or string
local table = a and a.table or table
local inspect = { Options = {} }
inspect._VERSION = "inspect.lua 3.1.0"
inspect._URL = "http://github.com/kikito/inspect.lua"
inspect._DESCRIPTION = "human-readable representations of tables"
inspect._LICENSE = [[
  MIT LICENSE

  Copyright (c) 2022 Enrique García Cota

  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be included
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
inspect.KEY = setmetatable({}, {
  __tostring = function()
    return "inspect.KEY"
  end,
})
inspect.METATABLE = setmetatable({}, {
  __tostring = function()
    return "inspect.METATABLE"
  end,
})
local tostring = tostring
local e = string.rep
local f = string.match
local g = string.char
local h = string.gsub
local i = string.format
local j
if rawget then
  j = rawget
else
  j = function(k, l)
    return k[l]
  end
end
local function m(k)
  return next, k, nil
end
local function n(o)
  if f(o, '"') and not f(o, "'") then
    return "'" .. o .. "'"
  end
  return '"' .. h(o, '"', '\\"') .. '"'
end
local p = {
  ["\a"] = "\\a",
  ["\b"] = "\\b",
  ["\f"] = "\\f",
  ["\n"] = "\\n",
  ["\r"] = "\\r",
  ["\t"] = "\\t",
  ["\v"] = "\\v",
  ["\127"] = "\\127",
}
local q = { ["\127"] = "\127" }
for r = 0, 31 do
  local s = g(r)
  if not p[s] then
    p[s] = "\\" .. r
    q[s] = i("\\%03d", r)
  end
end
local function t(o)
  return h(h(h(o, "\\", "\\\\"), "(%c)%f[0-9]", q), "%c", p)
end
local u = {
  ["and"] = true,
  ["break"] = true,
  ["do"] = true,
  ["else"] = true,
  ["elseif"] = true,
  ["end"] = true,
  ["false"] = true,
  ["for"] = true,
  ["function"] = true,
  ["goto"] = true,
  ["if"] = true,
  ["in"] = true,
  ["local"] = true,
  ["nil"] = true,
  ["not"] = true,
  ["or"] = true,
  ["repeat"] = true,
  ["return"] = true,
  ["then"] = true,
  ["true"] = true,
  ["until"] = true,
  ["while"] = true,
}
local function v(o)
  return type(o) == "string" and not not o:match "^[_%a][_%a%d]*$" and not u[o]
end
local w = math.floor
local function x(l, y)
  return type(l) == "number" and w(l) == l and 1 <= l and l <= y
end
local z = {
  ["number"] = 1,
  ["boolean"] = 2,
  ["string"] = 3,
  ["table"] = 4,
  ["function"] = 5,
  ["userdata"] = 6,
  ["thread"] = 7,
}
local function A(B, C)
  local D, E = type(B), type(C)
  if D == E and (D == "string" or D == "number") then
    return B < C
  end
  local F = z[D] or 100
  local G = z[E] or 100
  return F == G and D < E or F < G
end
local function H(k)
  local I = 1
  while j(k, I) ~= nil do
    I = I + 1
  end
  I = I - 1
  local J, K = {}, 0
  for l in m(k) do
    if not x(l, I) then
      K = K + 1
      J[K] = l
    end
  end
  table.sort(J, A)
  return J, K, I
end
local function L(M, N)
  if type(M) == "table" then
    if N[M] then
      N[M] = N[M] + 1
    else
      N[M] = 1
      for l, O in m(M) do
        L(l, N)
        L(O, N)
      end
      L(getmetatable(M), N)
    end
  end
end
local function P(Q, B, C)
  local R = {}
  local S = #Q
  for r = 1, S do
    R[r] = Q[r]
  end
  R[S + 1] = B
  R[S + 2] = C
  return R
end
local function T(U, V, Q, W)
  if V == nil then
    return nil
  end
  if W[V] then
    return W[V]
  end
  local X = U(V, Q)
  if type(X) == "table" then
    local Y = {}
    W[V] = Y
    local Z
    for l, O in m(X) do
      Z = T(U, l, P(Q, l, inspect.KEY), W)
      if Z ~= nil then
        Y[Z] = T(U, O, P(Q, Z), W)
      end
    end
    local _ = T(U, getmetatable(X), P(Q, inspect.METATABLE), W)
    if type(_) ~= "table" then
      _ = nil
    end
    setmetatable(Y, _)
    X = Y
  end
  return X
end
local function a0(a1, o)
  a1.n = a1.n + 1
  a1[a1.n] = o
end
local a2 = {}
local a3 = { __index = a2 }
local function a4(a5)
  a0(a5.buf, a5.newline .. e(a5.indent, a5.level))
end
function a2:getId(O)
  local a6 = self.ids[O]
  local a7 = self.ids
  if not a6 then
    local a8 = type(O)
    a6 = (a7[a8] or 0) + 1
    a7[O], a7[a8] = a6, a6
  end
  return tostring(a6)
end
function a2:putValue(O)
  local a1 = self.buf
  local a8 = type(O)
  if a8 == "string" then
    a0(a1, n(t(O)))
  elseif
    a8 == "number"
    or a8 == "boolean"
    or a8 == "nil"
    or a8 == "cdata"
    or a8 == "ctype"
  then
    a0(a1, tostring(O))
  elseif a8 == "table" and not self.ids[O] then
    local k = O
    if k == inspect.KEY or k == inspect.METATABLE then
      a0(a1, tostring(k))
    elseif self.level >= self.depth then
      a0(a1, "{...}")
    else
      if self.cycles[k] > 1 then
        a0(a1, i("<%d>", self:getId(k)))
      end
      local J, K, I = H(k)
      a0(a1, "{")
      self.level = self.level + 1
      for r = 1, I + K do
        if r > 1 then
          a0(a1, ",")
        end
        if r <= I then
          a0(a1, " ")
          self:putValue(k[r])
        else
          local l = J[r - I]
          a4(self)
          if v(l) then
            a0(a1, l)
          else
            a0(a1, "[")
            self:putValue(l)
            a0(a1, "]")
          end
          a0(a1, " = ")
          self:putValue(k[l])
        end
      end
      local _ = getmetatable(k)
      if type(_) == "table" then
        if I + K > 0 then
          a0(a1, ",")
        end
        a4(self)
        a0(a1, "<metatable> = ")
        self:putValue(_)
      end
      self.level = self.level - 1
      if K > 0 or type(_) == "table" then
        a4(self)
      elseif I > 0 then
        a0(a1, " ")
      end
      a0(a1, "}")
    end
  else
    a0(a1, i("<%s %d>", a8, self:getId(O)))
  end
end
function inspect.inspect(a9, aa)
  aa = aa or {}
  local ab = aa.depth or math.huge
  local ac = aa.newline or "\n"
  local ad = aa.indent or "  "
  local U = aa.process
  if U then
    a9 = T(U, a9, {}, {})
  end
  local N = {}
  L(a9, N)
  local a5 = setmetatable({
    buf = { n = 0 },
    ids = {},
    cycles = N,
    depth = ab,
    level = 0,
    newline = ac,
    indent = ad,
  }, a3)
  a5:putValue(a9)
  return table.concat(a5.buf)
end
setmetatable(inspect, {
  __call = function(ae, a9, aa)
    return inspect.inspect(a9, aa)
  end,
})
return inspect
