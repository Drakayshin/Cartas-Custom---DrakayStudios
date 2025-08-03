--Catashtri, La Bestia Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	*Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	--	 0° No puede ser Invocado de Modo Normal/Colocado
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--	 1° Invocación de Modo Especial de esta carta
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--	 2° No es afectado por efectos de monstruos que no sean de luz
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,te) return te:IsSpellTrapEffect() or not te:GetHandler():IsAttribute(ATTRIBUTE_LIGHT) end)
	c:RegisterEffect(e2)
	--	 3° Tu adversario no puede Sacrificar esta carta boca arriba
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetValue(s.sumlimit)
	c:RegisterEffect(e3)
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD)
	e3a:SetCode(EFFECT_CANNOT_RELEASE)
	e3a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetTargetRange(0,1)
	e3a:SetTarget(function(e,c) return c==e:GetHandler() end)
	e3a:SetValue(1)
	c:RegisterEffect(e3a)
	--	 4° Niega los efectos de monstruos del adversario que batallen contra esta carta
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	-- 	5° Monstruos "Terranigma" infligen daño de penetración a tu adversario
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_PIERCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3e7))
	c:RegisterEffect(e5)
	-- 	6° Inflige daño de penetración
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e6)
end
s.listed_series={0x3e7}
	-- 	*EFECTO 1°
function s.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsMonster() and (c:IsFaceup() or not c:IsOnField()) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.rescon(sg,e,tp)
	return aux.ChkfMMZ(1)(sg,e,tp,nil) and sg:GetClassCount(Card.GetRace)==#sg,sg:GetClassCount(Card.GetRace)~=#sg
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #rg>2
		and aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
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
	Duel.Release(g,REASON_COST)
    g:DeleteGroup()
end
	-- 	*EFECTO 3°
function s.sumlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer())
end
	-- 	*EFECTO 4°
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x57a0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x57a0000)
		tc:RegisterEffect(e2)
	end
end