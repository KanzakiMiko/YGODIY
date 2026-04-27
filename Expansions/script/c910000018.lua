--幽灵宝可梦－谜拟丘
local s,id,o=GetID()
local SET_GHOST_POKEMON=0x1770
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcMixRep(c,true,true,s.ffilter,2,2)
	--Extra Fusion Materials from GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_GRAVE,0)
	e0:SetTarget(s.extramtg)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)
	--Destroy and search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.dscon)
	e1:SetTarget(s.dstg)
	e1:SetOperation(s.dsop)
	c:RegisterEffect(e1)
	--Negate attack and temporarily banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.atkcon)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.gfilter(c)
	return c:IsSetCard(SET_GHOST_POKEMON) and c:IsType(TYPE_MONSTER)
end
function s.ffilter(c,fc,sumtype,tp)
	return s.gfilter(c)
end
function s.extramtg(e,c)
	return s.gfilter(c) and c:IsAbleToRemove()
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sg,fc=...
		return fc==e:GetHandler()
	elseif chk==2 then
		return Group.CreateGroup()
	end
end
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.dsfilter(c)
	return c:IsOnField() and c:IsDestructable()
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.dsfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dsfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.dsfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.thfilter(c)
	return c:IsSetCard(SET_GHOST_POKEMON) and c:IsAbleToHand()
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.rmfilter(c)
	return s.gfilter(c) and c:IsAbleToRemoveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ac=Duel.GetAttacker()
	if chk==0 then return ac:IsOnField() and ac:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,ac,1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	if Duel.NegateAttack() and ac:IsRelateToBattle() and Duel.Remove(ac,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetLabelObject(ac)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsLocation(LOCATION_REMOVED) then
		Duel.ReturnToField(tc)
	end
end
