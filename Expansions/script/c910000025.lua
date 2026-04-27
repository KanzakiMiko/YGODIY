local s,id,o=GetID()
local SET_GHOST_POKEMON=0x1770
function s.initial_effect(c)
	aux.AddEquipSpellEffect(c,true,true,s.eqfilter,nil)
	--ATK/DEF up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Cannot be targeted
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--Destruction replacement and draw
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.reptg)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end
function s.eqfilter(c)
	return c:IsSetCard(SET_GHOST_POKEMON) and c:IsType(TYPE_MONSTER)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and eg:IsContains(ec) and e:GetHandler():IsAbleToGrave() end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1)) then
		return true
	else
		return false
	end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
