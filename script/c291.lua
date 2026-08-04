--Montaraz de la Fábula
--DrakayStudios - Asegoria por Gemini
local s,id=GetID()
function s.initial_effect(c)
	--  Efecto 0: El nombre de esta carta se convierte en "Yacard, Héroe de la Fábula" en Campo o Cementerio
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
    e0:SetValue(290)
    c:RegisterEffect(e0)
    -- Efecto 1: Invocar de Modo Especial en la Main Phase si no controlas monstruos (Efecto Rápido)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- "Invocar de Modo Especial y destruir carta"
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
    -- Efecto 2: Al comienzo de la Fase de Batalla, Invocar a esta carta y otro monstruo
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1)) -- "Invocar de Modo Especial desde mano/destierro y Deck"
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e2:SetRange(LOCATION_HAND|LOCATION_REMOVED)
    e2:SetCountLimit(1,id) -- "Solo puedes activar 1 efecto de 'Montaraz de la Fábula' por turno" (Cláusula compartida)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end
s.listed_names={290,292}
    --  *EFECTO 1°
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    -- Durante la Main Phase y no controlas monstruos
    return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) 
        and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)	and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
            Duel.Destroy(g,REASON_EFFECT)
            Duel.BreakEffect()
            --  *Destierrala cuando deje el Campo
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3300)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
            c:RegisterEffect(e1,true)
		end
	end
end
    --  *EFECTO 2°
function s.mentionfilter(c,e,tp)
    return c:IsCode(292) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
    and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    --  *Se necesitan al menos 2 espacios libres (o 1 si Montaraz se invoca desde el campo, pero aquí inicia en mano/destierro)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
            and Duel.IsExistingMatchingCard(s.mentionfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_REMOVED,0,1,nil,e,tp) 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND|LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_REMOVED)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or not c:IsRelateToEffect(e) then return end
    --  *Invocamos a Montaraz y 1 monstruo
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.mentionfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
            Duel.SpecialSummonComplete()
        end
    end
end