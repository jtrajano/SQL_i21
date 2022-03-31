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
		 --  ISNULL(CASE WHEN (dblActualValue - dblTargetValue) >= 0 THEN 
			--	Round((dblActualValue - dblTargetValue) / dblFactorOverTarget,0) * dblPremium
			--ELSE
			--	Round((dblTargetValue - dblActualValue) / dblFactorUnderTarget,0) * dblDiscount
			--END,0) dblResult,
			0 dblResult,
			'Exact factor' strEscalatedBy,
		   intConcurrencyId
	from tblCTContractQuality CQ
	WHERE CQ.intContractDetailId = @intContractDetailId


	UPDATE @Qty
	SET dblResult = ISNULL(CASE WHEN (dblActualValue - dblTargetValue) >= 0 THEN 
						Round((dblActualValue - dblTargetValue) / dblFactorOverTarget,0) * dblPremium
					ELSE
						Round((dblTargetValue - dblActualValue) / dblFactorUnderTarget,0) * dblDiscount
					END,0) 
	
	
	--((dblActualValue - dblTargetValue) / (CASE WHEN dblActualValue < dblTargetValue THEN dblFactorUnderTarget ELSE dblFactorOverTarget END)) *
	--CASE WHEN dblActualValue < dblTargetValue THEN dblDiscount ELSE dblPremium END
	


	select  *
	from @Qty

	