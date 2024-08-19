--Anima del Cerezo Encarnado
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Debe ser Invocado por su propio metodo
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
    -- Modo de Invocacion desde la mano desterrando 1 monstruo
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.hspcond)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- No se puede buscar cartas
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	c:RegisterEffect(e2)
    -- No se puede Invocar monstruo del Main Deck
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	c:RegisterEffect(e3)
end
s.listed_names={14558127}
    -- Modo de Invocacion desde la mano desterrando 1 monstruo
function s.vlfilter(c)
	return c:IsFaceup() and c:IsCode(14558127) and c:IsAbleToRemoveAsCost()
end
function s.hspcond(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.vlfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.vlfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end