--El Homúnigno
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
     --  Efecto 0: ATK original se convierte en 2300
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_SET_BASE_ATTACK)
	e0:SetCondition(s.atkcon)
	e0:SetValue(2800)
    c:RegisterEffect(e0)
    --  Efecto 1: Invocar de Modo Especial a esta carta desde tu mano o destierro
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --  Efecto 2: añadir a tu mano 1 carta que mencione a "Octagonshiri" desde tu Deck o Cementerio, y después descartar 1 carta  
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY) 
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thsp_tg)
    e2:SetOperation(s.thsp_op)
    c:RegisterEffect(e2)
    local e2a=e2:Clone()
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2a)
end
s.listed_names={100}
    --  *EFECTO 0°
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,100),0,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil)
		or Duel.IsEnvironment(100)
end
    --  *EFECTO 1°
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
    --  *EFECTO 2°
function s.thfilter(c,e,tp,octagonshiri_chk)
    return not c:IsCode(id) and (c:IsMonster() and c:ListsCode(100))
    and (c:IsAbleToHand() or (octagonshiri_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.sphfilter(c)
	return c:IsCode(100) 
end
function s.thsp_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local octagonshiri_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sphfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,octagonshiri_chk) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.thsp_op(e,tp,eg,ep,ev,re,r,rp)
	local octagonshiri_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sphfilter,tp,LOCATION_ONFIELD,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,octagonshiri_chk):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(sc)
			return octagonshiri_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(sc)
			return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,0)
	)
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT,nil)
end