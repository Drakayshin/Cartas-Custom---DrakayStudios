--Irae, Atemporal Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Solo puedes controlar 1
    c:SetUniqueOnField(1,0,id)
    --  Efecto 1: Invocación de Modo Especial desde la mano (Sacrificando 1 del adversario)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --  Efecto 2: Tomar el control (Efecto Disparado al ser Invocado Normal)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,id) -- El ID base comparte el límite con e3
    e2:SetTarget(s.ctltg)
    e2:SetOperation(s.ctlop)
    c:RegisterEffect(e2)
    local e2a=e2:Clone()
    e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2a)
    --  Efecto 1: Desterrar para bloquear activaciones
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id) -- El ID base comparte el límite con e2
    e3:SetCondition(s.stuncon)
    e3:SetCost(s.stuncost)
    e3:SetOperation(s.stunop)
    c:RegisterEffect(e3)
end
s.listed_series={0x3e7}
    --  *Filtro global para identificar los tipos de monstruos objetivo
function s.exfilter(c)
    return c:IsType(TYPE_RITUAL|TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
    --  *EFECTO 1°
function s.spfilter(c,tp)
    return s.exfilter(c) and c:IsReleasable() and c:IsControler(1-tp)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    -- Se requiere espacio en TU campo, ya que sacrificas en el campo rival
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_MZONE,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,0,LOCATION_MZONE,nil,tp)
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
    -- *EFECTO 2°
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
    --  EFECTO 3°
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x3e7) 
end
function s.stuncon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.stuncost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.stunop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetValue(s.aclimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
    local tc=re:GetHandler()
    return re:IsActiveType(TYPE_MONSTER) and tc:IsLocation(LOCATION_MZONE) and s.exfilter(tc)
end