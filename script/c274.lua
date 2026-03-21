--Obra Maestre Waruin
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Invocación por Xyz
    c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),6,2,nil,nil,Xyz.InfiniteMats)
    --  0° Acoplar a esta carta 1 Carta Mágica/Trampa Normal al ser activada
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e0:SetCondition(s.attachcon)
	e0:SetOperation(s.attachop)
	c:RegisterEffect(e0)
    --  1° Destruir 1 carta que controle tu adversario
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_MSET|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_MONSTER) end)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--  2° Reducer ATK/DEF por selección de un monstruo que controle tu adversario
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_MSET|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_SPELL) end)
	e2:SetTarget(s.atkdefth)
	e2:SetOperation(s.atkdefop)
	c:RegisterEffect(e2)
    --  3° Negac activación y desterrar
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) return Duel.NegateActivation(ev) end)
	c:RegisterEffect(e3)
end
	--  *EFECTO 0°
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and (rc:IsNormalSpellTrap() or rc:IsQuickPlaySpell()) and rc:IsOnField() and rc:IsCanBeXyzMaterial(e:GetHandler(),tp,REASON_EFFECT)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and rc:IsRelateToEffect(re) and rc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) then
		Duel.Overlay(c,rc)
		if not c:GetOverlayGroup():IsContains(rc) then return end
		rc:CancelToGrave()
	end
end
    --  *EFECTO 1°
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
    --  *EFECTO 2°
function s.filter(c)
	return c:IsFaceup() and c:GetAttack()~=0
end
function s.atkdefth(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.atkdefop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
    --  *EFECTO 3°
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP) and rp==1-tp and re:IsSpellTrapEffect() and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
