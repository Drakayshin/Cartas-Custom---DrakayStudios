--Astralaus, El dragón Azabache
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Materiales
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION),s.matfilter,s.matfilter2,s.matfilter3)
	-- Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	--Debe ser primero Invocador por Fusion
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- Colocar hasta 3 Cartas Magicas/Trampas desde tu Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
    -- Negate the activation of an opponent's card or effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(3,{id,2})
    e2:SetCost(s.negcost)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
	--Registro de Tipos
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
    -- Materiales del Arquetipo con nombres diferentes
function s.matfilter(c,fc,sumtype,tp)
	return c:IsOnField() and not c:IsType(TYPE_TOKEN,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsOnField() and not c:IsType(TYPE_TOKEN,fc,sumtype,tp)
end
function s.matfilter3(c,fc,sumtype,tp)
	return c:IsOnField() and not c:IsType(TYPE_TOKEN,fc,sumtype,tp)
end
    -- Debe ser primero Invocador por Fusion
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
    -- Colocar hasta 3 Cartas Magicas/Trampas desde tu Deck
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
    -- Negar y destruir
function s.cfilter(c,rtype)
	return (not c:IsOnField() or c:IsFaceup()) and c:IsType(rtype) and c:IsAbleToRemoveAsCost()
end
	-- Desterrar el mismo tipo de carta en tu Cementerio
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