--Muisak, Infra-Soberano Bestial
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Solo 1 bajo tu control
    c:SetUniqueOnField(1,0,id)
	-- Materiales de Fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,132,133,130)
    -- Debe ser primero Invocador por Fusion
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
    --Inafectado, con excepcion
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    -- Limitado como Material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(s.funlimit)
	c:RegisterEffect(e2)
    -- Si es Invocado por Fusion, barajea cartas de tu adversario
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
    -- Invocar por Fusion 1 monstruo Barajeando
    local params = {matfilter=Fusion.OnFieldMat(Card.IsAbleToDeck),extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,extratg=s.extratg}
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(Fusion.SummonEffTG(params))
	e4:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e4)
    -- Si deja el Campo
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
end
s.listed_series={0x3e9}
    -- Debe ser primero Invocador por Fusion
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
    -- Inafectado excepto por cartas de arquetipos
function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x3e9)
end
    -- Limitado por Material a Monstruos especificos
function s.funlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x3e9)
end
    -- Barajear por su Invocacion de Fusion todas las demas cartas en el Campo
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
    -- Barajear del Campo y Cementerio
function s.fusfilter(c)
	return not c:IsCode(id)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
end
    -- Invocar si deja el Campo
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        --No pueden Invocar monstruo de la mano, Deck, Cementerio o destierro por este turno
		local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
        e1:SetTargetRange(1,1)
        e1:SetTarget(s.sp2limit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e2:SetDescription(aux.Stringid(id,3))
        e2:SetReset(RESET_PHASE+PHASE_END)
        e2:SetTargetRange(1,1)
        Duel.RegisterEffect(e2,tp)
	end
end
function s.sp2limit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_REMOVED) and c:IsLocation(LOCATION_GRAVE) and c:IsLocation(LOCATION_DECK) and c:IsLocation(LOCATION_HAND)
end