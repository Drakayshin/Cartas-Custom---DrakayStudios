--Surgimiento de Oricalcos
--Surgimiento de Oricalcos
local s,id=GetID()
function s.initial_effect(c)
	--Negar efecto de monstruo/Activar e invocar
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Puedes activar desde la mano
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
s.listed_names={id,48179391}
    --Costo Mitad de LP
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
    --Negar y activar Carta Magica de Campo
function s.filter(c,tp)
	return c:IsCode(48179391,105,125) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.filter1(c,e,tp)
	return c:IsCode(156) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_HAND,0,nil,tp)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
            local tc=g:Select(tp,1,1,nil):GetFirst()
            if tc:IsType(TYPE_FIELD) then
                Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
            else
                Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
                local te=tc:GetActivateEffect()
                local tep=tc:GetControler()
                local cost=te:GetCost()
                if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
            end
        end
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
        if tc then
            Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
        end
    end
end
	-- Activar desde la mano
function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end