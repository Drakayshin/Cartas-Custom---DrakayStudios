--Ciber Dragón  Zeugma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 1 bajo control
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	-- Condición de Invoación
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(0)
	c:RegisterEffect(e0)
	-- Invocación de Modo Especial
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    -- Gains ATK/DEF igual al monstruo equipado
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():GetEquipGroup():FilterCount(s.eqgfilter,nil)>0 end)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(s.defval)
	c:RegisterEffect(e3)
    -- Equipas tantos monstruos "Ciber Dragón"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
    aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsMonster),s.equipop,e4)
    --                              Efetos por Equipo
    -- Daño por penetración
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PIERCE)
    e5:SetCondition(s.damcon1)
	c:RegisterEffect(e5)
    -- Doble ataque
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_EXTRA_ATTACK)
    e6:SetCondition(s.damcon2)
	e6:SetValue(1)
	c:RegisterEffect(e6)
    -- Destrucción
    local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1)
	e7:SetCondition(s.damcon3)
	e7:SetTarget(s.target)
	e7:SetOperation(s.operation)
	c:RegisterEffect(e7)
    -- Evitar activación de efectos de monstruos
    local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetCode(EFFECT_CANNOT_ACTIVATE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(0,1)
	e8:SetCondition(s.damcon4)
	e8:SetValue(s.monlimit)
	c:RegisterEffect(e8)
    -- Inafectado por efectos de cartas Magica/Trampa
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCode(EFFECT_IMMUNE_EFFECT)
    e9:SetCondition(s.damcon5)
	e9:SetValue(s.efilter)
	c:RegisterEffect(e9)
end
s.listed_series={4243}

    -- Invocar de Modo Especial
function s.spfilter(c)
	return c:IsMonster() and c:IsSetCard(4243) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,e:GetHandler())
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #rg>1 and aux.SelectUnselectGroup(rg,e,tp,2,2,nil,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end
    -- ATK/DEF UP
function s.eqgfilter(c)
	return c:IsFaceup() and c:HasFlagEffect(id)
end
function s.atkval(e,c)
	local g=c:GetEquipGroup():Match(s.eqgfilter,nil):Match(function(c) return c:GetTextAttack()>0 end,nil)
	return g:GetSum(Card.GetTextAttack)
end
function s.defval(e,c)
	local g=c:GetEquipGroup():Match(s.eqgfilter,nil):Match(function(c) return c:GetTextDefense()>0 end,nil)
	return g:GetSum(Card.GetTextDefense)
end
    -- Equipas monstruos "Ciber Dragón"
function s.eqsfilter(c,tp,ec)
	return c:IsFaceup() and c:IsSetCard(4243)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	and Duel.GetMatchingGroupCount(s.eqsfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(s.eqsfilter,tp,LOCATION_GRAVE,0,nil,e:GetHandler())
	if #g==0 then return end
	if #g>ft then return end
	for tc in g:Iter() do
		s.equipop(c,e,tp,tc,true)
	end
	Duel.EquipComplete()
end
function s.equipop(c,e,tp,tc)
	c:EquipByEffectAndLimitRegister(e,tp,tc,id)
end
    -- Efecto 1+ - daño por penetración
function s.damcon1(e)
	local c=e:GetHandler()
	return c:GetEquipCount()>=1
end
    -- Efecto 2+ - Doble ataque
function s.damcon2(e)
	local c=e:GetHandler()
	return c:GetEquipCount()>=2
end
    -- Efecto 3+ - Destrucción
function s.damcon3(e)
	local c=e:GetHandler()
	return c:GetEquipCount()>=3
end
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	Duel.Destroy(sg,REASON_EFFECT)
end
    -- Efecto 4+ - Evitar efectos de monstruos en Battle Phase
function s.damcon4(e)
	local c=e:GetHandler()
	return Duel.IsBattlePhase() and c:GetEquipCount()>=4
end
function s.monlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
    -- Efecto 5+ - Inafectada por Magica/Trampa
function s.damcon5(e)
	local c=e:GetHandler()
	return c:GetEquipCount()>=5
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end