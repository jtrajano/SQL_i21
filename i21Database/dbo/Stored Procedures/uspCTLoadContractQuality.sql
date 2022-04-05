
Create PROCEDURE [dbo].[uspCTLoadContractQuality]
	@intContractDetailId	INT
AS



	DECLARE @Qty TABLE (
		intQualityId INT
		, intSampleId INT
		, intContractDetailId INT
		, intItemId INT
		, intPropertyId INT
		, strPropertyName [nvarchar](100) NULL
		, dblTargetValue NUMERIC(18, 6)
		, dblMinValue NUMERIC(18, 6)
		, dblMaxValue NUMERIC(18, 6)
		, dblFactorOverTarget NUMERIC(18, 6)
		, dblPremium NUMERIC(18, 6)
		, dblFactorUnderTarget NUMERIC(18, 6)
		, dblDiscount NUMERIC(18, 6)
		, strCostMethod [nvarchar](100) NULL
		, intCurrencyId INT
		, intUnitMeasureId INT
		, strCurrency [nvarchar](100) NULL
		, strUnitMeasure [nvarchar](100) NULL
		, dblActualValue NUMERIC(18, 6)
		, dblResult NUMERIC(18, 6)
		, strEscalatedBy [nvarchar](100) NULL
		, intConcurrencyId INT
	);

	Insert into @Qty
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
			0 dblResult,
			'Exact Factor' strEscalatedBy,
		   intConcurrencyId
	from tblCTContractQuality CQ
	WHERE CQ.intContractDetailId = @intContractDetailId


	UPDATE @Qty
	SET dblResult = (SELECT dbo.fnCTGetQualityResult(dblActualValue, dblMinValue, dblMaxValue, dblTargetValue, dblFactorUnderTarget, dblFactorOverTarget, dblDiscount, dblPremium, strEscalatedBy))


	
	select  *
	from @Qty