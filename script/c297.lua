--Yafragos, Mirmidón de la Fábula
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--  *Invocación por Sincronía
	Synchro.AddProcedure(c,nil,1,99,aux.FilterBoolFunction(Card.IsCode,290),1,1)
	--	Efecto 0: No puede ser destruido por batalla
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
    --  Efecto 1: Invocar de Modo Especial (Tratado como Sincronía)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
    e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={290}
function s.spfilter(c,e,tp,mc)
	if not c:ListsCode(290) then return false end
	local forcedg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_SYNCHRO)
	return #forcedg==0 and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) then
		sc:CompleteProcedure()
        --	*Inafectado hasta el final del próximo turno
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(3110)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(function(e,te) return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,Duel.IsTurnPlayer(tp) and 2 or 1)
        sc:RegisterEffect(e1)
        --  *No puede ser destruido por batalla hasta el final del próximo turno
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,Duel.IsTurnPlayer(tp) and 2 or 1)
		sc:RegisterEffect(e1)
	end
end