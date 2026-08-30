--Arcignis, La Predadora Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Solo puedes controlar 1
    c:SetUniqueOnField(1,0,id)
    --  Efecto 0: Invocación de Modo Especial desde la mano (Sacrificando 1 del adversario)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_HAND)
    e0:SetCondition(s.spcon)
    e0:SetTarget(s.sptg)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    --  Efecto 1: Tomar el control
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(function()return Duel.IsMainPhase() end)
    e1:SetTarget(s.ctltg)
    e1:SetOperation(s.ctlop)
    c:RegisterEffect(e1)
    --  Efecto 2: Rápido durante la Main Phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E + TIMING_MAIN_END)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.condition)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

    --  Rastrear activaciones globales de efectos por tipo de monstruo en el turno
    if not s.global_check then
        s.global_check = true
        local ge1 = Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAINING)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1, 0)
    end
end
s.listed_series={0x3e7}
    --  *Filtro global para identificar los tipos de monstruos objetivo
function s.exfilter(c)
    return c:IsType(TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
    --  *EFECTO 0°
function s.spfilter(c,tp)
    return s.exfilter(c) and c:IsReleasable()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    --  *Se requiere espacio en TU campo, ya que sacrificas en el campo rival
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local tc=g:SelectUnselect(nil,tp,false,true,1,1)
    if tc then
        e:SetLabelObject(tc)
        return true
    else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local tc=e:GetLabelObject()
    if tc then
        Duel.Release(tc,REASON_COST)
    end
end
    -- *EFECTO 1°
function s.ctlfilter(c)
    return c:IsFaceup() and s.exfilter(c) and c:IsControlerCanBeChanged()
end
function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctlfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.ctlfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.ctlfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    --  *Toma el control hasta la End Phase del próximo turno (2 End Phases)
    if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,2) then
        local c=e:GetHandler()
        --  *Negar efectos
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc:RegisterEffect(e2)
        --  *Tratar como "Terranigma"
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_ADD_SETCODE)
        e3:SetValue(0x3e7)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc:RegisterEffect(e3)
    end
end
    --  EFECTO 2°
    -- Rastrear cuándo un jugador activa un efecto de un Tipo de Monstruo específico
function s.checkop(e, tp, eg, ep, ev, re, r, rp)
    if re:IsActiveType(TYPE_MONSTER) then
        local monster_types = {TYPE_RITUAL, TYPE_FUSION, TYPE_SYNCHRO, TYPE_XYZ, TYPE_LINK}
        for _, t in ipairs(monster_types) do
            if re:IsActiveType(t) then
                -- Registra 1 conteo para el jugador (rp) y este tipo de monstruo en el turno
                Duel.RegisterFlagEffect(rp, id + t, RESET_PHASE + PHASE_END, 0, 1)
            end
        end
    end
end

-- Condición de activación: Debe ser Main Phase y no haberse activado el turno anterior
function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase() and Duel.GetFlagEffect(tp,id+100) == 0
end

-- Target: Comprobar que la carta puede ser desterrada
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemove() end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end

-- Resolución del efecto
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- 1. Desterrar esta carta hasta la End Phase (en resolución)
    if c:IsRelateToEffect(e) and Duel.Banish(c, POS_FACEUP, REASON_EFFECT + REASON_TEMPORARY) ~= 0 then
        -- Programar el retorno de la carta al campo al final del turno
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE + PHASE_END)
        e1:SetReset(RESET_PHASE + PHASE_END)
        e1:SetCountLimit(1)
        e1:SetLabelObject(c)
        e1:SetOperation(s.retop)
        Duel.RegisterEffect(e1, tp)
        -- 2. Restricción para el resto del turno: máximo 1 efecto activado por Tipo de Monstruo por jugador
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetCode(EFFECT_CANNOT_ACTIVATE)
        e2:SetTargetRange(1,1)
        e2:SetValue(s.aclimit)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
        -- 3. Bloquear la activación de este efecto durante el siguiente turno (expira al final del 2do turno)
        Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,2)
    end
end

-- Operación para retornar al campo en la End Phase
function s.retop(e, tp, eg, ep, ev, re, r, rp)
    Duel.ReturnToField(e:GetLabelObject())
end

-- Lógica de restricción de activación
function s.aclimit(e, re, tp)
    if re:IsActiveType(TYPE_MONSTER) then
        local monster_types = {TYPE_RITUAL, TYPE_FUSION, TYPE_SYNCHRO, TYPE_XYZ, TYPE_LINK}
        for _, t in ipairs(monster_types) do
            -- Si la carta que se intenta activar es de ese tipo y el jugador ya activó >= 1 en el turno:
            if re:IsActiveType(t) and Duel.GetFlagEffect(tp,id+t)>= 1 then
                return true -- Previene la activación
            end
        end
    end
    return false
end