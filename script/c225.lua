--Nacimiento Sunavalon 
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Activar y buscar 1 carta
    local e0=Effect.CreateEffect(c)
    e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	--	1° No puede ser destruida o desterrada por efectos
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.ptcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a:SetCode(EFFECT_CANNOT_REMOVE)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetTargetRange(1,1)
	e1a:SetCondition(s.ptcon)
	e1a:SetTarget(function(e,c,tp,r) return c==e:GetHandler() and r==REASON_EFFECT end)
	c:RegisterEffect(e1a)
	--	2° Reducir a la mitad daño por Batalla
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SUNAVALON),e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil) end)
	e2:SetValue(function(e,re,val,r,rp,rc) return math.floor(val/2) end)
	c:RegisterEffect(e2)
	--	3° Evitar la destrucción por batalla o por efecto de carta una vez por turno
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SUNVINE),e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil) end)
	e3:SetTarget(function(e,c) return c:IsRace(RACE_PLANT) end)
	e3:SetValue(function(e,re,r,rp) return (r&REASON_BATTLE)==0 and 0 or 1 end)
	c:RegisterEffect(e3)
	local e3a=e3:Clone()
	e3a:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3a:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	e3a:SetValue(function(e,re,r,rp) return (r&REASON_EFFECT)==0 and 0 or 1 end)
	c:RegisterEffect(e3a)
end
s.listed_series={SET_SUNAVALON,SET_SUNVINE,0x4157}
    --  *EFECTO 0°
function s.thfilter(c)
	return c:IsSetCard(SET_SUNVINE) or c:IsSetCard(0x4157) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
	--	*EFECTO 1°
function s.filter(c)
	return c:IsFaceup() and c:IsLinkMonster() and c:IsRace(RACE_PLANT)
end
function s.ptcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end