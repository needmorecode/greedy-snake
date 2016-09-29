require "Cocos2d"
require "Cocos2dConstants"
require "Constants"
local Node = require("Node")
local Food = require("Food")

local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

-- 坐标系
-- 多分辨率
function GameScene:ctor()
    local glview = cc.Director:getInstance():getOpenGLView()
    local screenSize = glview:getFrameSize()
    print("screenSize")
    print(screenSize.width.." "..screenSize.height)
    
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.visibleRect = cc.rect(self.origin.x, self.origin.y, self.visibleSize.width, self.visibleSize.height)
    self.visibleRect.xmid = cc.rectGetMidX(self.visibleRect)
    self.visibleRect.ymid = cc.rectGetMidY(self.visibleRect)
    self.visibleRect.xmax = cc.rectGetMaxX(self.visibleRect)
    self.visibleRect.ymax = cc.rectGetMaxY(self.visibleRect)
    self.visibleRect.xmin = cc.rectGetMinX(self.visibleRect)
    self.visibleRect.ymin = cc.rectGetMinY(self.visibleRect)
    print("rect")
    print(self.origin.x.." "..self.origin.y.." "..self.visibleSize.width.." "..self.visibleSize.height)
    self.schedulerID = nil
    
    -- 初始化
    self.state = STATE_READY
    
    self:addChild(self:createLayer())
end




-- create farm
function GameScene:createLayer()
    local layer = cc.LayerColor:create(cc.c4f(219, 219, 208, 255))
    local widget = ccs.GUIReader:getInstance():widgetFromJsonFile("editor/snake_1.ExportJson")
    local buttonMiddle = widget:getChildByName("Button_Middle")
    local buttonUp = widget:getChildByName("Button_Up")
    local buttonDown = widget:getChildByName("Button_Down")
    local buttonLeft = widget:getChildByName("Button_Left")
    local buttonRight = widget:getChildByName("Button_Right")
    
    local function onTouchLeft(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("touch left")
            if self.direction ~= DIRECTION_RIGHT then
                self.direction = DIRECTION_LEFT
            end
        end
    end

    buttonLeft:addTouchEventListener(onTouchLeft)
    
    local function onTouchRight(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("touch Right")
            if self.direction ~= DIRECTION_LEFT then            
                self.direction = DIRECTION_RIGHT
            end
        end
    end

    buttonRight:addTouchEventListener(onTouchRight)
    
    -- schedule主逻辑
    local function update(delta)
        --if self.state == STATE_PLAY then
        local head = self.body[1]
        local newHeadX = 0
        local newHeadY = 0
        if self.direction == DIRECTION_UP then
            newHeadX = head.x
            newHeadY = head.y + 1   
        elseif self.direction == DIRECTION_DOWN then
            newHeadX = head.x
            newHeadY = head.y - 1
        elseif self.direction == DIRECTION_LEFT then
            newHeadX = head.x - 1
            newHeadY = head.y
        else
            newHeadX = head.x + 1
            newHeadY = head.y
        end

        -- 撞墙判断
        if newHeadX < BORDER_MIN_X or newHeadX > BORDER_MAX_X or newHeadY < BORDER_MIN_Y or newHeadY > BORDER_MAX_Y then
            self.state = STATE_READY
            if (self.schedulerId ~= nil) then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
            end
            return
        end

        -- 撞自己判断
        for i = 1, #self.body - 1 do
            local currNode = self.body[i]
            if currNode.x == newHeadX and currNode.y == newHeadY then
                self.state = STATE_READY
                if (self.schedulerId ~= nil) then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
                end
                return
            end
        end

        -- 吃食物
        if self.food.x == newHeadX and self.food.y == newHeadY then
            local newHead = Node.new(self.food.x, self.food.y)
            --self.food:removeFromParent()
            self.widget:addChild(newHead)
            table.insert(self.body, 1, newHead)
            -- 重置食物位置
            self:resetFood()
            return
        end

        -- 通常情况
        -- 去掉尾部
        local tail = table.remove(self.body, #self.body)
        tail:setPos(newHeadX, newHeadY)
        -- 把新的尾部重新插入头部
        table.insert(self.body, 1, tail)
    end
    
    local function restart()
        if self.body ~= nil then
            for _, node in pairs(self.body) do
                node:removeFromParent()
            end
        end
        if self.food == nil then
            self.food = Food.new(0,0)
            self.widget:addChild(self.food)
        end
        self.direction = DIRECTION_UP
        self.body = {Node.new(18, 18), Node.new(18, 17), Node.new(18, 16), Node.new(18, 15), Node.new(18, 14)}

        -- 绘制蛇的初始位置
        for _, node in pairs(self.body) do
            self.widget:addChild(node)    
        end

        -- 随机一个食物的位置
        self:resetFood()

        self.schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.2, false)
    end 
    
    local function onTouchMiddle(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("touch Middle")
            -- 状态机转换
            if self.state == STATE_READY then
                self.state = STATE_PLAY
                restart()
            elseif self.state == STATE_PLAY then
                self.state = STATE_PAUSE
                if (self.schedulerId ~= nil) then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
                end
            elseif self.state == STATE_PAUSE then
                self.state = STATE_PLAY
                self.schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.2, false)
            end
            print("state change to "..self.state)
        end
    end

    buttonMiddle:addTouchEventListener(onTouchMiddle)
    
    local function onTouchUp(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("touch up")
            if self.direction ~= DIRECTION_DOWN then            
                self.direction = DIRECTION_UP
            end
        end
    end

    buttonUp:addTouchEventListener(onTouchUp)
    
    local function onTouchDown(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("touch Down")
            if self.direction ~= DIRECTION_UP then            
                self.direction = DIRECTION_DOWN
            end
        end
    end

    buttonDown:addTouchEventListener(onTouchDown)
    
    self.widget = widget
    layer:addChild(widget)
    
    local function onTouchWidget(sender, eventType)
        print("touch")
        local pos = sender:getTouchBeganPosition()
        print("%d %d", pos.x, pos.y)
    end

    widget:addTouchEventListener(onTouchWidget)
    

    return layer
end

function GameScene:resetFood()
    -- 随机一个食物的位置
    local candidatePosList = {}
    local excludePosList = {}
    for _, node in pairs(self.body) do
        table.insert(excludePosList, node.x * 100 + node.y, true)        
    end
    for i = BORDER_MIN_X, BORDER_MAX_X do
        for j = BORDER_MIN_Y, BORDER_MAX_Y do 
            table.insert(candidatePosList, i * 100 + j, true)
        end
    end
    for pos, _ in pairs(excludePosList) do
        table.remove(candidatePosList, pos)
    end
    local candidates = {}
    for pos, _ in pairs(candidatePosList) do
        table.insert(candidates, pos)
    end
    local randomIndex = math.random(#candidates)
    local pos = candidates[randomIndex]
    local posY = pos % 100
    local posX = (pos - posY) / 100
    self.food:setPos(posX, posY)
    --self.food = Food.new(posX, posY)
    --self.widget:addChild(self.food)
end





return GameScene
