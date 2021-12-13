CREATE PROCEDURE uspCTSaveContractSamplePremium @intContractDetailId INT
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
		INSERT INTO @tblTemp
		EXEC uspQMGetSamplePremiumTestResult @intSampleId

		IF Exists(SELECT TOP 1 1 FROM tblCTContractQuality where intSampleId = @intSampleId)
		BEGIN
			DELETE FROM tblCTContractQuality where intSampleId = @intSampleId
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
		)
		SELECT	intSampleId, 
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
				1,
				CASE WHEN ISNULL(strActualValue, '') = '' THEN 0 ELSE CAST(strActualValue as Numeric(18,6)) END AS dblActualValue
		FROM @tblTemp

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
