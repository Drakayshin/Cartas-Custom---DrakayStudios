--Radamantis, Espada Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	 Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	--	 0° No puede ser Invocado de Modo Normal/Colocado
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--  1° y 2° Requiere 4 Sacrificios para ser Invocado de Modo Normal/Colocación
	local e1=aux.AddNormalSummonProcedure(c,true,false,4,4,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	local e2=aux.AddNormalSetProcedure(c,true,false,4,4,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
    --  4° La Invocación de esta carta no puede ser negada
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(e5)
    --  5° Desterrar cartas boca abajo
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_SUMMON_SUCCESS)
    e6:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
    e6:SetTarget(s.bshth)
	e6:SetOperation(s.bshop)
    c:RegisterEffect(e6)
    --  6° Efectos Variados
    local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetHintTiming(TIMING_BATTLE_PHASE,TIMING_BATTLE_PHASE)
    e7:SetCost(Cost.PayLP(2000))
    e7:SetCountLimit(1,{id,2})
	e7:SetTarget(s.efftg)
	e7:SetOperation(s.effop)
	c:RegisterEffect(e7)
end
s.listed_series={0x3e7}

function s.tlimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
    --  Efecto 5°
function s.rmfilter(c,p)
	return Duel.IsPlayerCanRemove(p,c) and not c:IsType(TYPE_TOKEN)
end
function s.bshth(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local ct=#g-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ct=ct-1 end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,30459350)
		and ct>0 and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE) end
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.bshop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(1-tp,30459350) then return end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local ct=#g-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,ct,ct,nil,1-tp,POS_FACEDOWN,REASON_RULE)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,1-tp)
	end
end
    --  Efecto 6°
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local b1=true
	local b2=Duel.IsExistingMatchingCard(s.efffilter,tp,0,LOCATION_MZONE,1,nil)
	local tchk,teg=Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE,true)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,3)},{b2,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==2 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE) 
	end
	Duel.SetChainLimit(s.chlimit)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		--  1° Cambia el ATK de un monstruo a 0 y esta carta gana su ATK original
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetCategory(CATEGORY_ATKCHANGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetCondition(s.atkcon)
		e1:SetOperation(s.atkop)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	elseif op==2 then
		--  2° Niega los efectos de 1 monstruo en Posicion de ATK de tu adversario, y esta carta gana sus efectos
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local sc=Duel.SelectMatchingCard(tp,s.efffilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if sc and not sc:IsStatus(STATUS_DISABLED) then
			local code=sc:GetOriginalCode()
			sc:NegateEffects(c,RESETS_STANDARD_PHASE_END)
			c:CopyEffect(code,RESETS_STANDARD_PHASE_END)
		end
	end
	Duel.SetChainLimit(s.chlimit)
end
    -- Efecto 6 (1°) 
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() 
		and bc:GetBaseAttack()~=c:GetAttack() and bc:HasNonZeroAttack()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(bc:GetBaseAttack())
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		bc:RegisterEffect(e1)
	end
end
    -- Efecto 6 (2°)
function s.efffilter(c)
	return c:IsNegatableMonster() and c:IsAttackPos()
end