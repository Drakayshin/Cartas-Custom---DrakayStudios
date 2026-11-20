--Cxyz Dama de Injusticia Helada
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Invocación por Xyz
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,nil,7,3)
	--  Efecto 0: Ganat ATK
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(function(e,c) return c:GetOverlayCount()*500 end)
	c:RegisterEffect(e0)
	--  Efecto 1: Destruir e Infligir daño por efecto
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    --  Efecto 2: Efectos ganados por Material - Inafectado por efectos de monstruos
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,57707471) end)
	e2:SetValue(s.immval)
    c:RegisterEffect(e2)
    --  Efecto 3°: Efectos ganados por Material - Cambiar la Posición de batalla
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,57707471) end)
	e3:SetTarget(function(e,c) return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) end)
	e3:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e3)
end
s.listed_names={57707471}
    --  *EFECTO 1°
function s.desfilter(c)
	return c:IsDefensePos()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	if ct>0 then
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end
    --  *EFECTO 2°
function s.immval(e,te)
	local trig_loc,trig_pos=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_POSITION)
	if not (te:IsMonsterEffect() and te:IsActivated() and trig_loc==LOCATION_MZONE) then return false end
	local tc=te:GetHandler()
	if not Duel.IsChainSolving() or (tc:IsRelateToEffect(te) and tc:IsFaceup() and tc:IsLocation(trig_loc)) then
		return tc:IsDefensePos()
	else
		return trig_pos&POS_DEFENSE>0
	end
end