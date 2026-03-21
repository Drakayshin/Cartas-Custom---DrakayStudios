--Neo, El Hechicero Convergente
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	0° Invocar de Modo Especial y Destruir el monstruo que declaro un ataque
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_ATTACK_ANNOUNCE)
	e0:SetRange(LOCATION_HAND)
    e0:SetCountLimit(1,{id,0})
    e0:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e0:SetTarget(s.target)
	e0:SetOperation(s.operation)
    c:RegisterEffect(e0)
    --  1° Buscar 1 monstruo Guerrero o Lanzador de Conjuros
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,{id,1})
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
    -- 	*EFECTO 0°
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local at=Duel.GetAttacker()
	    if at:IsRelateToBattle() then
		Duel.Destroy(at,REASON_EFFECT)
        end
	end
end
    --  *EFECTO 1°
function s.thfilter(c)
	return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER) and c:IsLevel(6) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end