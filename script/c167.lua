--Sagaz del Ciber-Estilo
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.ListsArchetypeAsMaterial,0x1093),nil,s.fextra,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg,s.stage2)
	e1:SetCondition(function(_,tp) return Duel.GetLP(tp)<Duel.GetLP(1-tp) end)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil),s.fcheck
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
        --Cannot change their battle positions
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3313)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		Duel.RegisterEffect(e1,tp)
		--Must attack, if able to
		local e2=e1:Clone()
		e2:SetDescription(3200)
		e2:SetCode(EFFECT_MUST_ATTACK)
		Duel.RegisterEffect(e2,tp)
	end
end
