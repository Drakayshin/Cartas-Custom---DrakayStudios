--Arcabuz, Benigno Soberano Bestial
--Arcabuz, Benigno Soberano Bestial
local s,id=GetID()
function s.initial_effect(c)
	--Solo 1 bajo tu control
    c:SetUniqueOnField(1,0,id)
	--Materiales de Fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,{150,25795273},aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO+TYPE_FUSION+TYPE_XYZ))
    --Debe ser primero Invocador por Fusion
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
    --No puede ser Tributado
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	--No Material Fusion/Synchro/Xyz/Link
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e3)
	--Disminuir ATK/DEF Nivel/Rango
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
    --Destierro por su Invocación de Fusión
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e6:SetTarget(s.sgtg)
	e6:SetOperation(s.sgop)
	c:RegisterEffect(e6)
    --Efectos de monstruos Links Negados
    local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_DISABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
	e7:SetTarget(function(e,c) return c:IsType(TYPE_LINK) and (c:IsType(TYPE_EFFECT) or c:IsOriginalType(TYPE_EFFECT)) end)
	c:RegisterEffect(e7)
end
s.listed_series={0x3e9}
	-- Se puede Invoca con Miracle fusion
s.miracle_synchro_fusion=true
    -- Debe ser primero Invocador por Fusion
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
    -- Disminuir ATK/DEF Nivel/Rango
function s.val(e,c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()*-200
	else
		return c:GetLevel()*-200
	end
end
    -- Destierro por su Invocación de Fusión
function s.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.sgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
end