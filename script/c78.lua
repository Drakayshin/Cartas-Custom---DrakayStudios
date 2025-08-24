--Acamanto Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Cambiar el efecto de la carta activada por tu adversario
	local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_DRAW)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e0:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_DUEL)
	e0:SetCondition(s.chcon)
	e0:SetTarget(s.chtg)
	e0:SetOperation(s.chop)
	c:RegisterEffect(e0)
	local e0a=e0:Clone()
	e0:SetRange(LOCATION_GRAVE)
	e0a:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	c:RegisterEffect(e0a)
	local e0b=e0:Clone()
	e0b:SetRange(LOCATION_REMOVED)
	e0b:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_DUEL)
	c:RegisterEffect(e0b)
    --  1° Causar daño igual al ATK original del monstruo que activo un efecto en el Campo de tu adversario
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,3})
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
s.listed_series={0x3e7}
    -- 	*EFECTO 0°
function s.chcon(e,tp,eg,ep,ev,re,r,rp,chk)
    local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
    return ep==1-tp and re:IsMonsterEffect() and trig_loc&(LOCATION_HAND|LOCATION_GRAVE)>0
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) 
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Group.CreateGroup()
		Duel.ChangeTargetCard(ev,g)
		Duel.ChangeChainOperation(ev,s.repop)
	end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local h1=Duel.Draw(tp,1,REASON_EFFECT)
	local h2=Duel.Draw(1-tp,1,REASON_EFFECT)
	if h1>0 or h2>0 then Duel.BreakEffect() end
	if h1>0 then
		Duel.ShuffleHand(tp)
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
	if h2>0 then 
		Duel.ShuffleHand(1-tp)
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
    --  *EFECTO 1°
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
    return rp==1-tp and re:IsMonsterEffect() and trig_loc&(LOCATION_MZONE)>0 and re:GetHandler():GetBaseAttack()>0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
	local atk=re:GetHandler():GetBaseAttack()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(atk)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
		Duel.ShuffleHand(tp)
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
        Duel.Damage(p,d,REASON_EFFECT)
	end
end