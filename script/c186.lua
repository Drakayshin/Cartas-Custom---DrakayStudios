--Soldado del Brillo Negro - Enviado del Eclipse
--DrakaStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	*Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	--	*Invocación por Xyz
	Xyz.AddProcedure(c,nil,8,3)
	c:EnableReviveLimit()
    -- 	0° Alt. Invocació por Xyz usando Monstruos Xyz Rango 4
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_XYZ_LEVEL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(function(e,c) return c:IsRank(4) end)
	e0:SetValue(function(e,_,rc) return rc==e:GetHandler() and 8 or 0 end)
	c:RegisterEffect(e0)
    -- 	1° No es afectado por efectos de cartas de tu adversario
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
	c:RegisterEffect(e1)
    -- 	2° Acoplar monstruo destruido por batalla contra esta carta
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.atchtg)
	e2:SetOperation(s.atchop)
	c:RegisterEffect(e2)
    -- 	3° Desterrar 3 cartas (1 en la mano, Campo y Cementerio de tu adversario)
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
    -- 	4° Cambiar Posicion de Batalla de todos los monstruos que controle tu adversario a Posición de Defensa boca abajo
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
	e4:SetCost(Cost.DetachFromSelf(1))
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={0x10cf}
    --	*EFECTO 1°
function s.imfilter(c)
	return c:IsType(TYPE_RITUAL) or c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_XYZ) or c:IsType(TYPE_LINK)
end
function s.imcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(s.imfilter,1,nil)
end
    -- 	*EFECTO 2°
function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return c:IsType(TYPE_XYZ) and bc:IsMonster() and bc:IsFaceup()
		and bc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) end
	Duel.SetTargetCard(bc)
	if bc:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,tp,0)
	end
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsType(TYPE_XYZ) and bc:IsRelateToEffect(e)
		and bc:IsMonster() and bc:IsFaceup() then
		Duel.Overlay(c,bc,true)
	end
end
    -- *EFECTO 3°
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741) 
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	if #g1>0 and #g2>0 and #g3>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg1=g1:RandomSelect(tp,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg2=g2:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		Duel.HintSelection(sg1)
		Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
	end
end
    -- 	*EFECTO 4°
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end