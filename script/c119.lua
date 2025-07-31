--Adikia, Devastador Trascendental
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --	*Solo 1 en tu Campo
    c:SetUniqueOnField(1,0,id)
	--	*Invocación por Fusión
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.fusfilter(TYPE_SYNCHRO),s.fusfilter(TYPE_FUSION),s.fusfilter(TYPE_XYZ))
	--	*Deber ser Invocado por Fusión
	c:AddMustBeFusionSummoned()
    -- 	0° No es afectado por efectos de otras cartas
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e0)
    -- 	1° No puede ser usado como Sacrificio
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e1a)
	-- 	1° (No puede ser usado como Material de Fusión, Sicroní, Xyz o Enlace)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e1b:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e1b)
    -- 	2° ningún jugador recibe daño por batalla que involucre a esta carta
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    -- 	3° Destrucción por su Invocación de Fusión
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
    -- 	4° Negar efectos de monsrtuos que batallen contra esta carta
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
    -- 	5° Infligir daño igual al ATK/DEF (el mas alto) a los LP de tu adversario
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(aux.bdocon)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
end
s.miracle_synchro_fusion=true
function s.fusfilter(typ)
	return  function(c,fc,sumtype,tp)
				return c:IsType(typ,fc,sumtype,tp)
			end
end
	--	*EFECTO 3°
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
   Duel.Destroy(g,REASON_EFFECT)
end
	--	*EFECTO 4°
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
	--	*EFECTO 5°
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