--Céfiro, Aeromántico Flamante
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Inafectada por efectos activos de cartas Mágicas/ de Trampa
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
    e0:SetValue(function(e,te) return te:IsActivated() and te:IsSpellTrapEffect() and te:GetOwner()~=e:GetOwner() end)
    c:RegisterEffect(e0)
    --  1° Invocar de Modo Especial desde la mano y posible alteración de Nivel
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.PayLP(500))
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --  2° Colocar o añadir a la mano 1 carta Mágica "Flamante" y causar al mismo tiempo daño a tu adversario
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.rvcost)
	e2:SetTarget(s.rvth)
	e2:SetOperation(s.rvop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3ee}
    --  *EFECTO 1°
function s.spconfilter(c)
	return  c:IsOriginalRace(RACE_WARRIOR|RACE_BEASTWARRIOR) or (c:IsSetCard(0x3ee) and not c:IsType(TYPE_TUNER)) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		--  *Alterar el Nivel de esta carta
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
		local lvl=1
		if c:GetLevel()==1 then
			Duel.SelectOption(tp,aux.Stringid(id,0))
		else
			local sel=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
			if sel==1 then
				lvl=-1
			end
		end
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		e1:SetValue(lvl)
        c:RegisterEffect(e1)
	end
end
    --  *EFECTO 2°
function s.cfilter(c)
	return c:IsSetCard(0x3ee) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.rvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetLevel()*300)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.thsetfilter(c)
	return c:IsSetCard(0x3ee) and c:IsSpell() and (c:IsAbleToHand() or c:IsSSetable())
end
function s.rvth(e,tp,eg,ep,ev,re,r,rp,chk)
    --  *Ganar LP igual al Nivel del monstruo usado como coste
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res
	end
	Duel.SetTargetParam(e:GetLabel())
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,e:GetLabel())
    e:SetLabel(0)
    --  *Colocar o añadir a tu mano1 carta Mágica "Flamante" desde tu Deck
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
    --  *Ganar LP igual al Nivel del monstruo usado como coste
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Recover(tp,d,REASON_EFFECT,true)
    Duel.RDComplete()
    --  *Colocar o añadir a tu mano1 carta Mágica "Flamante" desde tu Deck
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sc=Duel.SelectMatchingCard(tp,s.thsetfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function(sc) return sc:IsSSetable() end,
		function(sc) Duel.SSet(tp,sc) end,
		aux.Stringid(id,3)
	)
end