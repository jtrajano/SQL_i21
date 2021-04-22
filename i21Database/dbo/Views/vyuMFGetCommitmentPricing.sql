CREATE VIEW vyuMFGetCommitmentPricing
AS
SELECT CP.intCommitmentPricingId
	,CP.strPricingNumber
	,C.strName
	,C.strExternalERPId AS strAliasName
	,CP.dtmDeliveryFrom
	,CP.dtmDeliveryTo
	,UOM.strUnitMeasure
	,CUR.strCurrency
	,CP.dtmDate
	,MB.dtmM2MBasisDate
	,AB.dtmAdditionalBasisDate
	,CP.strERPNo
	,CP.dblBalanceQty
	,CP.strComment
	,CP.dblMarketArbitrage
	,CP.ysnPost
FROM tblMFCommitmentPricing CP
LEFT JOIN tblEMEntity C on C.intEntityId = CP.intEntityId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CP.intUnitMeasureId
LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CP.intCurrencyId
LEFT JOIN tblRKM2MBasis MB ON MB.intM2MBasisId = CP.intM2MBasisId
LEFT JOIN tblMFAdditionalBasis AB ON AB.intAdditionalBasisId = CP.intAdditionalBasisId
