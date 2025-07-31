--Astralaus, El dragón Azabache
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
   	--	*Solo 1 en tu Campo
	c:SetUniqueOnField(1,0,id)
	-- 	*Invocación por Fusión
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION),s.matfilter,s.matfilter2,s.matfilter3)
	--	*Debe ser primero Invocador por Fusion
	c:AddMustFirstBeFusionSummoned()
	-- 	0° Colocar hasta 3 Cartas Magicas/Trampas desde tu Deck
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.settg)
	e0:SetOperation(s.setop)
	c:RegisterEffect(e0)
    -- 	1° Negar y destruir una carta activada por tipo (Monstruo, Mágica, Trampa)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(3,{id,1})
    e1:SetCost(s.negcost)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
	-- *Registro de Tipos
	aux.GlobalCheck(s,function()
		s.type_list={}
		s.type_list[0]=0
		s.type_list[1]=0
		aux.AddValuesReset(function()
				s.type_list[0]=0
				s.type_list[1]=0
			end)
		end)
end
	--	*Filtros de materiales
function s.matfilter(c,fc,sumtype,tp)
	return c:IsOnField() and not c:IsType(TYPE_TOKEN,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsOnField() and not c:IsType(TYPE_TOKEN,fc,sumtype,tp)
end
function s.matfilter3(c,fc,sumtype,tp)
	return c:IsOnField() and not c:IsType(TYPE_TOKEN,fc,sumtype,tp)
end
	--	*EFECTO 1°
function s.setfilter(c)
	return (c:IsSpell() or c:IsTrap()) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SET)
	if #sg>0 then
		Duel.SSet(tp,sg)
	end
end
	--	*EFECTO 2°
function s.cfilter(c,rtype)
	return (not c:IsOnField() or c:IsFaceup()) and c:IsType(rtype) and c:IsAbleToRemoveAsCost()
end
	-- 	*Desterrar el mismo tipo de carta en tu Cementerio
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rtype=(re:GetActiveType()&0x7)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,rtype) end
	local rg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,rtype)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) 
	and Duel.IsChainNegatable(ev) and s.type_list[tp]&re:GetActiveType()==0
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.type_list[tp]=s.type_list[tp]|(re:GetActiveType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP))
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end