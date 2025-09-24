--Solarvid Demedra
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Efecto de Unión
    aux.AddUnionProcedure(c,s.unfilter)
    -- 	0° Tratar esta carta como Normal en tu Mano
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetCode(EFFECT_ADD_TYPE)
	e0:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e0)
	local e0a=e0:Clone()
	e0a:SetCode(EFFECT_REMOVE_TYPE)
	e0a:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e0a)
    --  1° No Nopuede ser seleccionado por efectos de cartas de tu adversario
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--  2° Robar 1 carta si destruye a un monstruo por batalla
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
    --  *Filtro de Tipo
function s.unfilter(c)
	return c:IsLinkMonster() and c:IsRace(RACE_PLANT)
end
    --  Efecto 2°
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.IsUnionState(e) and e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end