--Presagio Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	0° Aplicar los siguientes efectos por el resto del duelo
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
end
s.listed_series={0x3e7}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	local c=e:GetHandler()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetTargetRange(1,0)
	e0:SetValue(s.aclimit)
	Duel.RegisterEffect(e0,tp)
	--	1, 2 y 3° Invocar de Modo Normal 1 monstruo "Terranigma" si tu adversario Invoca un monstruo
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.nscon)
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.nscon)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.nscon)
	e3:SetTarget(s.nstg)
	e3:SetOperation(s.nsop)
	Duel.RegisterEffect(e3,tp)
	--	4° Antes de tu robo normal, buscar 1 carta Terranigma en tu Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PREDRAW)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	Duel.RegisterEffect(e4,tp)
    --	5° Ganar LP
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e5:SetCode(EVENT_BATTLE_DAMAGE)
	e5:SetTargetRange(1,0)
	e5:SetCondition(s.reccon)
	e5:SetTarget(s.rectg)
	e5:SetOperation(s.recop)
    Duel.RegisterEffect(e5,tp)
end
	--	Efecto 0° (Limite de activación y efecto)
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(SET_BUJIN)
end
    --	Efecto 1° (1°, 2° y 3° Invocar de Modo Normal)
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.nsfilter(c)
	return c:IsSetCard(0x3e7) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		local sg=g:GetFirst(tp,1,1,nil)
		Duel.Summon(tp,sg,true,nil)
	end
end
	--	Efecto 1° (4° Antes de tu robo normal, buscar 1 carta Terranigma en tu Deck)
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0 and (Duel.GetTurnCount()>1 or Duel.IsDuelType(DUEL_1ST_TURN_DRAW))
end
function s.thfilter(c)
	return c:IsSetCard(0x3e7) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
    --	Efecto 1° (5° Ganar LP igual daño de batalla causado por monstruos "Terranigma")
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsSetCard(0x3e7)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ev)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end