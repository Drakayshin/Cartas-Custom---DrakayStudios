--Horizonte del Génesis Onírico
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  0° Activación: Búsqueda o Invocación Especial
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
    --  1° Reducir el daño a 0 de batallas espeficias
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.efilter)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(s.valcheck)
		Duel.RegisterEffect(ge1,0)
    end)
    --  2° Invocar de Modo Especial 1 Monstruo Normal
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,2})
    e2:SetCost(Cost.PayLP(1000))
    e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --  3° Invocación por Fusión 1 Monstruo de Fusión Ilusión
    local params = {nil,Fusion.OnFieldMat,matfilter=s.mfilter,extrafil=s.fextra}
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,{id,3})
    e3:SetCondition(function(e,tp) return Duel.IsMainPhase(tp) end)
	e3:SetCost(Cost.PayLP(1000))
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
    c:RegisterEffect(e3)
end
    --  *EFECTO 0°
 function s.filter(c)
    return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        local sg=g:Select(tp,1,1,nil):GetFirst()
        if sg:IsCanBeSpecialSummoned(e,0,tp,false,false) 
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then -- ID 2: "¿Invocar de modo especial?"
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        else
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    end
end  
    --  *EFECTO 1°
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		c:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD),0,1)
	end
end
function s.efilter(e,c)
	if c:IsType(TYPE_NORMAL) then
		return c:IsLevelAbove(5)
	else
		local summon_types={SUMMON_TYPE_RITUAL,SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ}
		return c:GetFlagEffect(id)>0 and c:IsSummonType(table.unpack(summon_types))
	end
end
    --  *EFECTO 2°
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then 
		--  *Barajalo al Deck si deja el Campo
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3900)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKSHF)
		tc:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
    --  *EFECTO 3°
function s.mfilter(c)
	return (c:IsLocation(LOCATION_MZONE) and c:IsAbleToGrave())
end
function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD,0,nil),s.checkmat
end