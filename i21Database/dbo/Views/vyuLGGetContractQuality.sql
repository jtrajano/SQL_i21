CREATE VIEW [dbo].[vyuLGGetContractQuality]
AS

Select
	CQ.intQualityId
	,CQ.intContractDetailId
	,CQ.intItemId
	,IC.strItemNo
	,CQ.intPropertyId
	,CQ.strPropertyName
	,CQ.dblTargetValue
	,CQ.dblMinValue
	,CQ.dblMaxValue
	,CQ.dblFactorOverTarget
	,CQ.dblPremium
	,CQ.dblFactorUnderTarget
	,CQ.dblDiscount
	,CQ.strCostMethod
	,CQ.intCurrencyId
	,CQ.strCurrency
	,CQ.intUnitMeasureId
	,CQ.strUnitMeasure
	,CQ.strEscalatedBy
	,CQ.dblActualValue
	,CQ.dblResult
	,CQ.intSequenceCurrencyId
	,CQ.strSequenceCurrency
	,CQ.intSequenceUnitMeasureId
	,CQ.strSequenceUnitMeasure
	,CQ.dblFXRate
	,CQ.dblAmount
	,CQ.intConcurrencyId
FROM tblCTContractQuality CQ
INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = CQ.intContractDetailId
INNER JOIN tblICItem IC on CQ.intItemId = IC.intItemId

GO

