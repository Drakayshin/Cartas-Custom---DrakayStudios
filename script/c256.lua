--Anotherverse Stratios Ex Machina
--DrakayStudios - Asesorado por Gemini
local s,id=GetID()
function s.initial_effect(c)
	--  *Invocación por Fusión
	c:EnableReviveLimit()
    c:AddMustFirstBeFusionSummoned()
	Fusion.AddProcMix(c,true,true,10949074,s.ffilter)
	--  0° Mecánica de Ilusión: No destruye ni es destruido en batalla
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.indes)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--  1° Inmunidad a Magias/Trampas (Efecto Continuo)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,te) return te:IsSpellTrapEffect() end)
	c:RegisterEffect(e1)
	--  2° Modificar ATK + Penetración Doble (Efecto Rápido)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--  3° Negar, Barajar y Auto-Desterrarse (Efecto Rápido)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
s.listed_names={10949074}
    --  *Filtro de Materiales de Fusión
function s.ffilter(c,fc,sumtype,tp)
    return (c:IsType(TYPE_NORMAL,fc,sumtype,tp) and c:IsLevelAbove(6)) 
    or (c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK,fc,sumtype,tp) and c:IsLevel(10))
end
    -- *EFECTO 1°
function s.indes(e,c)
	return c==e:GetHandler() or c==e:GetHandler():GetBattleTarget()
end
    --  *EFECTO 2°
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Seleccionar si subir o bajar
		local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		local val=1000
		if op==1 then val=-1000 end
        --  * Cambio de ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		--  *Otorgar Penetración Doble a ESTA carta (si sigue en campo)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--Penetración con doble daño
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_PIERCE)
            e3:SetValue(DOUBLE_DAMAGE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e3)
		end
	end
end
    --  *EFECTP 3°
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		--Registrar el regreso en la End Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		re:GetHandler():CancelToGrave()
		Duel.SendtoDeck(re:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
    --Operación de Regreso y Destierro en End Phase
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	--Regresa al campo
	if Duel.ReturnToField(c) then
		--Preguntar si quiere activar el efecto de desterrar
		if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) 
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_CARD,0,id)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end