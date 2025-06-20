--Crisaor, El Adalid Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --	Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
    --	0° No puede ser Invocado de Modo Especial
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e0)
	--	1° Invocar por Sacrificio usando 1 monstruo del adversario
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
    c:RegisterEffect(e1)
    --	2° Negar efectos de monstruos que no sean de Oscuridad
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(TIMINGS_CHECK_MONSTER|TIMING_MAIN_END|TIMING_DAMAGE_STEP)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.discon)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
    --	3° Reducir 500 ATK/DEF de todos los monstros que controle tu adversario por cada monstruos de Oscuridad
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetHintTiming(TIMINGS_CHECK_MONSTER|TIMING_MAIN_END|TIMING_DAMAGE_STEP)
    e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.stattg)
	e3:SetOperation(s.statop)
	c:RegisterEffect(e3)
end
s.listed_series={0x3e7}
	--	1° Invocar por Sacrificio usando 1 monstruo del adversario
function s.sumcon(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	local tp=c:GetControler()
	if minc>1 or c:IsLevelBelow(4) or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return false end
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsReleasable),tp,0,LOCATION_MZONE,nil)
	local must_g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil,EFFECT_EXTRA_RELEASE)
	return #g>0 and (#must_g==0 or #(g&must_g)>0) 
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsReleasable),tp,0,LOCATION_MZONE,nil)
	local must_g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil,EFFECT_EXTRA_RELEASE)
	if #must_g>0 then g=g&must_g end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mc=g:Select(tp,1,1,nil):GetFirst()
	if not mc then return false end
	e:SetLabelObject(mc)
	return true
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local mc=e:GetLabelObject()
	c:SetMaterial(mc)
	Duel.Release(mc,REASON_SUMMON|REASON_MATERIAL)
end
    --	2° Negar efectos de monstruos que no sean de Oscuridad con ATK/DEF igual o menor al ATK/DEF de esta carta
function s.filter(c)
	return c:IsSetCard(0x3e7) and c:IsFaceup() and not c:IsCode(id)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_HAND|LOCATION_GRAVE|LOCATION_MZONE|LOCATION_REMOVED)
	e1:SetTarget(s.disable)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.disable(e,c)
	return c~=e:GetHandler() and not c:IsOriginalAttribute(ATTRIBUTE_DARK) and ((c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT))
end
    --	3° Reducir 500 ATK/DEF de todos los monstros que controle tu adversario por cada monstruos de Oscuridad en el Campo
function s.stattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.statop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500*ct)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end