--Dartz, Regente del Oricalcos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
    -- *Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	-- 	1° Invocar de Modo Especial si controlas un "El Sello de Oricalcos"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA|LOCATION_HAND)
	e0:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.oricalcon)
	c:RegisterEffect(e0)
    -- 	1° No es afectada por efectos de otras cartas
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.oricalcon)
	e1:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e1)
    -- 	2° Monstruos que controle tu adversario pierden 500 ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(s.oricalcon)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	local e2a=e2:Clone()
	e2a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2a)
    --	3° Robar 2 cartas y descartar 1 carta de tu mano
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.oricalcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
    -- 	4° Invocar de Modo Especial hasta 2 monstruo que mencionen "El Sello de Oricalcos"
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCondition(s.oricalcon)
    e4:SetCost(s.cost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--	5° Regresar al Deck si deja el Campo
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e5:SetValue(LOCATION_DECKBOT)
	c:RegisterEffect(e5)
	local e5a=Effect.CreateEffect(c)
	e5a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5a:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1) end)
	c:RegisterEffect(e5a)

	--	EFECTO DE PENDULO
	
    -- Negar y destruir
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_PZONE)
    e6:SetCondition(s.negcon)
	e6:SetTarget(s.negtg)
	e6:SetOperation(s.negop)
	c:RegisterEffect(e6)
    --	*Registro de tipos
	aux.GlobalCheck(s,function()
		s.type_list={}
		s.type_list[0]=0
		s.type_list[1]=0
		aux.AddValuesReset(function()
				s.type_list[0]=0
				s.type_list[1]=0
			end)
		end)
end
s.listed_names={id,48179391,125,130}
	--	*Condigicón general para los siguientes efectos
function s.oricalcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391,125,130),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
    -- 	*EFECTO 3°
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.Draw(p,2,REASON_EFFECT)==2 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
    -- 	*EFECTO 4°
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.spfilter(c,e,tp)
	return (c:ListsCode(48179391)) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,2,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
    --	EFECTO DE PENDULO
	--	*EFECTO 6°
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) 
	and Duel.IsChainNegatable(ev) and s.type_list[tp]&re:GetActiveType()==0
	and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391,125,130),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.type_list[tp]=s.type_list[tp]|(re:GetActiveType()&(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP))
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end