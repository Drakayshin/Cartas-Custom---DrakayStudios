--Evocación Terranigma
--DrakayStudios
Duel.EnableUnofficialRace(RACE_YOKAI)
local s,id=GetID()
function s.initial_effect(c)
	--  0° Negar Invocación y posible Invocacion de "Gran Veleidad Terranigma"
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_SUMMON)
    e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.condition)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
    local e1=e0:Clone()
	e1:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e1)
	local e2=e0:Clone()
	e2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e2)
    --  3° Negar activación de una carta Magica/Trampa o efecto de monstruo
    local e3=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
    --  4° Activar desde la mano con tu adversario tiene 3 o mas cartas en su Campo
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD)>2 end)
	c:RegisterEffect(e4)
end
s.listed_names={99}
s.listed_series={0x3e7}
    --  *Efecto 0°, 1° y 2°
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsLevelBelow(9) and c:IsSetCard(0x3e7) and c:IsAbleToRemoveAsCost()
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsCode(99)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
	local g1=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
	if #g1>4 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=g1:Select(tp,5,5,nil)
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==5 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g2:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end
    --  *Efecto 3°
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e7)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev) and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	g:Merge(eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
	end
end