--Evocación Bestial
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Invocación de Fusión
	local e0=Fusion.CreateSummonEff({handler=c,fusfilter=s.filter,matfilter=s.mfilter1,extrafil=s.fextra,stage2=s.stage2})
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_CHAINING)
    e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
    -- Puedes activar desde la mano
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.handcon)
    c:RegisterEffect(e1)
end
s.listed_series={0x3e9}

function s.filter(c)
	return c:IsSetCard(0x3e9) and c:IsLevelBelow(8)
end
function s.mfilter1(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_MZONE) and c:IsAbleToGrave())
end
function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0x3e9)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,0,LOCATION_ONFIELD,nil),s.checkmat
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Gana 400 ATK por cada material
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(#sg*400)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
        -- Destruido al final de turno
        aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,0)
	end
end
    -- Puedes activar desde la mano
function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end