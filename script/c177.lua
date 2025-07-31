--Martirio Cibernético
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	0° Invocar de Modo Especial 1 Monstruo Fusión "Ciber" desde tu Deck Extra. (Esto es tratado como una Invocación por Fusión)
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e0:SetCondition(s.condition)
    e0:SetCost(s.cost)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
    -- 	1° Ganar LP igual al ATK de un monstruo Máquina de Luz o "Ciber Dragón" en tu Campo
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_GRAVE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
end
s.listed_names={1546123}
s.listed_series={147}
    --	*EFECTO 0°
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<=4000
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,5) and 
	Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>5 end
	Duel.DiscardDeck(tp,5,REASON_COST)
end
function s.filter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(147) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		--	*Aumentar el ATK igual a su ataque original
		local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(tc:GetBaseAttack())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1,true)
		tc:CompleteProcedure()
	end
end
    -- 	*EFECTO 1°
function s.filter1(c)
	return c:HasNonZeroAttack() and (c:IsSetCard(SET_CYBER_DRAGON) or c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE))
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetAttack()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and atk>0 then
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end