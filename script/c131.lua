--Indra, Definitivo Soberano Bestial
--Indra, Definitivo Soberano Bestial
local s,id=GetID()
function s.initial_effect(c)
	--Solo 1 bajo tu control
    c:SetUniqueOnField(1,0,id)
	--Materiales de Fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,130,s.matfilter,s.matfilter2,s.matfilter3)
    --Debe ser Invocador por Fusion
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
    --Inafectado
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
    --No puede ser Tributado
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	--No puede ser material de Fusion/Synchro/Xyz/Link
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e5:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TUPE_LINK))
	c:RegisterEffect(e5)
    --Conversion del daño
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_REVERSE_DAMAGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetValue(s.rev)
	c:RegisterEffect(e6)
    --No recibes daño por batalla que involucre a esta carta
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e7:SetValue(1)
	c:RegisterEffect(e7)
    --Limite de Invocar de Modo Normal y Especial
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetTargetRange(1,0)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e9)
	local e10=e8:Clone()
	e10:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e10)
    --Barajear por su Invocación de Fusión todas las demas cartas en el Campo
    local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,0))
	e11:SetCategory(CATEGORY_TODECK)
	e11:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e11:SetCode(EVENT_SPSUMMON_SUCCESS)
	e11:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e11:SetTarget(s.destg)
	e11:SetOperation(s.desop)
	c:RegisterEffect(e11)
	--ATK/DEF UP
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetCode(EFFECT_UPDATE_ATTACK)
	e12:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e12:SetRange(LOCATION_MZONE)
	e12:SetValue(s.atkval)
	c:RegisterEffect(e12)
	local e13=e12:Clone()
	e13:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e13)
	--Daño de penetracion
	local e14=Effect.CreateEffect(c)
	e14:SetType(EFFECT_TYPE_SINGLE)
	e14:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e14)
	--Cambio de posicion de batalla
	local e15=Effect.CreateEffect(c)
	e15:SetDescription(aux.Stringid(id,1))
	e15:SetCategory(CATEGORY_POSITION)
	e15:SetType(EFFECT_TYPE_QUICK_O)
	e15:SetCode(EVENT_FREE_CHAIN)
	e15:SetRange(LOCATION_MZONE)
	e15:SetCountLimit(2)
	e15:SetTarget(s.destg)
	e15:SetOperation(s.posop)
	c:RegisterEffect(e15)
end
s.listed_series={0x3e9}
    --Materiales del Arquetipo con nombres diferentes
function s.matfilter(c,fc,sumtype,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x3e9,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x3e9,fc,sumtype,tp)
end
function s.matfilter3(c,fc,sumtype,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x3e9,fc,sumtype,tp)
end
    --Inafectado excepto por cartas de arquetipos
function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0x3e9) and te:GetOwner():GetBaseAttack()<=3500 and te:GetOwner():GetBaseAttack()>=0
end
    --Conversion del daño
function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end
    --Barajear por su Invocacion de Fusion todas las demas cartas en el Campo
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
	--ATK/DEFK igual a tus LP
function s.atkval(e,c)
	return math.floor(Duel.GetLP(e:GetHandlerPlayer())/2)
end
	--Cambio de posicion de batalla
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
end
