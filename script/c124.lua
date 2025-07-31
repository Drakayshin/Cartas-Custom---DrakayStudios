--Batallador de Oricalcos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	0° Invocar de Modo Especial si es destruida
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_DESTROYED)
    e0:SetCondition(s.oricalcon)
	e0:SetTarget(s.target)
	e0:SetOperation(s.operation)
	e0:SetLabel(0)
	c:RegisterEffect(e0)
    --	1° Gana 500 ATK/DEF x cada Invocacion por su efecto
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.oricalcon)
	e2:SetValue(function(e,c) return e:GetLabelObject():GetLabel()*500 end)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EFFECT_UPDATE_DEFENSE)
    e2a:SetCondition(s.oricalcon)
	c:RegisterEffect(e2a)
	-- 	3° Reduce el daño de batalla que involucre a esta carta a tu adversario
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
end
s.listed_names={48179391}
	--	*Condición general de los siguientes efectos
function s.oricalcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391,125,130),e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
	--	*EFECTO 0°
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		e:SetLabel(e:GetLabel()+1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end