--Soldado del Éxodo Flamante
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Invocación por Sincronía
    c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3ee),1,1,Synchro.NonTuner(nil),1,99)
end
s.listed_series={0x3ee}