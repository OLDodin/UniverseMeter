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
			Widget = WidgetName and mainForm:GetChildUnchecked( WidgetName, false ),
			LastValues = {}
		}, { __index = self } )
end
--------------------------------------------------------------------------------
function TWidget:CreateNewObjectByDesc( WidgetName, Desc, Parent )
	local Widget = Parent.Widget:CreateChildByDesc( Desc )
	Widget:SetName( WidgetName )

	return setmetatable( { Widget = Widget, LastValues = {} }, { __index = self } )
end
--------------------------------------------------------------------------------
function TWidget:GetDesc()
	return self.Widget:GetWidgetDesc()
end
--------------------------------------------------------------------------------
function TWidget:GetChildCount()
	return table.getn( self.Widget:GetNamedChildren() ) + 1
end
--------------------------------------------------------------------------------
function TWidget:GetChildByName( Name )
	local wtChild = self.Widget:GetChildUnchecked( Name, false )
	
	if wtChild then
		return setmetatable( { Widget = wtChild, LastValues = {} }, { __index = self } )
	end
end
--------------------------------------------------------------------------------
function TWidget:GetChildByIndex( Index )
	local wtChildren = self.Widget:GetNamedChildren()
	local wtChild = wtChildren[ Index ]
	
	if wtChild then
		return setmetatable( { Widget = wtChild, LastValues = {} }, { __index = self } )
	end
end
--------------------------------------------------------------------------------
function TWidget:Destroy()
	self.Widget:DestroyWidget()
end
--------------------------------------------------------------------------------
function TWidget:DragNDrop( bUseCfg, bLockedToScreenArea, Padding )
	DnD.Init( self.Widget, self.Widget, bUseCfg, bLockedToScreenArea, Padding  )
end
--------------------------------------------------------------------------------
function TWidget:SetVariant( newVariant )
	if self.LastValues.variant == newVariant then
		return
	end
	self.LastValues.variant = newVariant
	self.Widget:SetVariant( newVariant )
end
--------------------------------------------------------------------------------
function TWidget:SetAlign( newAlignX, newAlignY )
	local Placement = {}
	if newAlignX then Placement.alignX = newAlignX end
	if newAlignY then Placement.alignY = newAlignY end
	self.Widget:SetPlacementPlain( Placement )
end
--------------------------------------------------------------------------------
function TWidget:SetPosition( newX, newY )
	local Placement = {}
	if newX then Placement.posX = math.ceil( newX ) end
	if newY then Placement.posY = math.ceil( newY ) end
	self.Widget:SetPlacementPlain( Placement )
end
--------------------------------------------------------------------------------
function TWidget:SetHighPosition( newX, newY )
	local Placement = {}
	if newX then Placement.highPosX = math.ceil( newX ) end
	if newY then Placement.highPosY = math.ceil( newY ) end
	self.Widget:SetPlacementPlain( Placement )
end
--------------------------------------------------------------------------------
function TWidget:SetWidth( newW )
	if self.LastValues.width == newW then
		return
	end
	self.LastValues.width = newW
	self.Widget:SetPlacementPlain( { sizeX = math.ceil(newW) } )
end
--------------------------------------------------------------------------------
function TWidget:SetHeight( newH )
	if self.LastValues.height == newH then
		return
	end
	self.LastValues.height = newH
	self.Widget:SetPlacementPlain( { sizeY = math.ceil( newH ) } )
end
--------------------------------------------------------------------------------
function TWidget:GetPosition()
	local Placement = self.Widget:GetPlacementPlain()
	return Placement.posX, Placement.posY
end
--------------------------------------------------------------------------------
function TWidget:GetWidth()
	return self.Widget:GetPlacementPlain().sizeX
end
--------------------------------------------------------------------------------
function TWidget:GetHeight()
	return self.Widget:GetPlacementPlain().sizeY
end
--------------------------------------------------------------------------------
function TWidget:SetColor( Color, Alpha )
	if Alpha then
		Color.a = Alpha
	end
	if CompareColor(self.LastValues.color, Color) then
		return
	end
	self.LastValues.color = table.sclone(Color)
	
	self.Widget:SetBackgroundColor( Color )
end
--------------------------------------------------------------------------------
function TWidget:SetTransparency( Alpha )
	local Color = self.Widget:GetBackgroundColor()
	Color.a = Alpha
	self.Widget:SetBackgroundColor( Color )
end
--------------------------------------------------------------------------------
function TWidget:Show()
	if self.LastValues.visible then
		return
	end
	self.LastValues.visible = true

	self.Widget:Show( true )
end
--------------------------------------------------------------------------------
function TWidget:Hide()
	if self.LastValues.visible == false then
		return
	end
	self.LastValues.visible = false

	self.Widget:Show( false )
end
--------------------------------------------------------------------------------
function TWidget:IsVisible()
	return self.Widget:IsVisible()
end
--------------------------------------------------------------------------------
function TWidget:DestroyAllChild()
	local wtChildren = self.Widget:GetNamedChildren()
	for _, wtChild in pairs( wtChildren ) do
		wtChild:DestroyWidget()
	end
end
--------------------------------------------------------------------------------
function TWidget:SetVal(aTag, aValue, aCmpVal)
	self.Widget:SetVal(aTag, aValue)
end

function TWidget:SetBackgroundTexture(aTexture)
	self.Widget:SetBackgroundTexture(aTexture)
end

function TWidget:SetTextAttributes(aTagTextValue, aFontName, aFontSize, anAlign, aShadow, anOutline, aColor)
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


function TWidget:ClearScrollList()
	local containerArr = {}
	for i = 0, self.Widget:GetElementCount() - 1 do
		table.insert(containerArr, self.Widget:At(i))
	end
	self.Widget:RemoveItems()
	for _, containerWdg in ipairs(containerArr) do
		containerWdg:DestroyWidget()
	end
end