-- Andrea Martinez
-- CMPM 121 - Solitaire pt2

io.stdout:setvbuf("no")

require "card"
require "grabber"
require "vector"

suitImages = {
  heart = love.graphics.newImage("assets/heartImg.png"),
  spade = love.graphics.newImage("assets/spadeImg.png"),
  diamond = love.graphics.newImage("assets/diamondImg.png"),
  club = love.graphics.newImage("assets/clubImg.jpeg")
}

local suits = {"heart", "spade", "diamond", "club"}
local ranks = {"A" , "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

function love.load()
  love.window.setMode(960, 640)
  love.graphics.setBackgroundColor(0, 0.3, 0.2, 1)
  
  grabber = GrabberClass:new()
  cardTable = {}

  deck = {}
  for _, suit in ipairs(suits) do
    for _, rank in ipairs(ranks) do
      table.insert(deck, cardClass:new(0, 0, suit, rank))
    end
  end
  shuffle(deck)

  deckPosition = Vector(50, 15)
  wastePosition = Vector(250, 15)

  wastePile = {}

  tableauPiles = {}
  local startX = 80
  local gapX = 120
  local y = 150

  for i = 1, 7 do
    tableauPiles[i] = {}
    for j = 1, i do
      local card = table.remove(deck)
      card.position = Vector(startX + (i - 1) * gapX, y + (j - 1) * 30)
      card.faceUp = (j == i)
      table.insert(tableauPiles[i], card)
      table.insert(cardTable, card)
    end
  end
end

function love.update()
  grabber:update()
  checkForMouseMoving()
  
  for _, card in ipairs(cardTable) do
    card:update()
  end
end

function love.draw()
  if #deck > 0 then
    local cardBack = cardTable[1].backImage or love.graphics.newImage("assets/backside.png")
    local scaleX = 80 / cardBack:getWidth()
    local scaleY = 120 / cardBack:getHeight()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(cardBack, deckPosition.x, deckPosition.y, 0, scaleX, scaleY)
  end

  if #wastePile > 0 then
    local topCard = wastePile[#wastePile]
    topCard.position = Vector(wastePosition.x, wastePosition.y)
    topCard:draw()
  end

  for _, card in ipairs(cardTable) do
    if card.state ~= CARD_STATE.GRABBED then
      card:draw()
    end
  end

  if grabber.heldObject then
    grabber.heldObject:draw()
  end

  love.graphics.setColor(1, 1, 1, 1)
  if grabber.currentMousePos then
    love.graphics.print("Mouse: " .. tostring(grabber.currentMousePos.x) .. ", " .. tostring(grabber.currentMousePos.y))
  end
end

function checkForMouseMoving()
  if grabber.currentMousePos == nil then return end
  
  for _, card in ipairs(cardTable) do
    card:checkForMouseOver(grabber)
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    if #deck > 0 then
      if x >= deckPosition.x and x <= deckPosition.x + 80 and
         y >= deckPosition.y and y <= deckPosition.y + 120 then
         
         local card = table.remove(deck)
         card.faceUp = true
         card.position = Vector(wastePosition.x, wastePosition.y)
         table.insert(wastePile, card)
         table.insert(cardTable, card) 
      end
    end
  end
end