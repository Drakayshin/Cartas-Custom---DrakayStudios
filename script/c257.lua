--Anotherverse Stellivorus
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	*Invocacioón por Fusión
	c:EnableReviveLimit()
	c:AddMustFirstBeFusionSummoned()
	Fusion.AddProcMixRep(c,true,true,s.ffilter,2,2,86893702)
	--	0° Inafectada por efectos activos que no la seleccionen del adversario
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.immval)
	c:RegisterEffect(e0)
	--	1° Ninguno monstruo puede ser destruido durante la batalla contra esta carta
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c==e:GetHandler() or c==e:GetHandler():GetBattleTarget() end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--	2° Tu adversario no puede activar cartas o efectos durante la Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function() return Duel.IsBattlePhase() end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 	3° Efecto Rápido: Negar, Equipar, Aumentar ATK
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,0}) -- Límite de uso por turno (ajustar si es necesario)
    e3:SetTarget(s.negth)
    e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	aux.AddEREquipLimit(c,nil,aux.NOT(aux.FilterBoolFunction(Card.IsType,TYPE_TOKEN)),s.equipop,e3,nil)
	--	4° Efecto de Robo de Control
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
	--	5° Efecto de Reemplazo por Pérdida
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) -- Efecto de Disparo Opcional
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_REMOVE) -- Si es desterrada
	e5:SetCountLimit(1,{id,2})
    e5:SetTarget(s.spth)
    e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	local e5a=e5:Clone()
	e5a:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e5a)
end
s.listed_names={86893702}
	--	*Filtro de Materiales de Fusión
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:GetRace(fc,sumtype,tp)~=0 and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetRace(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,attr,fc,sumtype,tp)
	return c:IsRace(attr,fc,sumtype,tp) and not c:IsHasEffect(511002961)
end
	--	*EFECTO 0°
function s.immval(e,re)
	if not (re:IsActivated() and e:GetOwnerPlayer()==1-re:GetOwnerPlayer()) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not (tg and tg:IsContains(e:GetHandler()))
end
	--	*EFECTO 3 - Seleccionar un monstruo de efecto en el Campo
function s.negatefilter(c)
    return c:IsType(TYPE_EFFECT) and c:IsNegatableMonster() and not c:IsCode(id)
end
function s.negth(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.negatefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.negatefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.negatefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e)) then return end
	tc:NegateEffects(c)
	--	*Si el efecto anterior se completa, puedes activar este
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		s.equipop(c,e,tp,tc)
	end
end
function s.equipop(c,e,tp,tc)
	--	*Verifica que el monstruo pueda ser equipado
	if not c:EquipByEffectAndLimitRegister(e,tp,tc) then return end
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
end
	--	*EFECTO 4° - Condición: Al final del Damage Step, si esta carta batalló con un monstruo del adversario	
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsRelateToBattle() and tc:IsControlerCanBeChanged() end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local tc=e:GetHandler():GetBattleTarget()
    if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp) and tc:IsLocation(LOCATION_MZONE) then
        Duel.BreakEffect()
		Duel.GetControl(tc,tp,0,1) -- Tomar control: '0,1' es un control permanente
		-- 1. No puede atacar este turno
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
        -- 2. Convertir su Tipo en Ilusión (EFFECT_CHANGE_TYPE)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(RACE_ILLUSION)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
	--	*EFECTO 5°
function s.sfilter1(c,e,tp)
    return c:IsCode(86893702) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spth(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.sfilter1,tp,LOCATION_GRAVE|LOCATION_REMOVED, 0, nil, e, tp)
    if chk==0 then
        -- Se debe poder Invocar a "Gluttonia" para activar el efecto
        return #g>0
    end
    -- Establece la Invocación de Gluttonia como acción obligatoria
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.sfilter1,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
    if #g==0 then return end
    -- 1. Invocar de Modo Especial "Anotherverse Gluttonia" (Mandatorio)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    if tc then
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
            if c:IsRelateToEffect(e) then
				Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
        end
    end
end