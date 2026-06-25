--Aparición de Ju-On
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --*Solo puedes Invocar de Modo Especial "Aparición de Ju-On" una vez por turno
    c:SetSPSummonOnce(id)
	--  Efecto 0: Limite de Invocación (Normal)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e0:SetCondition(s.sumcon)
    c:RegisterEffect(e0)
    --  Efecto 1: ATK/DEF x monstruos de Oscuridad en el Campo o Cementerios
    local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(function(e,c) return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),0,LOCATION_GRAVE,LOCATION_GRAVE,e:GetHandler())*500 end)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e1b)
    --  Efecto 2: Invocar de Modo Especial a esta carta con busqueda adicional
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1,{id,0})
    e2:SetCondition(function(_,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),tp,LOCATION_MZONE,0,1,nil) end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    --  Efecto 3: Daño o Recuperación según el Atributo del monstruo Invocado
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE) 
    e3:SetCondition(s.condition)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
    local e3a=e3:Clone()
    e3a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3a)
    local e3b=e3:Clone()
    e3b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3b)
end
s.listed_names={100}
    --  *EFECTO 0°
function s.sumcon(e,c,minc)
	if not c then return true end
	return false
end
    --  *EFECTO 2°
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chk1)
	local c=e:GetHandler()
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
    or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
    local target_player=op==1 and tp or 1-tp
    --  *Si fue Invocado, añadir a tu mano 1 "Octagonshiri" desde tu Deck o Cementerio
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,target_player,false,false,POS_FACEUP)>0 
    and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
	end
end
function s.thfilter(c)
	return (c:IsCode(100) or c:ListsCode(100)) and (c:IsLocation(LOCATION_DECK|LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToHand()
end
    --  *EFECTO 3°
-- Filtro: Verifica que esté en tu campo, boca arriba, y excluye a los Monstruos de Enlace
function s.cfilter(c,tp)
    return c:IsControler(tp) and c:IsFaceup() and not c:IsType(TYPE_LINK)
end
-- Condición: Revisa si el evento de invocación involucra al menos una carta válida
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
-- Objetivo: Determina la cantidad a dañar o recuperar para la fase de declaración
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=eg:Filter(s.cfilter,nil,tp)
    local dam=0
    local rec=0
    for tc in g:Iter() do
        -- Extrae el Rango si es Xyz, de lo contrario extrae el Nivel
        local val = (tc:IsType(TYPE_XYZ) and tc:GetRank() or tc:GetLevel()) * 100
        if tc:IsAttribute(ATTRIBUTE_DARK) then
            rec = rec + val
        else
            dam = dam + val
        end
    end
    if dam>0 then
        Duel.SetTargetPlayer(tp)
        Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,dam)
    end
    if rec>0 then
        Duel.SetTargetPlayer(tp)
        Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
    end
end
-- Operación: Aplica los cambios de LP en resolución
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.cfilter,nil,tp)
    local dam=0
    local rec=0
    for tc in g:Iter() do
        local val = (tc:IsType(TYPE_XYZ) and tc:GetRank() or tc:GetLevel()) * 100
        if tc:IsAttribute(ATTRIBUTE_DARK) then
            rec = rec + val
        else
            dam = dam + val
        end
    end
    if dam>0 then Duel.Damage(tp,dam,REASON_EFFECT) end
    if rec>0 then Duel.Recover(tp,rec,REASON_EFFECT) end
end