--Indra, Definitivo Soberano Bestial
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Solo 1 bajo tu control
    c:SetUniqueOnField(1,0,id)
	-- Materiales de Fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,130,s.matfilter,s.matfilter2,s.matfilter3)
    -- Debe ser Invocador por Fusion
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- No puede ser Tributado
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	-- No puede ser material de Fusion/Synchro/Xyz/Link
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e3)
	-- Limite de Invocar de Modo Normal y Especial
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e5)
    -- Inafectado
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(s.efilter)
	c:RegisterEffect(e6)
    -- Conversion del daño
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_REVERSE_DAMAGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetTargetRange(1,0)
	e7:SetValue(s.rev)
	c:RegisterEffect(e7)
	-- ATK/DEF UP
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_UPDATE_ATTACK)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(s.atkval)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e9)
	-- No recibes daño por batalla que involucre a esta carta
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e10:SetValue(1)
	c:RegisterEffect(e10)
	-- Daño de penetracion
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e11)
    -- Barajear por su Invocación de Fusión todas las demas cartas en el Campo
    local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(id,0))
	e12:SetCategory(CATEGORY_TODECK)
	e12:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e12:SetCode(EVENT_SPSUMMON_SUCCESS)
	e12:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e12:SetTarget(s.destg)
	e12:SetOperation(s.desop)
	c:RegisterEffect(e12)
	-- Cambio de posicion de batalla
	local e13=Effect.CreateEffect(c)
	e13:SetDescription(aux.Stringid(id,1))
	e13:SetCategory(CATEGORY_POSITION)
	e13:SetType(EFFECT_TYPE_QUICK_O)
	e13:SetCode(EVENT_FREE_CHAIN)
	e13:SetRange(LOCATION_MZONE)
	e13:SetCountLimit(2)
	e13:SetTarget(s.destg)
	e13:SetOperation(s.posop)
	c:RegisterEffect(e13)
end
s.listed_series={0x3e9}
    -- Materiales del Arquetipo con nombres diferentes
function s.matfilter(c,fc,sumtype,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x3e9,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x3e9,fc,sumtype,tp)
end
function s.matfilter3(c,fc,sumtype,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x3e9,fc,sumtype,tp)
end
    -- Inafectado excepto por cartas de arquetipos
function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x3e9) and te:GetOwner():GetBaseAttack()<=3500 and te:GetOwner():GetBaseAttack()>=0
end
    -- Conversion del daño
function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end
	-- ATK/DEFK igual a tus LP
function s.atkval(e,c)
	return math.floor(Duel.GetLP(e:GetHandlerPlayer())/2)
end
    -- Barajear por su Invocacion de Fusion todas las demas cartas en el Campo
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
	-- Cambio de posicion de batalla
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
end
