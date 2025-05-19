require "vector"

GrabberClass = {}

function GrabberClass:new()
  local grabber = {}
  local metadata = { __index = GrabberClass }
  setmetatable(grabber, metadata)

  grabber.previousMousePos = nil
  grabber.currentMousePos = nil

  grabber.grabPos = nil
  grabber.heldObject = nil

  grabber.dragOffset = Vector(0, 0)

  return grabber
end

function GrabberClass:update()
  self.currentMousePos = Vector(love.mouse.getX(), love.mouse.getY())

  if love.mouse.isDown(1) and self.grabPos == nil then
    self:grab()
  end

  if not love.mouse.isDown(1) and self.grabPos ~= nil then
    self:release()
  end

  if self.heldObject then
    self:drag()
  end
end

function GrabberClass:grab()
  self.grabPos = self.currentMousePos
  print("GRAB - " .. tostring(self.grabPos))
  for _, card in ipairs(cardTable) do
    if card:isPointInside(self.currentMousePos.x, self.currentMousePos.y) then
      self.heldObject = card
      card:startDrag(self.currentMousePos.x, self.currentMousePos.y)
      self.dragOffset = Vector(self.currentMousePos.x - card.position.x, self.currentMousePos.y - card.position.y)
      break
    end
  end
end

function GrabberClass:release()
  print("RELEASE")

  if self.heldObject == nil then
    self.grabPos = nil
    return
  end

  local isValidReleasePosition = true 
  if not isValidReleasePosition then
    self.heldObject.position = self.grabPos 
  end

  self.heldObject.state = CARD_STATE.IDLE
  self.heldObject = nil
  self.grabPos = nil
end

function GrabberClass:drag()
  if self.heldObject then
    self.heldObject.position = self.currentMousePos - self.dragOffset
  end
end

return GrabberClass