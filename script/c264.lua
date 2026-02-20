--Renacimiento de Rosa Nívea
--DrakayStudios - Asesoria por Gemini
local s,id=GetID()
function s.initial_effect(c)
	--	0° Activar desde la mano
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(function(e) return Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)>0 end)
    c:RegisterEffect(e0)
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	--  1° Invocar Especial y otorgar efectos
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_BLACK_ROSE_DRAGON} --Black Rose Dragon
s.listed_series={SET_ROSE_DRAGON}
    --  *EFECTO 0°
function s.chainfilter(re,tp,cid)
	return not (re:IsMonsterEffect() and re:GetActivateLocation()&(LOCATION_GRAVE|LOCATION_REMOVED)>0)
end
    --Filtro: Sincronía, "Dragón de la Rosa", Invocable
function s.spfilter(c,e,tp)
	return (c:IsCode(CARD_BLACK_ROSE_DRAGON) or (c:IsRace(RACE_PLANT) and c:IsType(TYPE_SYNCHRO))) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		--  *Efecto Ganado 1: Inmune a efectos activos del adversario
		local e1a=Effect.CreateEffect(c)
		e1a:SetDescription(aux.Stringid(id,2))
		e1a:SetType(EFFECT_TYPE_SINGLE)
		e1a:SetCode(EFFECT_IMMUNE_EFFECT)
		e1a:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1a:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() end)
		e1a:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1a)
		--  *Efecto Ganado 2: Efecto Rápido (Destruir y Regresar a la mano)
		local e1b=Effect.CreateEffect(c)
		e1b:SetDescription(aux.Stringid(id,3))
        e1b:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
        e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1b:SetType(EFFECT_TYPE_QUICK_O)
		e1b:SetCode(EVENT_FREE_CHAIN)
		e1b:SetRange(LOCATION_MZONE)
		e1b:SetCountLimit(1)
		e1b:SetTarget(s.thtg)
		e1b:SetOperation(s.thop)
		e1b:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1b)
	end
end
    --  *Target: Monstruo invocado de modo especial del adversario
function s.thfilter(c)
	return c:IsSpecialSummoned() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
    --  *Operación: Regresar a la mano
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end