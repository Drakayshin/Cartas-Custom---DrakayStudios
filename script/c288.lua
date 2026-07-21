--Oni-namuji, Vasallo de la Bruma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  *Invocación por Péndulo
    Pendulum.AddProcedure(c)
    
    --  EFECTO DE PENDULO

    --  Efecto 0: 
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
end
    --  *EFECTO 0°
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 
    and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) and Duel.Destroy(tc,REASON_EFFECT)~=0 
    and tc:GetBaseAttack()>=0 and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		e1:SetValue(tc:GetBaseAttack())
		c:RegisterEffect(e1)
	end
end