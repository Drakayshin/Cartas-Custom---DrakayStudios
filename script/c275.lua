--Uranus, El Prohibido de los sirvientes
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
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_MONSTER) end)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--  2° Colocar 1 Carta Magica/ de Trampa destruida
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_DESTROY)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_SPELL) end)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    local e2a=e2:Clone()
	e2a:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2a)
    --  3° Activar 1 Magica/Trampa Normal
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_MSET|TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,{id,3})
    e3:SetCost(Cost.AND(Cost.DetachFromSelf(1),s.effcost))
    e3:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP) end)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
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
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then 
		--  *Barajalo al Deck si deja el Campo
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3900)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKSHF)
		tc:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
    --  *EFECTO 2°
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tc:GetPreviousControler(),LOCATION_SZONE)>0 
	and #eg==1 and tc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and tc:IsType(TYPE_SPELL|TYPE_TRAP) and tc:IsPreviousControler(tp)
		and tc:IsSSetable() end
	tc:CreateEffectRelation(e)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		Duel.SSet(tp,tc)
	end
end
    --  *EFECTO 3°
function s.copyfilter(c)
	return c:IsNormalSpellTrap() and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(false,true,true)~=nil
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then
		--Storing the legal group before detaching due to rulings (Q&A #16286)
		local g=Duel.GetMatchingGroup(s.copyfilter,tp,LOCATION_DECK,0,nil)
		e:SetLabelObject(g)
		return #g>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=e:GetLabelObject():Select(tp,1,1,nil):GetFirst()
	e:SetLabelObject(sc)
	Duel.SendtoGrave(sc,REASON_COST)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te,ceg,cep,cev,cre,cr,crp=table.unpack(e:GetLabelObject())
		return te and te:GetTarget() and te:GetTarget()(e,tp,ceg,cep,cev,cre,cr,crp,chk,chkc)
	end
	if chk==0 then
		local res=e:GetLabel()==-100
		e:SetLabel(0)
		return res and e:GetHandler():GetFlagEffect(id)==0 
	end
	local sc=e:GetLabelObject()
	local te,ceg,cep,cev,cre,cr,crp=sc:CheckActivateEffect(true,true,true)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		e:SetProperty(te:GetProperty())
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
		Duel.ClearOperationInfo(0)
	end
	e:SetLabel(0)
	e:SetLabelObject({te,ceg,cep,cev,cre,cr,crp})
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    --  *No puedes usar este efecto hasta tu siguiente turno
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local reset=RESET_SELF_TURN
		if Duel.IsTurnPlayer(tp) then reset=RESET_OPPO_TURN end
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END|reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
	end
	local te,ceg,cep,cev,cre,cr,crp=table.unpack(e:GetLabelObject())
	if not te then return end
	local op=te:GetOperation()
	if op then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		op(e,tp,ceg,cep,cev,cre,cr,crp)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end