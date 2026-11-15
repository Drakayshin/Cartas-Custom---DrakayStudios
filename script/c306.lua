--Virtud de Dragoncella
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: Activar desde la mano
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	--  Efecto 1: Invocar de Modo Especial
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --  Efecto 2: Evitar destrucción
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE) end)
	c:RegisterEffect(e2)
end
s.listed_series={0x133}
    --  *EFECTO 0°
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
    --  *EFECTO 1°
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	return true
end
function s.cfilter(c,e,tp)
	return c:IsMonster() and not c:IsPublic() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp,c:GetAttribute(),c:GetLevel())
end
function s.spfilter(c,e,tp,attr,lv)
	return c:IsSetCard(0x133) and c:IsAttribute(attr) and not c:IsLevel(lv)
		and (c:IsLocation(LOCATION_DECK) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==-1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		e:SetLabel(0)
		return res
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	e:SetLabel(rc:GetAttribute(),rc:GetLevel())
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local attr,lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp,attr,lv):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Return it to the hand during the End Phase
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag) Duel.SendtoHand(ag,nil,REASON_EFFECT) end,nil,0,1,aux.Stringid(id,2))
	end
    Duel.SpecialSummonComplete()
    Duel.BreakEffect()
	Duel.Draw(tp,1,REASON_EFFECT)
end
    --  *EFECTO 2°
function s.repfilter(c,tp)
	return (c:IsRace(RACE_DRAGON) or c:IsSetCard(0x133)) and c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end