--Guilletosaurus LV3
--DrakayStudios - Evento 12/09/2026 - Hernán Fernández
local s,id=GetID()
function s.initial_effect(c)
	--  Efecto 0: Atacar directamente
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e0)
	--  Efecto 0: Reducir daño por batalla a la mitad
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e0a:SetCondition(s.rdcon)
	e0a:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
    c:RegisterEffect(e0a)
    --  Efecto 1: Guardar evento de daño por batalla de esta carta
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
    c:RegisterEffect(e1)
    --  Efecto 1: Invocar 1 Guilletosaurus LV5
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCode(EVENT_PHASE|PHASE_END)
	e1a:SetCondition(s.spcon)
	e1a:SetCost(Cost.SelfTribute)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
end
s.listed_names={304}
s.LVnum=3
    --  *EFECTO 0°
function s.rdcon(e)
	local c,tp=e:GetHandler(),e:GetHandlerPlayer()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
    --  *EFECTO 1
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(id)~=0
end
function s.spfilter(c,e,tp)
	return c:IsCode(304) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end