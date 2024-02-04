--Llama Estigma Bestial
--Llama Estigma Bestial
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x3e9),nil,s.fextra)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
s.listed_series={0x3e9}
s.listed_names={132}
    --Condicion
function s.filter(c)
	return c:IsCode(132)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
end
    --Invocar por Fusión metodo alternativo
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=2
end
function s.fextra(e,tp,mg)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0) then
		local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsSetCard(0x3e9) and c:IsAbleToGrave()
end