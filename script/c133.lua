--Cychreus, Insigne del Oricaustro
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	-- *Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	-- 	0° Invocar de Modo Especial primero por su efecto
	local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
    -- 	1° Buscar 1 carta que mencione "El Sello de Oricalcos" desde tu Deck
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1a)
    -- 	2° Inafectada por monster del Extra deck
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.oricalcon)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	-- 	3° Regresar a la mano 1 monstruo con seleccion
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.oricalcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_names={id,48179391}
    -- 	*EFECTO 0°
function s.spcon(e,c,tp,eg,ep,ev,re,r,rp)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_EXTRA,0)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
    -- 	*EFECTO 1°
function s.filter(c)
	return (c:IsCode(48179391) or c:ListsCode(48179391) and c:IsSpellTrap()) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.oricalcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391,125,130),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
    -- 	*EFECTO 2°
function s.immval(e,te)
	local tc=te:GetOwner()
	return te:IsMonsterEffect() and te:GetOwnerPlayer()==1-e:GetHandlerPlayer()
		and te:IsActiveType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
    -- 	*EFECTO 3°
function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end