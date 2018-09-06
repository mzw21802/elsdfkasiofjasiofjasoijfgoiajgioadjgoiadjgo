function UITextEdit:onStyleApply(styleName, styleNode)
  for name,value in pairs(styleNode) do
    if name == 'vertical-scrollbar' then
      addEvent(function()
        self:setVerticalScrollBar(self:getParent():getChildById(value))
      end)
    elseif name == 'horizontal-scrollbar' then
      addEvent(function()
        self:setHorizontalScrollBar(self:getParent():getChildById(value))
      end)
    end
  end
end

function UITextEdit:onMouseWheel(mousePos, mouseWheel)
  if self.verticalScrollBar and self:isMultiline() then
    if mouseWheel == MouseWheelUp then
      self.verticalScrollBar:decrement()
    else
      self.verticalScrollBar:increment()
    end
    return true
  elseif self.horizontalScrollBar then
    if mouseWheel == MouseWheelUp then
      self.horizontalScrollBar:increment()
    else
      self.horizontalScrollBar:decrement()
    end
    return true
  end
end

function UITextEdit:onTextAreaUpdate(virtualOffset, virtualSize, totalSize)
  self:updateScrollBars()
end

function UITextEdit:setVerticalScrollBar(scrollbar)
  self.verticalScrollBar = scrollbar
  self.verticalScrollBar.onValueChange = function(scrollbar, value)
    local virtualOffset = self:getTextVirtualOffset()
    virtualOffset.y = value
    self:setTextVirtualOffset(virtualOffset)
  end
  self:updateScrollBars()
end

function UITextEdit:setHorizontalScrollBar(scrollbar)
  self.horizontalScrollBar = scrollbar
  self.horizontalScrollBar.onValueChange = function(scrollbar, value)
    local virtualOffset = self:getTextVirtualOffset()
    virtualOffset.x = value
    self:setTextVirtualOffset(virtualOffset)
  end
  self:updateScrollBars()
end

function UITextEdit:updateScrollBars()
  local scrollSize = self:getTextTotalSize()
  local scrollWidth = math.max(scrollSize.width - self:getTextVirtualSize().width, 0)
  local scrollHeight = math.max(scrollSize.height - self:getTextVirtualSize().height, 0)

  local scrollbar = self.verticalScrollBar
  if scrollbar then
    scrollbar:setMinimum(0)
    scrollbar:setMaximum(scrollHeight)
    scrollbar:setValue(self:getTextVirtualOffset().y)
  end

  local scrollbar = self.horizontalScrollBar
  if scrollbar then
    scrollbar:setMinimum(0)
    scrollbar:setMaximum(scrollWidth)
    scrollbar:setValue(self:getTextVirtualOffset().x)
  end

end

function UITextEdit:onDoubleClick(mousePosition)
  local text = self:getText()
  local mousePos = self:getCursorPos()+1
  local wordCords = {}
   
  if lastSelection ~= self then
	local label = lastSelection
	if label and label:hasSelection() then
	   label:clearSelection()
    end
  end
	
  if #text <= 0 or not self:isSelectable() then
     return
  end

  local check = string.sub(text, mousePos, mousePos)
  if check == " " or check == "" or check == "\n" then
     return
  end

  for i = 1, #text do
  local ret = string.sub(text, mousePos-i, mousePos-i)
     if ret == " " or ret == "" or ret == "\n" then
        table.insert(wordCords, mousePos-i)
	    break
     end
  end
  for i = 1, #text do
  local ret = string.sub(text, mousePos+i, mousePos+i)
     if ret == " " or ret == "" or ret == "\n" then
  	    table.insert(wordCords, mousePos+i)
	    break
     end
  end
  
  if not table.empty(wordCords) then
     self:setSelection(wordCords[1], wordCords[2]-1)
	 lastSelection = self
  end
end

-- todo: ontext change, focus to cursor