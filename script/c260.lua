--Dragón de la Rosa Proserpina
--Script por DrakayStudios / Asistente Gemini
local s,id=GetID()
function s.initial_effect(c)
	--	*LImite de Invocación a 1
	c:SetSPSummonOnce(id)
	--	*Invocación por Sincronía
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,2,2,Synchro.NonTuner(nil),1,99)
	--	0° Debe ser primero Invocado por Sincronía
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	--	1° Invocación: Destrucción Masiva (Mejorada si se usa Nivel 7+)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--  2° Batalla: Segundo Ataque (Trigger)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon) --Si destruyó un monstruo por batalla
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--  3° Float: Recuperar y Black Rose (Tratado como Sincronía)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.floatcon)
	e3:SetTarget(s.exsptg)
	e3:SetOperation(s.exspop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_BLACK_ROSE_DRAGON} --Black Rose Dragon
    --  *EFECTO 1°
function s.matfilter(c,sc) --Chequeo de Material Nivel 7+
	return c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER,sc,SUMMON_TYPE_SYNCHRO)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mat=c:GetMaterial()
	local upgrade=mat:IsExists(s.matfilter,1,nil,c)
	if chk==0 then 
		if upgrade then
			local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
			return #g>0
		else
			local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
			return #g>0
		end
	end
	if upgrade then
		Duel.SetChainLimit(aux.FALSE) --Opcional: Da poder extra al upgrade, puedes quitarlo si es muy fuerte.
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	else
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mat=c:GetMaterial()
	--Revisamos los materiales de nuevo en la resolución por seguridad
	local upgrade=mat:IsExists(s.matfilter,1,nil,c)
	if upgrade then
		--Destruye todo MENOS Dragones/Plantas que controles
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		local dg=g:Filter(function(tc) return not (tc:IsControler(tp) and s.protfilter(tc)) end, nil)
		if #dg>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	else
		--Destruye solo Magias y Trampas
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.protfilter(c) --Filtro de protección (Plantas o Dragones del controlador)
	return (c:IsRace(RACE_PLANT) or c:IsRace(RACE_DRAGON)) and c:IsFaceup()
end
    --  *EFECTO 2°
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local c=e:GetHandler()
		return e:GetHandler():IsRelateToBattle() and e:GetHandler():CanChainAttack() 
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
	local c=e:GetHandler()
	c:AddPiercing(RESETS_STANDARD_PHASE_END,c)
end
    --  *EFECTO 3°
function s.floatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsFaceup() and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.exspfilter(c,e,tp,mc)
	return (c:IsCode(CARD_BLACK_ROSE_DRAGON) or (c:IsSetCard(SET_ROSE_DRAGON) and c:IsType(TYPE_SYNCHRO))) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.exsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.exspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end