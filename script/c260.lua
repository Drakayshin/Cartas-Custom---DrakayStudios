--Dragón de la Rosa Sangrienta
--Script por DrakayStudios / Asistente Gemini
local s,id=GetID()
local CARD_BLACK_ROSE_DRAGON=73580471
function s.initial_effect(c)
	--	*Invocación por Sincronía
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,99,aux.FilterBoolFunction(Card.IsSetCard,SET_ROSE_DRAGON),1,1)
	--	0° Debe ser primero Invocado por Sincronía
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	--	1° INVOCACIÓN SINCRONÍA -> DESTRUIR + DAÑO + ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--	2° DESTRUYE EN BATALLA -> ATAQUE EXTRA + DEBUFF + DAÑO POR PENETRACIÓN
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_names={73580471,CARD_BLACK_ROSE_DRAGON}
--------------------------------------------------------------------------------
-- LÓGICA DEL EFECTO 1 (NUKE)
--------------------------------------------------------------------------------
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	g:RemoveCard(e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	g:RemoveCard(c)
	if #g>0 then
		local ct=Duel.Destroy(g,REASON_EFFECT)
		if ct>0 then
			local damage=ct*300
			local real_damage=Duel.Damage(1-tp,damage,REASON_EFFECT)
			if real_damage>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
				Duel.BreakEffect()
				local e_atk=Effect.CreateEffect(c)
				e_atk:SetType(EFFECT_TYPE_SINGLE)
				e_atk:SetCode(EFFECT_UPDATE_ATTACK)
				e_atk:SetValue(real_damage)
				e_atk:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
				c:RegisterEffect(e_atk)
			end
		end
	end
end
--------------------------------------------------------------------------------
-- LÓGICA DEL EFECTO 2 (DOBLE ATAQUE)
--------------------------------------------------------------------------------
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsReason(REASON_BATTLE) and bc:IsReason(REASON_DESTROY)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--	*Atacar de nuevo y causar daño de penetración
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChainAttack()
		c:AddPiercing(RESETS_STANDARD_PHASE_END,c)
	end
	--	*Debuff a oponentes
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e_debuff=Effect.CreateEffect(c)
			e_debuff:SetType(EFFECT_TYPE_SINGLE)
			e_debuff:SetCode(EFFECT_UPDATE_ATTACK)
			e_debuff:SetValue(-600)
			e_debuff:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e_debuff)
			local e_def=e_debuff:Clone()
			e_def:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e_def)
		end
	end
end
