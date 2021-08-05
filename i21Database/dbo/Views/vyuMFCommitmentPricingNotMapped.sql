CREATE VIEW vyuMFCommitmentPricingNotMapped
AS
SELECT CP.intCommitmentPricingId
	,C.strName
	,C.strExternalERPId AS strAliasName
	,UOM.strUnitMeasure
	,CUR.strCurrency
	,MB.dtmM2MBasisDate
	,AB.dtmAdditionalBasisDate
FROM tblMFCommitmentPricing CP
LEFT JOIN tblEMEntity C on C.intEntityId = CP.intEntityId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CP.intUnitMeasureId
LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CP.intCurrencyId
LEFT JOIN tblRKM2MBasis MB ON MB.intM2MBasisId = CP.intM2MBasisId
LEFT JOIN tblMFAdditionalBasis AB ON AB.intAdditionalBasisId = CP.intAdditionalBasisId
