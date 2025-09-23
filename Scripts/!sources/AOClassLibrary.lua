local localeGroup = common.GetAddonRelatedTextGroup(common.GetLocalization(), true) or common.GetAddonRelatedTextGroup("eng")

local tagFontName = userMods.ToWString("fontname")
local tagAlignX = userMods.ToWString("alignx")
local tagFontsize = userMods.ToWString("fontsize")
local tagShadow = userMods.ToWString("shadow")
local tagOutline = userMods.ToWString("outline")
local tagColor = userMods.ToWString("color")


---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------- HELPER FUNCTIONS -----------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
local addonRelatedWidgetGroup = common.GetAddonRelatedWidgetGroup("meter")
function GetDescFromResource(aName)
	return addonRelatedWidgetGroup:GetWidget(aName)
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function RegisterEventHandlers( handlers)
	for event, handler in pairs( handlers ) do
		common.RegisterEventHandler( handler, event)
	end
end
--------------------------------------------------------------------------------
function RegisterReactionHandlers( handlers)
	for event, handler in pairs( handlers ) do
		common.RegisterReactionHandler( handler, event)
	end
end

function UnRegisterEventHandlers( handlers)
	for event, handler in pairs( handlers ) do
		common.UnRegisterEvent( event )
	end
end

function UnRegisterEventHandlerWithParams(anEvent, aHandler, aParamList)
	for _, params in ipairs(aParamList) do 
		common.UnRegisterEventHandler(aHandler, anEvent, params)
	end
end

function RegisterEventHandlerWithParams(anEvent, aHandler, aParamList)
	for _, params in ipairs(aParamList) do 
		common.RegisterEventHandler(aHandler, anEvent, params)
	end
end

---------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- MULTIPLE LOCALIZATIONS SUPPORT ----------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
function GetTextLocalized( strTextName )
	return localeGroup:GetText( strTextName )
end
---------------------------------------------------------------------------------------------------------------------------
------------------------------------------------ GLOBAL VARIABLES, CLASSES ------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
Global( "TWidget", {} )
---------------------------------------------------------------------------------------------------------------------------
function TWidget:CreateNewObject( WidgetName )
	return setmetatable( {
			Widget = WidgetName and mainForm:GetChildUnchecked( WidgetName, true ),
			LastValues = {},
			bDraggable = false
		}, { __index = self } )
end
--------------------------------------------------------------------------------
function TWidget:CreateNewObjectByDesc( WidgetName, Desc, Parent )
	if not Parent then
		LogInfo("ERROR - no parent for create wdg")
	end
	local Widget = Parent.Widget:CreateChildByDesc( Desc )
	Widget:SetName( WidgetName )

	return setmetatable( { Widget = Widget, LastValues = {}, bDraggable = false }, { __index = self } )
end
--------------------------------------------------------------------------------
function TWidget:GetDesc()
	if self.Widget then
		return self.Widget:GetWidgetDesc()
	end
end
--------------------------------------------------------------------------------
function TWidget:GetChildCount()
	if self.Widget then
		return table.getn( self.Widget:GetNamedChildren() ) + 1
	end
	return 0
end
--------------------------------------------------------------------------------
function TWidget:GetChildByName( Name )
	if self.Widget then
		local wtChild = self.Widget:GetChildUnchecked( Name, false )
		
		if wtChild then
			return setmetatable( { Widget = wtChild, LastValues = {}, bDraggable = false }, { __index = self } )
		end
	end
end
--------------------------------------------------------------------------------
function TWidget:GetChildByIndex( Index )
	if self.Widget then
		local wtChildren = self.Widget:GetNamedChildren()
		local wtChild = wtChildren[ Index ]
		
		if wtChild then
			return setmetatable( { Widget = wtChild, LastValues = {}, bDraggable = false }, { __index = self } )
		end
	end
end
--------------------------------------------------------------------------------
function TWidget:Destroy()
	if self.Widget then
		self.Widget:DestroyWidget()
		self = nil
	end
end
--------------------------------------------------------------------------------
function TWidget:DragNDrop( bDraggable, bUseCfg, bLockedToScreenArea, Padding )
	if self.Widget then
		self.bDraggable = bDraggable
		if bUseCfg ~= nil then
			DnD.Init( self.Widget, self.Widget, bUseCfg, bLockedToScreenArea, Padding  )
		else
			DnD.Enable( self.Widget, bDraggable )
		end
	end
end
--------------------------------------------------------------------------------
function TWidget:SetPosition( newX, newY )
	if self.Widget then
		local Placement = {}
		if newX then Placement.posX = math.ceil( newX ) end
		if newY then Placement.posY = math.ceil( newY ) end
		self.Widget:SetPlacementPlain( Placement )
	end
end
--------------------------------------------------------------------------------
function TWidget:SetHighPosition( newX, newY )
	if self.Widget then
		local Placement = {}
		if newX then Placement.highPosX = math.ceil( newX ) end
		if newY then Placement.highPosY = math.ceil( newY ) end
		self.Widget:SetPlacementPlain( Placement )
	end
end
--------------------------------------------------------------------------------
function TWidget:SetWidth( newW )
	if self.Widget then
		if self.LastValues.width == newW then
			return
		end
		self.LastValues.width = newW
		self.Widget:SetPlacementPlain( { sizeX = math.ceil(newW) } )
	end
end
--------------------------------------------------------------------------------
function TWidget:SetHeight( newH )
	if self.Widget then
		if self.LastValues.height == newH then
			return
		end
		self.LastValues.height = newH
		self.Widget:SetPlacementPlain( { sizeY = math.ceil( newH ) } )
	end
end
--------------------------------------------------------------------------------
function TWidget:GetPosition()
	if self.Widget then
		local Placement = self.Widget:GetPlacementPlain()
        return Placement.posX, Placement.posY
	end
end
--------------------------------------------------------------------------------
function TWidget:GetWidth()
	if self.Widget then
		return self.Widget:GetPlacementPlain().sizeX
	end
end
--------------------------------------------------------------------------------
function TWidget:GetHeight()
	if self.Widget then
		return self.Widget:GetPlacementPlain().sizeY
	end
end
--------------------------------------------------------------------------------
function TWidget:SetColor( Color, Alpha )
	if self.Widget then
		if Alpha then
			Color.a = Alpha
		end
		if CompareColor(self.LastValues.color, Color) then
			return
		end
		self.LastValues.color = table.sclone(Color)
		
		self.Widget:SetBackgroundColor( Color )
	end
end
--------------------------------------------------------------------------------
function TWidget:SetTransparency( Alpha )
	if self.Widget then
		local Color = self.Widget:GetBackgroundColor()
		Color.a = Alpha
		self.Widget:SetBackgroundColor( Color )
	end
end
--------------------------------------------------------------------------------
function TWidget:Show()
	if self.Widget and not self.Widget:IsVisible() then
		self.Widget:Show( true )
	end
end
--------------------------------------------------------------------------------
function TWidget:Hide()
	if self.Widget and self.Widget:IsVisible() then
		self.Widget:Show( false )
	end
end
--------------------------------------------------------------------------------
function TWidget:IsVisible()
	if self.Widget then
		return self.Widget:IsVisible()
	end
    return false
end
--------------------------------------------------------------------------------
function TWidget:HideAllChild()
	if self.Widget then
		local wtChildren = self.Widget:GetNamedChildren()
		for _, wtChild in pairs( wtChildren ) do
			wtChild:Show( false )
		end
	end
end

function TWidget:DestroyAllChild()
	if self.Widget then
		local wtChildren = self.Widget:GetNamedChildren()
		for _, wtChild in pairs( wtChildren ) do
			wtChild:DestroyWidget()
		end
	end
end

--------------------------------------------------------------------------------
function TWidget:ShowAllChild()
	if self.Widget then
		local wtChildren = self.Widget:GetNamedChildren()
		for _, wtChild in pairs( wtChildren ) do
			wtChild:Show( true )
		end
	end
end
--------------------------------------------------------------------------------
function TWidget:SetVal(aTag, aValue)
	if self.Widget then
		self.Widget:SetVal(aTag, aValue)
	end
end

function TWidget:SetBackgroundTexture(aTexture)
	if self.Widget then
		self.Widget:SetBackgroundTexture(aTexture)
	end
end

function TWidget:SetTextAttributes(aTagTextValue, aFontName, aFontSize, anAlign, aShadow, anOutline, aColor)
	if self.Widget then
		local attributes = {}
		if aFontName then
			attributes[ tagFontName ] = aFontName
		end	
		if anAlign then
			attributes[ tagAlignX ] = anAlign
		end	
		if aFontSize then
			attributes[ tagFontsize ] = tostring(aFontSize)
		end	
		if aShadow then
			attributes[ tagShadow ] = tostring(aShadow)
		end	
		if anOutline then
			attributes[ tagOutline ] = tostring(anOutline)
		end	
		
		if aColor then
			-- example "0xFFEEDDCC"
			attributes[ tagColor ] = tostring(anOutline)
		end	
		if table.nkeys(attributes) > 0 then
			self.Widget:SetTextAttributes(true, aTagTextValue and userMods.ToWString(aTagTextValue), attributes)
		end
	end
end


function TWidget:ClearScrollList()
	if not self.Widget then
		return
	end
	local containerArr = {}
	for i = 0, self.Widget:GetElementCount() - 1 do
		table.insert(containerArr, self.Widget:At(i))
	end
	self.Widget:RemoveItems()
	for _, containerWdg in ipairs(containerArr) do
		containerWdg:DestroyWidget()
	end
end