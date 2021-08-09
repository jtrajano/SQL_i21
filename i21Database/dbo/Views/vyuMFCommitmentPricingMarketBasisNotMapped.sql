CREATE VIEW vyuMFCommitmentPricingMarketBasisNotMapped
AS
SELECT CPM.intCommitmentPricingMarketBasisId
	,I.strItemNo
	,C.strCurrency + '/' + UOM.strUnitMeasure AS strUOM
FROM tblMFCommitmentPricingMarketBasis CPM
--JOIN tblMFCommitmentPricing CP ON CP.intCommitmentPricingId = CPM.intCommitmentPricingId
JOIN tblICItem I ON I.intItemId = CPM.intItemId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = CPM.intCurrencyId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CPM.intUnitMeasureId
