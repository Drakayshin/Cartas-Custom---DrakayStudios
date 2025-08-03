--Gran Veleidad Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  *Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	--  0° Solo puede ser Invocado de Modo Especial por el efecto de "Evocación Terranigma"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,se,sp,st) return se:GetHandler():IsCode(81) end)
	c:RegisterEffect(e0)
	-- 	1° Requiere 3 Sacrificios
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,99,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
    --  2° No se pueden activar cartas o efectos por el resto del turno en que esta carta es Invocada por Sacrificio o de Modo Especial
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(s.sumsuc)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a:SetValue(aux.tgoval)
	c:RegisterEffect(e2a)
	--  3° Ganar ATK/DEF por sus Sacrificios
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	c:RegisterEffect(e3)
	--	*EFECTO 3a° give atk effect only when summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_COST)
	e4:SetOperation(s.facechk)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
    -- 5° Desterrar y causar daño
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e5:SetCost(s.sgcost)
	e5:SetTarget(s.sgtg)
	e5:SetOperation(s.sgop)
    c:RegisterEffect(e5)
    Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.listed_names={81}
s.listed_series={0x3e7}
    --  *Efecto 2°
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsTributeSummoned() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return e:GetHandler()~=re:GetHandler()
end
    -- 	*Efecto 3°
	function s.facechk(e,tp,eg,ep,ev,re,r,rp)
		e:GetLabelObject():SetLabel(1)
	end
    -- 	*Efecto 3°(*EFECTO 3a°)
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local atk=0
	local def=0
	for tc in aux.Next(g) do
		local catk=tc:GetTextAttack()
		atk=atk+(catk>=0 and catk or 0)
		local cdef=tc:GetTextDefense()
		def=def+(cdef>=0 and cdef or 0)
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE-RESET_TOFIELD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end
	-- 	*Efecto 5°
function s.chainfilter(re,tp,cid)
	return re:GetHandler():IsSetCard(0x3e7)
end
function s.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,5000) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0
    else Duel.PayLPCost(tp,5000) end
end
function s.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,#g*500)
end
function s.sgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
