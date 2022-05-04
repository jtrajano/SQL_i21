Create PROCEDURE [dbo].[uspCTSaveContractSamplePremium] @intContractDetailId INT
	,@intSampleId INT
	,@intUserId INT
	,@ysnImpactPricing BIT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intItemId INT
	DECLARE @strItemNo NVARCHAR(50)
	
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

			IF  EXISTS(SELECT TOP 1 1 FROM @tblTemp where intCurrencyId IS NULL)
			begin

				SELECT TOP 1 @intItemId = intItemId from @tblTemp where intCurrencyId IS NULL
				SELECT TOP 1 @strItemNo = strItemNo from tblICItem where intItemId = @intItemId
				SELECT @ErrMsg = 'Quality Premium Criteria for the item ' + @strItemNo + ' is not configured.'

				RAISERROR (
						@ErrMsg
						,16
						,1
						)
			END


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
				,intCurrencyIdTmp
				,strCurrencyTmp
				,intUnitMeasureIdTmp
				,strUnitMeasureTmp
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
					CASE WHEN strCostMethod = 'Percentage' THEN NULL ELSE tmp.intCurrencyId END intCurrencyId,
					CASE WHEN strCostMethod = 'Percentage' THEN NULL ELSE tmp.intUnitMeasureId END intUnitMeasureId,
					CASE WHEN strCostMethod = 'Percentage' THEN NULL ELSE tmp.strCurrency END strCurrency,
					CASE WHEN strCostMethod = 'Percentage' THEN NULL ELSE tmp.strUnitMeasure END strUnitMeasure,
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
					UM.strUnitMeasure,
					tmp.intCurrencyId,
					tmp.strCurrency, 
					tmp.intUnitMeasureId, 
					tmp.strUnitMeasure
					
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

				--SAME CURRENCY AND UOM
			UPDATE Q
			SET dblAmount = dblResult
			FROM tblCTContractQuality Q 
			INNER JOIN @tblTemp tmp on tmp.intContractDetailId = Q.intContractDetailId and tmp.intPropertyId = Q.intPropertyId
			WHERE tmp.intContractDetailId = Q.intContractDetailId 
				  AND tmp.intPropertyId = Q.intPropertyId
				  AND Q.intCurrencyId = Q.intSequenceCurrencyId 
				  AND Q.intUnitMeasureId = Q.intSequenceUnitMeasureId 
				  AND Q.strCostMethod <> 'Percentage'


			--SAME CURRENCY - Different UOM
			UPDATE Q
			SET Q.dblAmount = (ICF.dblUnitQty / ICT.dblUnitQty) * dblResult
			FROM tblCTContractQuality Q
			INNER JOIN tblICItemUOM ICF on Q.intUnitMeasureId = ICF.intUnitMeasureId and Q.intItemId = ICF.intItemId
			INNER JOIN tblICItemUOM ICT on Q.intSequenceUnitMeasureId = ICT.intUnitMeasureId and Q.intItemId = ICT.intItemId
			INNER JOIN @tblTemp tmp on tmp.intContractDetailId = Q.intContractDetailId and tmp.intPropertyId = Q.intPropertyId
			WHERE Q.intCurrencyId = Q.intSequenceCurrencyId 
			      AND Q.intUnitMeasureId <> Q.intSequenceUnitMeasureId 
				  AND Q.strCostMethod <> 'Percentage'

			--PERCENTAGE
			UPDATE Q
			SET Q.dblAmount = CD.dblBasis * dblResult
			FROM tblCTContractQuality Q
			INNER JOIN tblCTContractDetail CD on Q.intContractDetailId = CD.intContractDetailId
			INNER JOIN @tblTemp tmp on tmp.intContractDetailId = Q.intContractDetailId and tmp.intPropertyId = Q.intPropertyId
			WHERE Q.strCostMethod = 'Percentage'

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