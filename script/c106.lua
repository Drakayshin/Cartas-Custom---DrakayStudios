--Enardecido Coloso del Ascua
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--Solo 1 bajo tu control
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	-- 	Auxiliar de Invocación de Modo Especial
	aux.AddLavaProcedure(c,3,POS_FACEUP,nil,0,aux.Stringid(id,0))
	-- 	0° Infligir daño durante la Standby Phase
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetCategory(CATEGORY_DAMAGE)
	e0:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1)
	e0:SetCondition(s.damcon)
	e0:SetTarget(s.damtg)
	e0:SetOperation(s.damop)
	c:RegisterEffect(e0)
	-- 	1° LImitación de ataques a este monstruo
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.antarget)
	c:RegisterEffect(e1)
end
	-- 	*EFECTO 0°
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(700)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,700)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
	-- 	*EFECTO 1°
function s.antarget(e,c)
	return c~=e:GetHandler()
end