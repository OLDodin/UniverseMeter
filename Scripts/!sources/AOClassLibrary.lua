---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------- HELPER FUNCTIONS -----------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
function GetTableSize( t )
	if not t then
		return 0
	end
	return table.nkeys(t)
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function LogInfo( ... )
	local arg = {...}
	local argNorm = {}

	for i, value in pairs(arg) do
		if common.IsWString( arg[ i ] ) then
			argNorm[ i ] = arg[ i ]
		else
			argNorm[ i ] = tostring( arg[ i ] )
		end
	end
	common.LogInfo( common.GetAddonName(), unpack( argNorm ) )
end
--------------------------------------------------------------------------------
function LogTable( t, tabstep )
	tabstep = tabstep or 1
	if t == nil then
		LogInfo( "nil (no table)" )
		return
	end
	assert( type( t ) == "table", "Invalid data passed" )
	local TabString = string.rep( "    ", tabstep )
	local isEmpty = true
	for i, v in pairs( t ) do
		if type( v ) == "table" then
			LogInfo( TabString, i, ":" )
			LogTable( v, tabstep + 1 )
		else
			LogInfo( TabString, i, " = ", v )
		end
		isEmpty = false
	end
	if isEmpty then
		LogInfo( TabString, "{} (empty table)" )
	end
end
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

---------------------------------------------------------------------------------------------------------------------------
--------------------------------------------- MULTIPLE LOCALIZATIONS SUPPORT ----------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
function GetGameLocalization()
	local loc = common.GetLocalization()
	if loc == "rus" or loc == "eng" then
		return loc
	end
	return "eng"
end
--------------------------------------------------------------------------------
function GetTextLocalized( strTextName )
	return common.GetAddonRelatedTextGroup( localization ):GetText( strTextName )
end
---------------------------------------------------------------------------------------------------------------------------
------------------------------------------------ GLOBAL VARIABLES, CLASSES ------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
Global( "TWidget", {} )
---------------------------------------------------------------------------------------------------------------------------
function TWidget:CreateNewObject( WidgetName )
	return setmetatable( {
			Widget = WidgetName and mainForm:GetChildUnchecked( WidgetName, true ),
			LastTagValues = {},
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

	return setmetatable( { Widget = Widget, LastTagValues = {}, bDraggable = false }, { __index = self } )
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
			return setmetatable( { Widget = wtChild, bDraggable = false }, { __index = self } )
		end
	end
end
--------------------------------------------------------------------------------
function TWidget:GetChildByIndex( Index )
	if self.Widget then
		local wtChildren = self.Widget:GetNamedChildren()
		local wtChild = wtChildren[ Index ]
		
		if wtChild then
			return setmetatable( { Widget = wtChild, bDraggable = false }, { __index = self } )
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
		local Placement = self.Widget:GetPlacementPlain()
		if newX then Placement.posX = math.ceil( newX ) end
		if newY then Placement.posY = math.ceil( newY ) end
		self.Widget:SetPlacementPlain( Placement )
	end
end
--------------------------------------------------------------------------------
function TWidget:SetWidth( newW )
	if self.Widget then
		local Placement = self.Widget:GetPlacementPlain()
		Placement.sizeX = math.ceil( newW )
		self.Widget:SetPlacementPlain( Placement )
	end
end
--------------------------------------------------------------------------------
function TWidget:SetHeight( newH )
	if self.Widget then
		local Placement = self.Widget:GetPlacementPlain()
		Placement.sizeY = math.ceil( newH )
		self.Widget:SetPlacementPlain( Placement )
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
function TWidget:DnDShow()
	if self.Widget then
		DnD.ShowWdg(self.Widget)
	end
end
--------------------------------------------------------------------------------
function TWidget:DnDHide()
	if self.Widget then
		DnD.HideWdg(self.Widget)
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

function TWidget:SetFormat(aValue)
	if self.Widget then
		self.Widget:SetFormat(aValue)
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


---------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- INITIALIZATION ------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
Global( "localization", "eng" ) -- "eng" is default.
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
