Create PROCEDURE [dbo].[uspCTSaveContractSamplePremium] @intContractDetailId INT
	,@intSampleId INT
	,@intUserId INT
	,@ysnImpactPricing BIT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @tblTemp TABLE (
			intSampleId INT
			,intContractDetailId INT
			,intItemId INT
			,intPropertyId INT
			,dblTargetValue NUMERIC(18, 6)
			,dblMinValue NUMERIC(18, 6)
			,dblMaxValue NUMERIC(18, 6)
			,dblFactorOverTarget NUMERIC(18, 6)
			,dblPremium NUMERIC(18, 6)
			,dblFactorUnderTarget NUMERIC(18, 6)
			,dblDiscount NUMERIC(18, 6)
			,strCostMethod nvarchar(100)
			,strEscalatedBy nvarchar(100)

			,intCurrencyId INT
			,intUnitMeasureId INT
			,strActualValue nvarchar(100)
			,intQualityCriteriaId INT
			,intQualityCriteriaDetailId INT
			,strSampleNumber nvarchar(100)
			,strPropertyName nvarchar(100)
			,strCurrency nvarchar(100)
			,strUnitMeasure nvarchar(100)
		)
		INSERT INTO @tblTemp(
			intSampleId 
			,intContractDetailId
			,intItemId
			,intPropertyId
			,dblTargetValue
			,dblMinValue
			,dblMaxValue
			,dblFactorOverTarget
			,dblPremium
			,dblFactorUnderTarget
			,dblDiscount
			,strCostMethod
			,strEscalatedBy
			,intCurrencyId
			,intUnitMeasureId
			,strActualValue
			,intQualityCriteriaId
			,intQualityCriteriaDetailId
			,strSampleNumber
			,strPropertyName
			,strCurrency
			,strUnitMeasure
		)
		EXEC uspQMGetSamplePremiumTestResult @intSampleId

		IF Exists(SELECT TOP 1 1 FROM tblCTContractQuality where intContractDetailId = @intContractDetailId and intSampleId = @intSampleId)
		BEGIN
			DELETE FROM tblCTContractQuality where intContractDetailId = @intContractDetailId and intSampleId = @intSampleId
		END

		
		IF @ysnImpactPricing = 1 
		BEGIN

			Insert INTO tblCTContractQuality(
				intSampleId
				,intContractDetailId
				,intItemId
				,intPropertyId
				,strPropertyName
				,dblTargetValue
				,dblMinValue
				,dblMaxValue
				,dblFactorOverTarget
				,dblPremium
				,dblFactorUnderTarget
				,dblDiscount
				,strCostMethod
				,intCurrencyId
				,intUnitMeasureId
				,strCurrency
				,strUnitMeasure
				,ysnImpactPricing
				,dblActualValue
				,dblResult
				,strEscalatedBy
				,intSequenceCurrencyId
				,strSequenceCurrency
				,intSequenceUnitMeasureId
				,strSequenceUnitMeasure
			)
			SELECT	intSampleId, 
					tmp.intContractDetailId, 
					tmp.intItemId,
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
					tmp.intCurrencyId,
					tmp.intUnitMeasureId,
					tmp.strCurrency,
					tmp.strUnitMeasure,
					1,
					CASE WHEN ISNULL(strActualValue, '') = '' THEN 0 ELSE CAST(strActualValue as Numeric(18,6)) END AS dblActualValue,
					(SELECT dbo.fnCTGetQualityResult(CASE WHEN ISNULL(strActualValue, '') = '' THEN 0 ELSE CAST(strActualValue as Numeric(18,6)) END 
													, dblMinValue
													, dblMaxValue
													, dblTargetValue
													, dblFactorUnderTarget
													, dblFactorOverTarget
													, dblDiscount
													, dblPremium
													, strEscalatedBy)),
					strEscalatedBy,
					CU.intMainCurrencyId intSequenceCurrencyId,
					CU.strCurrency strSequenceCurrency,
					UM.intUnitMeasureId,
					UM.strUnitMeasure
					
			FROM @tblTemp tmp
			JOIN tblCTContractDetail CD on CD.intContractDetailId = tmp.intContractDetailId
			JOIN (
				SELECT intCurrencyID, intMainCurrencyId, strCurrency 
				FROM (
					
					select intCurrencyID, ISNULL(intMainCurrencyId, intCurrencyID) intMainCurrencyId, strCurrency
					from tblSMCurrency 
					where intMainCurrencyId is null

					UNION ALL

					select C.intCurrencyID, M.intCurrencyID intMainCurrencyId, M.strCurrency
					from tblSMCurrency C
					JOIN tblSMCurrency M on C.intMainCurrencyId = M.intCurrencyID
					where C.intMainCurrencyId is NOT null
					) a
				Group by intCurrencyID, strCurrency, intMainCurrencyId 
			
			) CU on CU.intCurrencyID = CD.intCurrencyId
			JOIN (
				select  IT.intItemUOMId, IT.intUnitMeasureId, strUnitMeasure
				from tblICItemUOM IT
				JOIN tblICUnitMeasure UM on IT.intUnitMeasureId = UM.intUnitMeasureId

			)UM on UM.intItemUOMId = CD.intPriceItemUOMId

		END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH