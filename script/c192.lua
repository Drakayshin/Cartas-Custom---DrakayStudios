--Anhelo Tearlaments
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	0° Invocar por Fusión
	local e0=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_TEARLAMENTS),Fusion.OnFieldMat(Card.IsAbleToDeck),s.fextra,Fusion.ShuffleMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e0:SetCost(s.cost)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	-- 	1° Buscar una Trampa o monstruo Tearlaments
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_TEARLAMENTS}
	--	*EFECTO 0°
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	--	*No puedes Invocar monstruos del Deck Extra, excepto Monstruos de Fusión
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
	-- Invocar por Fusión barajeando
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_PUBLIC)
end
	-- 	*EFECTO 1°
function s.thfilter(c)
	return c:IsSetCard(SET_TEARLAMENTS) and not c:IsCode(id) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	aux.ToHandOrElse(tc,tp)
end