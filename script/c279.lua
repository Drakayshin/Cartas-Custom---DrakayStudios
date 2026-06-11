--Molestor
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  0° No puedes Invocar de Modo Especial desde tu Deck Extra
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)return c:IsLocation(LOCATION_EXTRA)end)
	c:RegisterEffect(e0)
	--  *auxiliar de efecto continuo
    aux.addContinuousLizardCheck(c,LOCATION_MZONE)
    --  1° Reflejo de daño por batalla a tu adversario
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetValue(1)
    c:RegisterEffect(e1)
    --  2° Invocar a esta carta de Modo Especial (desde la mano)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
    --  3° Invocar a esta carta de Modo Especial desde el Cementerio o destierro
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
    e3:SetCountLimit(1,{id,0})
    e3:SetCondition(function(_,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,100),tp,LOCATION_ONFIELD,0,1,nil) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--  4° Añadir a tu mano o Invocar de Modo Especial hasta 2 "Molestor"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	local e4a=e4:Clone()
	e4a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4a)
end
s.listed_names={100}
    --  *EFECTO 2°
function s.cfilter(c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
	and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
    --  *EFECTO 3°
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
    and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3900)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_DECKSHF)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
        c:RegisterEffect(e1,true)
	end
end
	--	*EFECTO 4°
function s.adfilter(c,e,tp,octagonshiri_chk)
	return c:IsCode(id) and (c:IsAbleToHand() or (octagonshiri_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local octagonshiri_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,100),tp,LOCATION_ONFIELD,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_DECK,0,1,nil,e,tp,octagonshiri_chk) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local octagonshiri_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,100),tp,LOCATION_ONFIELD,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sc=Duel.SelectMatchingCard(tp,s.adfilter,tp,LOCATION_DECK,0,1,2,nil,e,tp,octagonshiri_chk)
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(sc)
			return octagonshiri_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function(sc)
			return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2)
	)
end