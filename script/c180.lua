--Leviatán, Supremo Ídolo de Oricalcos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Invocación por Péndulo
	Pendulum.AddProcedure(c)
    -- 1 invocación de esta carta por turno
	c:SetSPSummonOnce(id)
	-- Busqueda
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,1})
	e0:SetCost(s.thcost)
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
	-- Limite de revivir
	c:EnableUnsummonable()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_REVIVE_LIMIT)
	e1:SetCondition(function(e) return not e:GetHandler():IsLocation(LOCATION_HAND) end)
	c:RegisterEffect(e1)
	-- Condición de Invocación
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	-- Colocar en zona de Péndulo
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
    -- Inafectada
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.oricalcon)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
    -- Sin Invocaciones Normales o Especiales
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
    e5:SetCondition(s.oricalcon)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e6)
    -- ATK/DEF UP
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
    e7:SetCondition(s.oricalcon)
	e7:SetValue(s.val)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e8)

    -- Efecto Péndulo

	-- Regresar esta carta a tu mano con otra que controles
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,0))
	e9:SetCategory(CATEGORY_TOHAND)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e9:SetRange(LOCATION_PZONE)
	e9:SetCountLimit(1,{id,2})
	e9:SetTarget(s.sthtg)
	e9:SetOperation(s.sthop)
	c:RegisterEffect(e9)

	-- Invocar y cambiar ataque
	local e10=Effect.CreateEffect(c)
	e10:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e10:SetCode(EVENT_ATTACK_ANNOUNCE)
	e10:SetRange(LOCATION_PZONE)
    e10:SetCountLimit(1,{id,3})
	e10:SetCondition(s.sumcon)
	e10:SetTarget(s.sptg)
	e10:SetOperation(s.spop)
	c:RegisterEffect(e10)
end
s.listed_names={48179391,120,125,130}

    -- Busqueda
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.thfilter(c)
	return ((c:ListsCode(48179391) and c:IsMonster() and not c:IsCode(id)) or c:IsCode(48179391,120,125,130))
		 and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,3,nil)
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
	-- Condición de Invocación
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL or ((se:GetHandler():ListsCode(48179391) 
	and Duel.GetLP(e:GetHandlerPlayer())>=10000 and e:GetHandler():IsLocation(LOCATION_HAND)))
end
	-- Colocar en zona de Péndulo
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and rp==1-tp
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
    -- Inafectada por carta Mágica/Trampa
function s.oricalcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391,125,130),e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
    -- ATK/DEF UP
function s.val(e,c)
	return Duel.GetLP(c:GetControler(1,e))
end
	-- Regresar cartas a tu mano
function s.sthfilter(c)
	return c:IsFaceup() and c:ListsCode(48179391) and c:IsAbleToHand()
end
function s.sthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and chkc~=c and s.thfilter(chkc) end
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingTarget(s.sthfilter,tp,LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.sthfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g+c,2,0,0)
end
function s.sthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(Group.FromCards(c,tc),nil,REASON_EFFECT)
	end
end
    -- Invocar y cambiar ataque
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.filter(c,e,tp,lsc,rsc)
	local lv=c:GetLevel()
	return lv>lsc and lv<rsc and (c:ListsCode(48179391)) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not lc or not rc then return false end
	local lsc=lc:GetLeftScale()
	local rsc=rc:GetRightScale()
	if lsc>rsc then lsc,rsc=rsc,lsc end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp,lsc,rsc) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not lc or not rc then return end
	local lsc=lc:GetLeftScale()
	local rsc=rc:GetRightScale()
	if lsc>rsc then lsc,rsc=rsc,lsc end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp,lsc,rsc):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.ChangeAttackTarget(tc)
	end
end
