--Teslauric, Gran Levianor Bestial
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Metodo alternativo de Invocacion
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,7,4)
    -- Gana ATK por cada Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(function(_,_c) return (_c:GetOverlayCount())*700 end)
	c:RegisterEffect(e0)
    local e1=e0:Clone()
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1)
    -- Immune a efectos activos de cartas del adversario
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,te) return te:IsActivated() and e:GetOwnerPlayer()~=te:GetOwnerPlayer() end)
	c:RegisterEffect(e2)
    -- Destrucción por Invocación Xyz
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
    e3:SetCountLimit(1,id)
	e3:SetOperation(s.sumsuc)
	c:RegisterEffect(e3)
    -- Destrucción por desacoplo
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
	e4:SetCost(aux.dxmcostgen(2,2,nil))
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
    c:RegisterEffect(e4)
end
s.listed_series={0x3e9}
    -- Si es Invocado por Xyz
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
    -- Destrucción por desacoplo
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local dg=Duel.GetOperatedGroup()
		Duel.BreakEffect()
		local dam=dg:GetSum(Card.GetPreviousAttackOnField)
		Duel.Damage(1-tp,dam,REASON_EFFECT)
        -- Daño reducido del adversario
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		e2:SetTargetRange(1,0)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end