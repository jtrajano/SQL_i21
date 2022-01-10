Create PROCEDURE [dbo].[uspCTLoadContractQuality]
	@intContractDetailId	INT
AS
	select intQualityId,
		   intSampleId,
		   intContractDetailId,
		   intItemId,
		   intPropertyId,
		   strPropertyName,
		   dblTargetValue,
		   dblMinValue,
		   dblMaxValue,
		   dblFactorOverTarget,
		   dblPremium,
		   dblFactorUnderTarget,
		   dblDiscount,
		   strCostMethod,
		   intCurrencyId,
		   intUnitMeasureId,
		   strCurrency,
		   strUnitMeasure,
		   dblActualValue,
		   ISNULL(CASE WHEN (dblActualValue - dblTargetValue) >= 0 THEN 
				Round((dblActualValue - dblTargetValue) / dblFactorOverTarget,0) * dblPremium
			ELSE
				Round((dblTargetValue - dblActualValue) / dblFactorUnderTarget,0) * dblDiscount
			END,0) dblResult,
		   intConcurrencyId
	from tblCTContractQuality CQ
	WHERE CQ.intContractDetailId = @intContractDetailId


	