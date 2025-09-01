--Dark Contract with the Monopoly Seal
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
    --  0° Activar en el turno que se colocada
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCondition(function(e) return not Duel.IsExistingMatchingCard(Card.IsTrap,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil) end)
	c:RegisterEffect(e0)
	--   0a° Activación y busqueda
	local e0a=Effect.CreateEffect(c)
	e0a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0a:SetType(EFFECT_TYPE_ACTIVATE)
	e0a:SetCode(EVENT_FREE_CHAIN)
	e0a:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0a:SetOperation(s.activate)
	c:RegisterEffect(e0a)	
    --  1° Limitar las Invocación de tu adversario desde el Deck Extra
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,1)
	e1:SetLabel(TYPE_RITUAL)
	e1:SetCondition(s.con)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetLabel(TYPE_FUSION)
	c:RegisterEffect(e1a)
	local e1b=e1:Clone()
	e1b:SetLabel(TYPE_SYNCHRO)
    c:RegisterEffect(e1b)
    local e1c=e1:Clone()
	e1c:SetLabel(TYPE_XYZ)
    c:RegisterEffect(e1c)
    --  2° Invocar 1 monstruo "Ojos Rojos" que no sea Fusión, Sincronía o Xyz que este desterrado o en tu Cementerio
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    --  3° Invocar Monstruos que tengan el mgismo Tipo o Atributo que monstruos "Ojos Rojos" regresados por este efecto
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,2})
	e3:SetCost(s.cost)
	e3:SetTarget(s.spttg)
	e3:SetOperation(s.sptop)
	c:RegisterEffect(e3)
end
s.listed_names={92353449}
s.listed_series={SET_RED_EYES}
    --  *EFECTO 0°
function s.thfilter(c)
	return c:IsCode(92353449) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
    --  *EFECTO 1°
function s.filterx(c,tpe)
	return c:IsFaceup() and c:IsType(tpe) and c:IsSetCard(SET_RED_EYES)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.filterx,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,e:GetLabel())
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and c:IsType(e:GetLabel())
end
    --  *EFECTO 2°
function s.spfilterx(c,e,tp)
	return c:IsSetCard(SET_RED_EYES) and not c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilterx,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,nil,e,tp) and
		Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilterx),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
			--Neither player can activate cards or effects when that monster is Special Summoned
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_END)
			e1:SetLabelObject(sc)
			e1:SetOperation(s.limop)
			Duel.RegisterEffect(e1,tp)
		end
		Duel.SpecialSummonComplete()
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	local ex,sg=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if ex and #sg==1 and sg:GetFirst()==sc and sc:HasFlagEffect(id) then
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	e:Reset()
end
    --  *EFECTO 3°
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.cfilter(c,g,e,tp)
	if not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) or not c:IsAbleToExtraAsCost() then return false end
	local exg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,c,e,tp)
	g:Merge(exg)
	return #exg>0
end
function s.spfilter(c,sc,e,tp)
	return s.chkfilter(sc,c) and c:IsSetCard(SET_RED_EYES) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.chkfilter(sc,c)
	local tpe=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ
	return c:IsRace(sc:GetRace()) or c:IsAttribute(sc:GetAttribute())
end
function s.rescon1(g)
	return function(sg,e,tp,mg)
				local ct=#sg
				return aux.SelectUnselectGroup(g,e,tp,ct,ct,s.rescon2(sg),0)
			end
end
function s.rescon2(g)
	return function(sg,e,tp,mg)
				local gtable={}
				g:ForEach(function(tc)
					table.insert(gtable,tc)
				end)
				return sg:IsExists(s.chk,1,nil,tp,sg,Group.CreateGroup(),table.unpack(gtable))
			end
end
function s.chk(c,tp,sg,g,sc,...)
	local tpe=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ
	if not s.chkfilter(sc,c) or Duel.GetLocationCountFromEx(tp,tp,nil,tpe)<#sg then return false end
	if not ... then return true end
	g:AddCard(c)
	local res=sg:IsExists(s.chk,1,g,tp,sg,g,...)
	g:RemoveCard(c)
	return res
end
function s.spttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Group.CreateGroup()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil,sg,e,tp)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return aux.SelectUnselectGroup(g,e,tp,nil,nil,s.rescon1(sg),0)
	end
	local cg=aux.SelectUnselectGroup(g,e,tp,nil,nil,s.rescon1(sg),1,tp,HINTMSG_TODECK,s.rescon1(sg))
	cg:KeepAlive()
	Duel.SendtoDeck(cg,nil,0,REASON_COST)
	Duel.SetTargetCard(cg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#cg,tp,LOCATION_DECK)
end
function s.filter(c,sc)
	return c:IsRace(sc:GetRace()) and c:IsAttribute(sc:GetAttribute())
		and c:IsType(sc:GetType()&(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ))
end
function s.sptop(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetTargetCards(e)
	local ct=#cg
	local sg=Group.CreateGroup()
	cg:ForEach(function(tc)
		sg:Merge(Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,tc,e,tp,cg))
	end)
	if not aux.SelectUnselectGroup(sg,e,tp,ct,ct,s.rescon2(cg),0) then return end
	local spg=aux.SelectUnselectGroup(sg,e,tp,ct,ct,s.rescon2(cg),1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
end