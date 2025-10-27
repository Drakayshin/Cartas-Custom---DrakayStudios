--Anotherverse Arcanister
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Invocación por Fusión
    c:EnableReviveLimit()
    c:AddMustFirstBeFusionSummoned()
    Fusion.AddProcMix(c,true,true,63028558,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PYRO|RACE_THUNDER))
    --  0° No puede ser afectada por efectos de otros monstruos
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetValue(function(e,te) return te:IsMonsterEffect() and te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e0)
	--  1° Ninguno monstruo puede ser destruido durante la batalla contra esta carta
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indestg)
	e1:SetValue(1)
    c:RegisterEffect(e1)
    --  2° Causar daño y negar efectos del monstruo que batalle contra esta carta del adversario
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
    --  3° Causar daño igual al Nivel
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END|TIMING_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.dmcost)
	e3:SetTarget(s.dmth)
	e3:SetOperation(s.dmop)
	c:RegisterEffect(e3)
end
    --  *EFECTO 1°
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
    --  *EFECTO 2°
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsStatus(STATUS_OPPO_BATTLE) and c:IsRelateToBattle() and bc:IsRelateToBattle() and not bc:IsDisabled()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		--  *Causar daño
		Duel.Damage(1-tp,bc:GetAttack(),REASON_EFFECT)
		--  *Negar efectos
		bc:NegateEffects(c)
	end
end
    --  *EFECTO 3°
function s.cfilter(c)
	return c:IsRace(RACE_PYRO|RACE_THUNDER) and c:HasLevel() and c:IsAbleToDeckOrExtraAsCost()
end
function s.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetLevel()*200)
    Duel.SendtoDeck(g,nil,1,REASON_COST)
end
function s.dmth(e,tp,eg,ep,ev,re,r,rp,chk)
	--	*Causar daño igual al Nivel del monstruo usado como coste
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res
	end
	Duel.SetTargetParam(e:GetLabel())
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
    e:SetLabel(0)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	--	*Causar daño igual al Nivel del monstruo usado como coste
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Damage(1-tp,d,REASON_EFFECT,true)
    Duel.RDComplete()
end