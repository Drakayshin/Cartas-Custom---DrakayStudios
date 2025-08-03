--Disebia, Consorte Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	0° Inegable activación y efectos de cartas "Terranigma"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_INACTIVATE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.effectfilter)
	c:RegisterEffect(e0)
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetCode(EFFECT_CANNOT_DISEFFECT)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetValue(s.effectfilter)
    c:RegisterEffect(e0a)
    --	1° Tu adversario no puede selecciar esta carta para taques o por efectos de cartas
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.con)
	e1:SetValue(aux.imval2)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1a:SetValue(aux.tgoval)
	c:RegisterEffect(e1a)
    -- 	2 Gana ATK/DEF por cada monstruo de Oscuridad en el Campo
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2a)
    -- 	3° Invocar de Modo Normal 1 monstruo "Terranigma"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMINGS_CHECK_MONSTER|TIMING_MAIN_END|TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
end
s.listed_series={0x3e7}
	-- 	*EFECTO 0°
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0x3e7) and loc&LOCATION_ONFIELD|LOCATION_HAND~=0
end
    -- 	*EFECTO 1°
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e7) and not c:IsCode(id)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
    -- 	*EFECTP 2°
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,0,nil)*500
end
    -- 	*EFECTO 3°
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