--Avance del Sheol Bestial
--Avance del Sheol Bestial
local s,id=GetID()
function s.initial_effect(c)
    -- Activar desde la mano
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	-- Activación
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    -- Reducir ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(s.Fbestialcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
    -- No atacar
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsAttackBelow,2000))
    e4:SetCondition(s.Fbestialcon)
	c:RegisterEffect(e4)
    -- Daño y descarto
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_HAND)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.Fbestialcon)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
end
s.listed_series={0x3e9}
    -- Condicion continua
function s.confilter(c,e,tp)
	return c:IsSetCard(0x3e9) and c:IsType(TYPE_FUSION)
end
function s.Fbestialcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(s.confilter),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
    -- Activar desde la mano
function s.handcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,152),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
    -- Reducción de ATK/DEF
function s.atkfilter(c)
	return c:IsMonster() and c:IsSetCard(0x3e9)
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)*-200
end
    -- Daño y descarte
function s.damfil(c,tp)
	return c:IsControler(tp) and c:IsAbleToGrave()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.damfil,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=eg:FilterSelect(tp,s.damfil,1,1,nil,tp)
	if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,400,REASON_EFFECT)
	end
end