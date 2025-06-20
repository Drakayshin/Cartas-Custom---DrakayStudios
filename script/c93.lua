--Disebia, Consorte Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	 0° y 1° Inegable activación y efectos de cartas "Terranigma"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_INACTIVATE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.effectfilter)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISEFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.effectfilter)
    c:RegisterEffect(e1)
    --	 2° Tu adversario no puede selecciar esta carta para taques
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetValue(aux.imval2)
	c:RegisterEffect(e2)
	--	 3° Tu adversario no puede selecciar esta carta para efectos
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
    -- 	4° y 5° Gana ATK/DEF por cada monstruo de Oscuridad en el Campo
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e5)
    -- 	6° Invocar de Modo Normal 1 monstruo "Terranigma"
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_SUMMON)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetHintTiming(TIMINGS_CHECK_MONSTER|TIMING_MAIN_END|TIMING_DAMAGE_STEP)
	e6:SetCountLimit(1)
	e6:SetTarget(s.sumtg)
	e6:SetOperation(s.sumop)
	c:RegisterEffect(e6)
end
s.listed_series={0x3e7}
	-- 	1° y 2° Inegable activación y efectos de cartas "Terranigma"
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0x3e7) and loc&LOCATION_ONFIELD|LOCATION_HAND~=0
end
    -- 	3° No puede ser seleccionada para taques
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e7) and not c:IsCode(id)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
    -- 	4° y 5° Gana ATK/DEF por cada monstruo de Oscuridad en el Campo
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,0,nil)*500
end
    -- 	6° Invocar de Modo Normal 1 monstruo "Terranigma"
function s.sumfilter(c)
	return c:IsSetCard(0x3e7) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,tp,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end