--Mártir de resistencia
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  *Invocación por Péndulo
    Pendulum.AddProcedure(c)
    
    --  EFECTO DE PENDULO

    --  Efecto 0: Colocar 1 "Gran Revolución"
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SET)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.settg)
	e0:SetOperation(s.setop)
	c:RegisterEffect(e0)
    --  Efecto 1: Añadir a tu mano 1 Monstruo Normal, e invocar de Modo Normal
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	c:RegisterEffect(e1)
end
s.listed_names={65396880}
    --  *EFECTO 0°
function s.setfilter(c)
    return c:IsCode(65396880) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) 
    and (c:IsAbleToHand() or c:IsSSetable())
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if sc and Duel.SSet(tp,sc)>0 then
		--  *Puede ser activada este turno si controlas 3 Monstruos Normales
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetCondition(function() return Duel.GetFieldGroupCount(s.actcondfilter,tp,LOCATION_MZONE,0,3,nil) end)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e1)
	end
end
function s.actcondfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsMonster() and c:IsFaceup()
end
    --  *EFECTO 1°
function s.filter1(c)
	return c:IsType(TYPE_NORMAL) and c:IsMonster() and c:IsLevelBelow(4) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand()
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.sumfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsSummonable(true,nil)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if not g:GetFirst():IsLocation(LOCATION_HAND) then return end
		-- *Invocar de Modo Normal
		local sg1=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
		if #sg1>0 then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg2=sg1:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sg2,true,nil)
		end
	end
end