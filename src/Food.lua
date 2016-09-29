local Food = class("Food",function()
    return cc.Sprite:create("dot.png")
end)

function Food:ctor(x, y)
    self:setPos(x, y)
end

function Food:setPos(x, y)
    self.x = x
    self.y = y
    self:setPosition(x * 16 + 24, y * 16 + 294)
end

return Food