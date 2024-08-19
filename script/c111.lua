--Legionario Bestial
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Invocación por Fusión
    c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,69247929,s.ffilter)
    -- Debe ser primero Invocador por Fusion
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- Refleja el daño por batalla
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    -- Daño igual a su defensa actual
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6602300,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	-- Invocar de modo especial a todos sus materiales
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35952884,1))
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.sumcon)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
end
s.listed_series={0x3e9}
	-- Materiales multiples
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_FIEND|RACE_PYRO,fc,sumtype,tp)
end
    -- Debe ser primero Invocador por Fusion
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
    -- Daño por DEF
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetDefense()/2)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Damage(p,e:GetHandler():GetDefense()/2,REASON_EFFECT)
end
    -- Invocar de modo especial a todos sus materiales
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.mgfilter(c,e,tp,fusc)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&0x40008==0x40008 and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if chk==0 then return #mg>0 and ft>=#mg 
		and mg:FilterCount(s.mgfilter,nil,e,tp,c)==#mg end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,#mg,tp,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if #mg<=ft and mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,c)==#mg then
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
