--Preseptor de Oricalcos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	-- Activar 1 carta de Campo desde tu Deck
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,0})
	e0:SetCost(Cost.SelfDiscard)
	e0:SetTarget(s.target)
	e0:SetOperation(s.operation)
	c:RegisterEffect(e0)
	-- Tu adversario no seleccina por efectos tus cartas
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.oricalcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
    -- Invocar 1 monstruo que mencione El Sello de Oricalcos
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.oricalcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- Invocar a "Defensor de Oricalcos"
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetTarget(s.target1)
	e4:SetOperation(s.operation1)
	c:RegisterEffect(e4)
end
s.listed_names={48179391,141}
    -- Activar 1 carta de Campo
function s.filter(c,tp)
	return c:IsFieldSpell() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	if not Duel.CheckPhaseActivity() then Duel.RegisterFlagEffect(tp,CARD_MAGICAL_MIDBREAKER,RESET_CHAIN,0,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end
    -- Invocar 1 monstruo que mencione El Sello de Oricalcos
function s.oricalcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391,125,130),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.spfilter(c,e,tp)
	return (c:ListsCode(48179391)) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
	-- Invocar "Defensor de Oricalcos"
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.filter1(c,e,tp)
	return c:IsCode(129) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end