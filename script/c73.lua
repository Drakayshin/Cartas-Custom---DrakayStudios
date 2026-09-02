--Limacoideus Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  EFecto 0: Reflejar daño por batalla
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--  Efecto 1: Invocar de Modo Especial esta carta
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --  Efecto 2: Efecto multiple: Robar 1 carta, o Infigir daño a los LP del adversario
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
s.listed_series={0x3e7}
    --  *EFECTO 1°
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e7) or (c:IsAttribute(ATTRIBUTE_DARK))
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.ListsCode,1,nil,CARD_LIGHT_AND_DARKNESS_RITUAL)
end
function s.desfilter2(c,e)
	return s.desfilter(c) and c:IsCanBeEffectTarget(e)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc) end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(s.desfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
	if chk==0 then return ft>-2 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and #g>2 and aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
            --  *No puede ser destruir por batalla o por efectos
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3008)
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
            c:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            c:RegisterEffect(e2)
        end
	end
end
    --  *EFECTO 2°
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local b1=true
	local b2=true
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
    e:SetLabel(op)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,800)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
		--	*Robar 1 carta
        if c:IsRelateToEffect(e) and Duel.Draw(tp,1,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local drawn_card=Duel.GetOperatedGroup():GetFirst()
		if drawn_card:IsSetCard(0x3e7) and drawn_card:IsMonster() and drawn_card:IsSummonable(true,nil) then
			if not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return Duel.ShuffleHand(tp) end
			Duel.BreakEffect()
            Duel.Summon(tp,drawn_card,true,nil)
        end
	end
	elseif op==2 then
		Duel.BreakEffect()
		if Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))==0 then
			local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
       		local dam=#g*100
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		else
			local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
       		local rec=#g*100
			Duel.Recover(tp,rec,REASON_EFFECT)
		end
	end
end