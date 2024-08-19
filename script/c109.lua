--Regulus, Supremo Soberano Bestial
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Solo 1 bajo tu control
    c:SetUniqueOnField(1,0,id)
	-- Materiales de Fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3e9),aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO+TYPE_FUSION),aux.FilterBoolFunctionEx(Card.IsType,TYPE_XYZ+TYPE_LINK))
    -- Debe ser primero Invocador por Fusion
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
    -- No puede ser Tributado
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
	-- No puede ser material de Fusion/Synchro/Xyz/Link
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e3)
    -- Immune a efectos activos de cartas del adversario
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(function(e,te) return te:IsActivated() and e:GetOwnerPlayer()~=te:GetOwnerPlayer() end)
	c:RegisterEffect(e4)
    -- Destrucción por su Invocación de Fusión
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
    -- Unico seleccionable de batalla
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e6:SetValue(s.tg)
	c:RegisterEffect(e6)
	-- Unico seleccionable por efectos
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(s.tg)
	e7:SetValue(s.tgval)
	c:RegisterEffect(e7)
end
s.listed_series={0x3e9}
	-- Se puede Invoca con Miracle fusion
s.miracle_synchro_fusion=true
    -- Debe ser primero Invocador por Fusion
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
    -- Destruccion por su Invocacion de Fusion
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
    -- Unico seleccionable de batalla
function s.tg(e,c)
	return c:IsFaceup() and c:GetCode()~=id
end
    -- Unico seleccionable por efectos
function s.tgval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rp==1-e:GetHandlerPlayer()
end
