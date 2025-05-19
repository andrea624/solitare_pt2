require "vector"

cardClass = {}

CARD_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
  GRABBED = 2
}

local suitColors = {
  heart = {1, 0, 0},
  diamond = {1, 0, 0},
  spade = {0, 0, 0},
  club = {0, 0, 0}
}

local CARD_WIDTH = 80
local CARD_HEIGHT = 120

local suitImages = {
  heart = love.graphics.newImage("assets/heartImg.png"),
  spade = love.graphics.newImage("assets/spadeImg.png"),
  diamond = love.graphics.newImage("assets/diamondImg.png"),
  club = love.graphics.newImage("assets/clubImg.jpeg")
}

local cardBack = love.graphics.newImage("assets/backside.png")

function cardClass:new(xPos, yPos, suit, value)
  local card = {}
  local metadata = {__index = cardClass}
  setmetatable(card, metadata)

  card.position = Vector(xPos, yPos)
  card.originalPosition = Vector(xPos, yPos)
  card.size = Vector(CARD_WIDTH, CARD_HEIGHT)
  card.state = CARD_STATE.IDLE
  card.faceUp = false
  card.suit = suit or "heart"
  card.value = value or 1
  card.dragOffset = Vector(0, 0)

  return card
end

function cardClass:draw()
  if self.state ~= CARD_STATE.IDLE then
    love.graphics.setColor(0, 0, 0, 0.8)
    local offset = 4 * (self.state == CARD_STATE.GRABBED and 2 or 1)
    love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, 6, 6)
  end


  if self.faceUp then
    -- draws front card
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)

    local img = suitImages[self.suit]
    if img then
      local iconScale = 0.1
      love.graphics.draw(
        img,
        self.position.x + 10,
        self.position.y + 10,
        0,
        iconScale,
        iconScale
      )
    end

    local valueStr = ({[1] = "A", [11] = "J", [12] = "Q", [13] = "K"})[self.value] or tostring(self.value)
    love.graphics.setColor(unpack(suitColors[self.suit] or {0, 0, 0}))
    love.graphics.print(
      valueStr,
      self.position.x + self.size.x - 24,
      self.position.y + 10
    )
  -- else you want the back of the card
  else
    local scaleX = CARD_WIDTH / cardBack:getWidth()
    local scaleY = CARD_HEIGHT / cardBack:getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(cardBack, self.position.x, self.position.y, 0, scaleX, scaleY)
  end

  love.graphics.setColor(1, 1, 1, 1)
end

function cardClass:update()

end

function cardClass:checkForMouseOver(grabber)
  if self.state == CARD_STATE.GRABBED then
    return
  end

  local mousePos = grabber.currentMousePos
  local isMouseOver =
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y

  self.state = isMouseOver and CARD_STATE.MOUSE_OVER or CARD_STATE.IDLE
end

function cardClass:isPointInside(x, y)
  return x >= self.position.x and 
         x <= self.position.x + self.size.x and
         y >= self.position.y and 
         y <= self.position.y + self.size.y
end

function cardClass:startDrag(mouseX, mouseY)
  self.state = CARD_STATE.GRABBED
  self.dragOffset = Vector(mouseX - self.position.x, mouseY - self.position.y)
end

function cardClass:updateDrag(mouseX, mouseY)
  if self.state == CARD_STATE.GRABBED then
    self.position.x = mouseX - self.dragOffset.x
    self.position.y = mouseY - self.dragOffset.y
  end
end

function cardClass:endDrag()
  self.state = CARD_STATE.IDLE
end

function cardClass:flip()
  self.faceUp = not self.faceUp
end

return cardClass