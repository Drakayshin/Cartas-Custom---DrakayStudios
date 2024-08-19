--Formidable Balhamut Bestial
--DrakayStudio
local s,id=GetID()
function s.initial_effect(c)
	-- Solo 1 bajo tu control
    c:SetUniqueOnField(1,0,id)
	-- Materiales de Fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,130,128,s.ffilter,s.matfilter2)
    -- Debe ser primero Invocador por Fusion
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
    -- Indestructible por efectos
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Inafectada por efectos
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
    -- Cambiar posiciones de batalla por su invocacion de Fusion
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
    -- Ataca a todos los monstruos una vez cada uno
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
    -- Ataque en Modo de Defensa
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DEFENSE_ATTACK)
	c:RegisterEffect(e5)
end
s.listed_series={0x3e9}
    -- Debe ser primero Invocador por Fusion
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
    -- Monstruos Material en el Campo
function s.ffilter(c,fc,sumtype,tp)
	return c:IsOnField() and not c:IsType(TYPE_TOKEN,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsOnField() and not c:IsType(TYPE_TOKEN,fc,sumtype,tp)
end
	-- Inafecta por efectos
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
    -- Cambio de Posicion de Batalla Defensa boca abajo
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,e:GetHandler())
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		local og=Duel.GetOperatedGroup()
		local tc=og:GetFirst()
		for tc in aux.Next(og) do
			-- Cannot change their battle positions
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3313)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end