--Dragón de la Rosa Proserpina
--Script por DrakayStudios / Asistente Gemini
local s,id=GetID()
function s.initial_effect(c)
	--	*LImite de Invocación a 1
	c:SetSPSummonOnce(id)
	--	*Invocación por Sincronía
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,2,2,Synchro.NonTuner(nil),1,99)
	--	0° Invocación: Destrucción Masiva (Mejorada si se usa Nivel 7+)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_DESTROY)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	c:RegisterEffect(e0)
	--  1° Batalla: Segundo Ataque (Trigger)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(aux.bdocon) --Si destruyó un monstruo por batalla
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--  2° Float: Recuperar y Black Rose (Tratado como Sincronía)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.floatcon)
	e2:SetTarget(s.floattg)
	e2:SetOperation(s.floatop)
	c:RegisterEffect(e2)
end
s.listed_names={73580471} --Black Rose Dragon
    --  *EFECTO 0°
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
    --  *EFECTO 1°
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToBattle() and e:GetHandler():CanChainAttack() end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
	c:AddPiercing(RESETS_STANDARD_PHASE_END,c)
end
    --  *EFECTO 2°
function s.floatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsFaceup()
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.thfilter(c)
	return (c:IsRace(RACE_PLANT) or c:IsRace(RACE_DRAGON)) and c:IsLevel(7) and c:IsMonster() and c:IsAbleToHand()
end
function s.brdfilter(c,e,tp)
	return c:IsCode(73580471) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) --Black Rose Dragon
end
function s.floattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.floatop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,g)
			--Parte opcional: Invocar a Black Rose
			if Duel.IsExistingMatchingCard(s.brdfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) 
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=Duel.SelectMatchingCard(tp,s.brdfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
				if sc then
					Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
					sc:CompleteProcedure() --Marca que fue invocado correctamente
				end
			end
		end
	end
end