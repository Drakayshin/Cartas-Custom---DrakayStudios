--Vilkong, Terranigma Inclemente
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	*Solo 1 Boca arriba en tu campo
	c:SetUniqueOnField(1,0,id)
	-- 	Efecto 0: Daño de Penetración
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e0)
	--	Efecto 1: Invocar de Modo Especial desde tu mano
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--	Efecto 2:
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3e7}
	--	*EFECTO 1°
function s.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsPreviousSetCard(0x3e7) 
	and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,true,aux.ReleaseCheckMMZ,c,0x3e7) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,true,aux.ReleaseCheckMMZ,c,0x3e7)
	Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
	--	*EFECTO 2°
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	local b2=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanTurnSet),tp,0,LOCATION_MZONE,1,e:GetHandler())
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		local g1=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
		local g2=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
		local b1=#g1>0
		local b2=#g2>0
		if chk==0 then return b1 or b2 end
		local cd=e:GetChainData()
		cd.choice=Duel.SelectEffect(tp,{b1,aux.Stringid(id,4)},{b2,aux.Stringid(id,5)})
		local g=(cd.choice==1 and g1 or g2)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,POS_FACEDOWN_DEFENSE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local cd=e:GetChainData()
		if cd.choice==1 then
			local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
			if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
		elseif cd.choice==2 then
			local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
			if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
		end
	else
		local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
		if #g==0 or Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)==0 then return end
		local c=e:GetHandler()
		for tc in g:Match(Card.IsPosition,nil,POS_FACEDOWN_DEFENSE):Iter() do
			--  *No pueden cambiar sus Posiciones de Batalla
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3313)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--	*Duplicar el daño de batalla a tu adversario de esta carta
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
			e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
			c:RegisterEffect(e2)
		end
	end
end