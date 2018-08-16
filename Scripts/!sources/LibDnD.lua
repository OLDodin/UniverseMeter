--------------------------------------------------------------------------------
-- LibDnD.lua // "Drag&Drop Library" by SLA, version 2011-05-28
-- Help and Updates: http://ui9.ru/forum/develop/topic/950
--------------------------------------------------------------------------------
Global( "DnD", {} )
-- PUBLIC FUNCTIONS
function DnD:Init( ID, wtReacting, wtMovable, fUseCfg, fLockedToScreenArea, Padding )
    if not ID or not wtReacting then return end
    if not DnD.Widgets then
        DnD.Widgets = {}
        DnD.Screen = widgetsSystem:GetPosConverterParams()
        common.RegisterEventHandler( DnD.OnPickAttempt, "EVENT_DND_PICK_ATTEMPT" )
        common.RegisterEventHandler( DnD.OnResolutionChanged, "EVENT_POS_CONVERTER_CHANGED" )
    end
    DnD.Widgets[ ID ] = {}
    DnD.Widgets[ ID ].wtReacting = wtReacting
    DnD.Widgets[ ID ].wtMovable = wtMovable or wtReacting
    DnD.Widgets[ ID ].Enabled = true
    DnD.Widgets[ ID ].fUseCfg = fUseCfg or false
    DnD.Widgets[ ID ].fLockedToScreenArea = fLockedToScreenArea == nil and true or fLockedToScreenArea
    DnD.Widgets[ ID ].Padding = { 0, 0, 0, 0 } -- { T, R, B, L }
    if type( Padding ) == "table" then
        for i = 1, 4 do
            DnD.Widgets[ ID ].Padding[ i ] = Padding[ i ] or 0
        end
    end
    local InitialPlace = DnD.Widgets[ ID ].wtMovable:GetPlacementPlain()
    if fUseCfg then
        local CfgX = GetConfig( "w" .. ID .. "x" )
        local CfgY = GetConfig( "w" .. ID .. "y" )
        if CfgX and CfgY then
            InitialPlace.posX = CfgX
            InitialPlace.posY = CfgY
            DnD.Widgets[ ID ].wtMovable:SetPlacementPlain( DnD.NormalizePlacement( InitialPlace, ID ) )
        end
    end
    DnD.Widgets[ ID ].Initial = {}
    DnD.Widgets[ ID ].Initial.X = InitialPlace.posX
    DnD.Widgets[ ID ].Initial.Y = InitialPlace.posY
    local mt = getmetatable( wtReacting )
    if not mt._Show then
        mt._Show = mt.Show
        mt.Show = function ( self, show )
            self:_Show( show ); DnD.Register( self, show )
        end
    end
    DnD.Register( wtReacting, true )
end
function DnD:Enable( wtWidget, fEnable )
    if not DnD.Widgets then return end
    local ID = DnD.GetWidgetID( wtWidget )
    if ID and DnD.Widgets[ ID ].Enabled ~= fEnable then
        DnD.Widgets[ ID ].Enabled = fEnable
        DnD.Register( wtWidget, fEnable )
    end
end
function DnD:IsDragging()
    return DnD.Dragging and true or false
end
-- FREE BONUS
function GetConfig( name )
    local cfg = userMods.GetGlobalConfigSection( common.GetAddonName() )
    if not name then return cfg end
    return cfg and cfg[ name ]
end
function SetConfig( name, value )
    local cfg = userMods.GetGlobalConfigSection( common.GetAddonName() ) or {}
    if type( name ) == "table" then
        for i, v in pairs( name ) do cfg[ i ] = v end
    elseif name ~= nil then
        cfg[ name ] = value
    end
    userMods.SetGlobalConfigSection( common.GetAddonName(), cfg )
end
-- INTERNAL FUNCTIONS
function DnD.GetWidgetID( wtWidget )
    local WtId = wtWidget:GetInstanceId()
    for ID, W in pairs( DnD.Widgets ) do
        if W.wtReacting:GetInstanceId() == WtId or W.wtMovable:GetInstanceId() == WtId then
            return ID
        end
    end
end
function DnD.Register( wtWidget, fRegister )
    if not DnD.Widgets then return end
    local ID = DnD.GetWidgetID( wtWidget )
    if ID then
        if fRegister and DnD.Widgets[ ID ].Enabled and DnD.Widgets[ ID ].wtReacting:IsVisible() then
            if mission.GetLocalTimeHMS then -- AO 2.0.01+
                mission.DNDRegister( DnD.Widgets[ ID ].wtReacting, ID * DND_CONTAINER_STEP + DND_WIDGET_MOVE, true )
            else -- AO 1.1.02-2.0.00
                mission.DNDRegister( DnD.Widgets[ ID ].wtReacting, DND_WIDGET_MOVE * DND_CONTAINER_STEP + ID, true )
            end
        elseif not fRegister then
            if DnD.Dragging == ID then DnD.OnDragCancelled() end
            mission.DNDUnregister( DnD.Widgets[ ID ].wtReacting )
        end
    end
end
function DnD.NormalizePlacement( Place, ID )
    if Place.posX + Place.sizeX > DnD.Screen.fullVirtualSizeX - DnD.Widgets[ ID ].Padding[ 2 ] then
        Place.posX = math.ceil( DnD.Screen.fullVirtualSizeX ) - Place.sizeX - DnD.Widgets[ ID ].Padding[ 2 ] end
    if Place.posY + Place.sizeY > DnD.Screen.fullVirtualSizeY - DnD.Widgets[ ID ].Padding[ 3 ] then
        Place.posY = math.ceil( DnD.Screen.fullVirtualSizeY ) - Place.sizeY - DnD.Widgets[ ID ].Padding[ 3 ] end
    if Place.posX < DnD.Widgets[ ID ].Padding[ 4 ] then Place.posX = DnD.Widgets[ ID ].Padding[ 4 ] end
    if Place.posY < DnD.Widgets[ ID ].Padding[ 1 ] then Place.posY = DnD.Widgets[ ID ].Padding[ 1 ] end
    return Place
end
if not math.fmod then math.fmod = math.mod end -- Temp fix for < 5.0.2
function DnD.OnPickAttempt( params )
    local Picking
    if mission.GetLocalTimeHMS then -- AO 2.0.01+
        Picking = ( params.srcId - DND_WIDGET_MOVE ) / DND_CONTAINER_STEP
    else -- AO 1.1.02-2.0.00
        Picking = math.fmod( params.srcId, DND_CONTAINER_STEP )
    end
    if DnD.Widgets[ Picking ] and DnD.Widgets[ Picking ].Enabled then
        DnD.Place = DnD.Widgets[ Picking ].wtMovable:GetPlacementPlain()
        DnD.Reset = DnD.Widgets[ Picking ].wtMovable:GetPlacementPlain()
        DnD.Screen = widgetsSystem:GetPosConverterParams()
        DnD.Delta = {}
        DnD.Delta.X = math.ceil( params.posX * DnD.Screen.fullVirtualSizeX / DnD.Screen.realSizeX - DnD.Place.posX )
        DnD.Delta.Y = math.ceil( params.posY * DnD.Screen.fullVirtualSizeY / DnD.Screen.realSizeY - DnD.Place.posY )
        common.SetCursor( "drag" )
        DnD.Dragging = Picking
        common.RegisterEventHandler( DnD.OnDragTo, "EVENT_DND_DRAG_TO" )
        common.RegisterEventHandler( DnD.OnDropAttempt, "EVENT_DND_DROP_ATTEMPT" )
        common.RegisterEventHandler( DnD.OnDragCancelled, "EVENT_DND_DRAG_CANCELLED" )
        if object.GetBuffs then -- AO 2.0.06+ only
            mission.DNDConfirmPickAttempt()
        end
    end
end
function DnD.OnDragTo( params )
    if not DnD.Dragging then return end
    DnD.Place.posX = math.ceil( params.posX * DnD.Screen.fullVirtualSizeX / DnD.Screen.realSizeX - DnD.Delta.X )
    DnD.Place.posY = math.ceil( params.posY * DnD.Screen.fullVirtualSizeY / DnD.Screen.realSizeY - DnD.Delta.Y )
    if DnD.Widgets[ DnD.Dragging ].fLockedToScreenArea then
        DnD.Place = DnD.NormalizePlacement( DnD.Place, DnD.Dragging )
    end
    DnD.Widgets[ DnD.Dragging ].wtMovable:SetPlacementPlain( DnD.Place )
    common.SetCursor( "drag" )
end
function DnD.OnDropAttempt()
    DnD.StopDragging( true )
end
function DnD.OnDragCancelled()
    DnD.StopDragging( false )
end
function DnD.StopDragging( fSuccess )
    if not DnD.Dragging then return end
    common.UnRegisterEventHandler( DnD.OnDragTo, "EVENT_DND_DRAG_TO" )
    common.UnRegisterEventHandler( DnD.OnDropAttempt, "EVENT_DND_DROP_ATTEMPT" )
    common.UnRegisterEventHandler( DnD.OnDragCancelled, "EVENT_DND_DRAG_CANCELLED" )
    if fSuccess then
        mission.DNDConfirmDropAttempt()
        if DnD.Widgets[ DnD.Dragging ].fUseCfg then
            SetConfig( { [ "w"..DnD.Dragging.."x" ] = DnD.Place.posX, [ "w"..DnD.Dragging.."y" ] = DnD.Place.posY } )
        end
        DnD.Widgets[ DnD.Dragging ].Initial.X = DnD.Place.posX
        DnD.Widgets[ DnD.Dragging ].Initial.Y = DnD.Place.posY
    else
        DnD.Widgets[ DnD.Dragging ].wtMovable:SetPlacementPlain( DnD.Reset )
    end
    DnD.Place = nil
    DnD.Reset = nil
    DnD.Delta = nil
    DnD.Dragging = nil
    common.SetCursor( "default" )
end
function DnD.OnResolutionChanged()
    DnD.OnDragCancelled()
    DnD.Screen = widgetsSystem:GetPosConverterParams()
    for ID, W in pairs( DnD.Widgets ) do
        if W.fLockedToScreenArea then
            local InitialPlace = W.wtMovable:GetPlacementPlain()
            InitialPlace.posX = W.Initial.X
            InitialPlace.posY = W.Initial.Y
            W.wtMovable:SetPlacementPlain( DnD.NormalizePlacement( InitialPlace, ID ) )
        end
    end
end
