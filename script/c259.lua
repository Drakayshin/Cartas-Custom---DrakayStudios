--Dragón de la Rosa Sangrienta
--Script por DrakayStudios / Asistente Gemini
local s,id=GetID()
function s.initial_effect(c)
	--	*Invocación por Sincronía
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,99,aux.FilterBoolFunction(Card.IsCode,73580471),1,1)
	--	EFECTO 0: INVOCACIÓN SINCRONÍA -> DESTRUIR + DAÑO + ATK
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.descon)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	c:RegisterEffect(e0)
	--	EFECTO 1: DESTRUYE EN BATALLA -> ATAQUE EXTRA + DEBUFF + DAÑO POR PENETRACIÓN
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.atcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--	EFECTO 2: DESTRUIDA O DESTERRADA -> INVOCAR BLACK ROSE DRAGON
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE) -- Se activa si va al cementerio
	e2:SetCondition(s.spcon_grave)
	e2:SetTarget(s.sptg_brd)
	e2:SetOperation(s.spop_brd)
	c:RegisterEffect(e2)
	-- Clonamos el efecto para cuando es Desterrada (EVENT_REMOVE)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	e3:SetCondition(s.spcon_remove)
	c:RegisterEffect(e3)
end
s.listed_names={73580471,CARD_BLACK_ROSE_DRAGON}
--------------------------------------------------------------------------------
-- LÓGICA DEL EFECTO 1 (NUKE)
--------------------------------------------------------------------------------
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
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
--------------------------------------------------------------------------------
-- LÓGICA DEL EFECTO 3 (FLOAT -> BLACK ROSE DRAGON)
--------------------------------------------------------------------------------
function s.spcon_grave(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and rp==1-tp and c:IsPreviousControler(tp)
end
function s.spcon_remove(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
function s.brd_filter(c,e,tp)
	return c:IsCode(CARD_BLACK_ROSE_DRAGON) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.sptg_brd(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.brd_filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop_brd(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.brd_filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	end
end