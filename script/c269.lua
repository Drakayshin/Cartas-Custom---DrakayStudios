--Soldado del Brillo Negro - Soldado del Origen
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: Un monstruo "Soldado del Brillo Negro" Invocado por Ritual usando a esta carta, gana efectos.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_BE_MATERIAL)
	e0:SetCondition(s.mtcon)
	e0:SetOperation(s.mtop)
	c:RegisterEffect(e0)
    --  Efecto 1: Invocar de Modo Especial a esta carta desde tu mano
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.selfspcost)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
    c:RegisterEffect(e1)
    --  Efecto 2: Invocar por Ritual 1 Monstruo de Ritual desde tu Deck
	local e2=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,location=LOCATION_DECK|LOCATION_GRAVE,matfilter=s.mfilter})
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(function() return Duel.IsBattlePhase() end)
	c:RegisterEffect(e2)
	--	Efecto 3: Invocar esta carta de Modo Especial si es deterrada durante la proxima Standby Phase
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3a:SetCode(EVENT_REMOVE)
	e3a:SetOperation(s.spreg)
	c:RegisterEffect(e3a)
	local e3b=Effect.CreateEffect(c)
	e3b:SetDescription(aux.Stringid(id,3))
	e3b:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3b:SetRange(LOCATION_REMOVED)
	e3b:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3b:SetCountLimit(1,{id,2})
	e3b:SetCondition(s.spcon)
	e3b:SetTarget(s.sptg)
	e3b:SetOperation(s.spop)
	e3b:SetLabelObject(e3a)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_BLACK_LUSTER_SOLDIER,SET_CHAOS}
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return (r==REASON_RITUAL or r==REASON_FUSION or r==REASON_SYNCHRO) 
	and e:GetHandler():GetReasonCard():IsSetCard(SET_BLACK_LUSTER_SOLDIER)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local rc=c:GetReasonCard()
    if not rc then return end
    --  *No puede ser seleccionada por efectos de tu adversario
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(3061)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    rc:RegisterEffect(e1,true)
    --  *No puede ser destruida por efectos de cartas de tu adversario
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(3060)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indval)
	e2:SetOwnerPlayer(ep)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
    --  *EFECTO 1°
function s.selfspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsRace,1,true,aux.ReleaseCheckMMZ,c,RACE_WARRIOR) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsRace,1,1,true,aux.ReleaseCheckMMZ,c,RACE_WARRIOR)
	Duel.Release(g,REASON_COST)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		--	*OPCIONAL: reducir su Nivel a 4
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD_DISABLE&~RESET_TOFIELD))
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		c:RegisterEffect(e1)
	end
	--	*Barajalo a tu Deck cuando deje el Campo
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3300)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
	c:RegisterEffect(e2)
end
    --  *EFECTO 2°
function s.ritualfil(c)
	return (c:IsSetCard(SET_CHAOS) or c:IsSetCard(SET_BLACK_LUSTER_SOLDIER)) and c:IsRitualMonster()
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
end
	--	*EFECTO 3°
function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(Duel.GetTurnCount())
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,2)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and c:GetFlagEffect(id)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(id)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	--	*Barajalo a tu Deck cuando deje el Campo
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(3900)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetValue(LOCATION_DECKSHF)
	e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
	c:RegisterEffect(e2)
end