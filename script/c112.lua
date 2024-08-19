--Adikia, Devastador Trascendental
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Solo 1 bajo tu control
    c:SetUniqueOnField(1,0,id)
	-- Invocación por Fusion
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.fusfilter(TYPE_SYNCHRO),s.fusfilter(TYPE_FUSION),s.fusfilter(TYPE_XYZ))
    -- Deber ser Invocado por FUsión
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
    -- Inafectado
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    -- No puede ser Tributado
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
	-- No puede ser Material Fusion/Synchro/Xyz
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e4:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e4)
    -- Cero daño por batalla
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
    -- Destrucción por su Invocación de Fusión
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e6:SetTarget(s.destg)
	e6:SetOperation(s.desop)
	c:RegisterEffect(e6)
    -- Negar efectos por batalla
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_BATTLE_START)
	e7:SetOperation(s.disop)
	c:RegisterEffect(e7)
    -- Daño igual al ATK/DEF mas alto
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_DAMAGE)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetCode(EVENT_BATTLE_DESTROYING)
	e8:SetCountLimit(1,{id,1})
	e8:SetCondition(aux.bdocon)
	e8:SetTarget(s.damtg)
	e8:SetOperation(s.damop)
	c:RegisterEffect(e8)
end
s.miracle_synchro_fusion=true
function s.fusfilter(typ)
	return  function(c,fc,sumtype,tp)
				return c:IsType(typ,fc,sumtype,tp)
			end
end
    -- Inafectado
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
    -- Destruccion por su Invocacion de Fusion
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
   Duel.Destroy(g,REASON_EFFECT)
end
    -- Negar efectos
function s.disop(e,c)
	local tc=e:GetHandler():GetBattleTarget()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
end
    -- Daño igual al ATK/DEF mas alto
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	local dam=math.max(bc:GetTextAttack(),bc:GetTextDefense())
	if chk==0 then return dam>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.max(bc:GetTextAttack(),bc:GetTextDefense())
		if dam<0 then dam=0 end
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end