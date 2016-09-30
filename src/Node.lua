local Node = class("Node",function()
    --return cc.Sprite:create("cell.png")
    return cc.Sprite:createWithSpriteFrameName("cell.png")
end)

function Node:ctor(x, y)
    self:setPos(x, y)
end

function Node:setPos(x, y)
    self.x = x
    self.y = y
    self:setPosition(x * 16 + 24, y * 16 + 294)
end

return Node