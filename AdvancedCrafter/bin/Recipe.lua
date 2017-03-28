component = require "component"
crafting = component.crafting
inventory = component.in

local Recipe = {}

Recipe.mt = {}
setmetatable(Recipe.mt,Recipe)
Recipe.__index = Recipe

function Recipe:new(recipe)
  recipe = recipe or {}
  setmetatable(recipe,self.mt)
  self.mt.__index = self.mt
  return recipe
end

function Recipe.mt:craft()
  
