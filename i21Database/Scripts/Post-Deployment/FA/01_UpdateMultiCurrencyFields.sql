PRINT N'BEGIN Update tblFAFixedAsset, tblFABookDepreciation and tblFAFixedAssetDepreciation'

CREATE TABLE #tblFACurrentAssets (
	intAssetId INT,
	dblForexRate NUMERIC(16,2),
	ysnProcessed BIT
)

DECLARE 
	@intCurrentAssetId INT,
	@intFunctionalCurrencyId INT,
	@dblForexRate NUMERIC(16, 2) = NULL

INSERT INTO #tblFACurrentAssets
SELECT intAssetId, dblForexRate, 0 FROM tblFAFixedAsset WHERE intFunctionalCurrencyId IS NULL ORDER BY intAssetId

SELECT TOP 1 @intFunctionalCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

WHILE EXISTS(SELECT TOP 1 1 FROM #tblFACurrentAssets WHERE ysnProcessed = 0 ORDER BY intAssetId)
BEGIN
	SELECT TOP 1 @intCurrentAssetId = intAssetId, @dblForexRate = CASE WHEN ISNULL(@dblForexRate, 0) > 0 THEN @dblForexRate ELSE 1 END FROM #tblFACurrentAssets WHERE ysnProcessed = 0 ORDER BY intAssetId 

	UPDATE tblFAFixedAsset
	SET
		dblForexRate = @dblForexRate,
		intFunctionalCurrencyId = @intFunctionalCurrencyId
	WHERE intAssetId = @intCurrentAssetId

	IF EXISTS(SELECT TOP 1 1 FROM tblFABookDepreciation WHERE intAssetId = @intCurrentAssetId)
	BEGIN
		DECLARE @tblBookDep TABLE(
			intBookDepreciationId INT,
			intAssetId INT,
			intBookId INT,
			ysnProcessed BIT
		)
		DECLARE @intCurrentBookId INT, @intBookDepreciationId INT
		
		-- Sync tblFABookDepreciation
		INSERT INTO @tblBookDep SELECT intBookDepreciationId, intAssetId, intBookId, 0 FROM tblFABookDepreciation WHERE intAssetId = @intCurrentAssetId
		
		WHILE EXISTS (SELECT TOP 1 1 FROM @tblBookDep WHERE intAssetId = @intCurrentAssetId AND ysnProcessed = 0)
		BEGIN
			SELECT TOP 1 @intCurrentBookId = intBookId, @intBookDepreciationId = intBookDepreciationId FROM @tblBookDep WHERE intAssetId = @intCurrentAssetId AND ysnProcessed = 0
			
			IF (@intCurrentBookId = 1)
			BEGIN
				UPDATE A 
				SET 
					intCurrencyId = B.intCurrencyId,
					intFunctionalCurrencyId = B.intFunctionalCurrencyId,
					intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId,
					dblRate = B.dblForexRate,
					dblFunctionalCost = ROUND((B.dblCost * B.dblForexRate), 2),
					dblFunctionalSalvageValue = ROUND((B.dblSalvageValue * B.dblForexRate), 2),
					dblInsuranceValue = B.dblInsuranceValue,
					dblFunctionalInsuranceValue = ROUND((B.dblInsuranceValue* B.dblForexRate), 2),
					dblMarketValue = B.dblMarketValue,
					dblFunctionalMarketValue = ROUND((B.dblMarketValue* B.dblForexRate), 2)
				FROM tblFABookDepreciation A 
				JOIN tblFAFixedAsset B 
					ON A.intAssetId = B.intAssetId
				WHERE 
					intBookDepreciationId = @intBookDepreciationId AND 
					intBookId = @intCurrentBookId AND 
					A.intAssetId = @intCurrentAssetId

			END
			ELSE
			BEGIN
				UPDATE A 
				SET 
					intCurrencyId = B.intCurrencyId,
					intFunctionalCurrencyId = B.intFunctionalCurrencyId,
					intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId,
					dblRate = B.dblForexRate,
					dblFunctionalCost = ROUND((A.dblCost * B.dblForexRate), 2),
					dblFunctionalSalvageValue = ROUND((A.dblSalvageValue * B.dblForexRate), 2),
					dblInsuranceValue = B.dblInsuranceValue,
					dblFunctionalInsuranceValue = ROUND((B.dblInsuranceValue * B.dblForexRate), 2),
					dblMarketValue = B.dblMarketValue,
					dblFunctionalMarketValue = ROUND((B.dblMarketValue * B.dblForexRate), 2),
					dblFunctionalBonusDepreciation = CASE WHEN ISNULL(A.dblBonusDepreciation, 0) > 0 THEN ROUND((A.dblBonusDepreciation * B.dblForexRate), 2) ELSE A.dblBonusDepreciation END,
					dblFunctionalSection179 = CASE WHEN ISNULL(A.dblSection179, 0) > 0 THEN ROUND((A.dblSection179 * B.dblForexRate), 2) ELSE A.dblSection179 END
				FROM tblFABookDepreciation A 
				JOIN tblFAFixedAsset B 
					ON A.intAssetId = B.intAssetId
				WHERE 
					intBookDepreciationId = @intBookDepreciationId AND 
					intBookId = @intCurrentBookId AND 
					A.intAssetId = @intCurrentAssetId
			END
			
			-- Update and Sync tblFAFixedAssetDepreciation
			DECLARE @tblDep TABLE(
				intAssetDepreciationId INT,
				intAssetId INT,
				intBookId INT,
				ysnProcessed BIT
			)
			DECLARE @intCurrentAssetDepId INT

			INSERT INTO @tblDep SELECT intAssetDepreciationId, intAssetId, intBookId, 0 FROM tblFAFixedAssetDepreciation WHERE intAssetId = @intCurrentAssetId AND intBookId = @intCurrentBookId ORDER BY intAssetDepreciationId

			WHILE EXISTS(SELECT TOP 1 1 FROM @tblDep WHERE ysnProcessed = 0 AND intAssetId = @intCurrentAssetId AND intBookId = @intCurrentBookId)
			BEGIN
				SELECT TOP 1 @intCurrentAssetDepId = intAssetDepreciationId FROM @tblDep WHERE ysnProcessed = 0 AND intAssetId = @intCurrentAssetId AND intBookId = @intCurrentBookId

				UPDATE tblFAFixedAssetDepreciation
				SET 
					dblRate = @dblForexRate,
					dblFunctionalBasis = ROUND((dblBasis * @dblForexRate), 2),
					dblFunctionalDepreciationToDate = ROUND((dblDepreciationToDate * @dblForexRate), 2),
					dblFunctionalSalvageValue = ROUND((dblSalvageValue * @dblForexRate) , 2)
				WHERE 
					intAssetDepreciationId = @intCurrentAssetDepId AND
					intAssetId = @intCurrentAssetId AND
					intBookId = @intCurrentBookId

				UPDATE @tblDep SET ysnProcessed = 1 
				WHERE intAssetDepreciationId = @intCurrentAssetDepId AND
					intAssetId = @intCurrentAssetId AND
					intBookId = @intCurrentBookId

			END

			-- End Update and Sync tblFAFixedAssetDepreciation

			UPDATE @tblBookDep SET ysnProcessed = 1
			WHERE intBookDepreciationId = @intBookDepreciationId AND intBookId = @intCurrentBookId
		END

		-- End Sync tblFABookDepreciation
	END

	UPDATE #tblFACurrentAssets
	SET ysnProcessed = 1
	WHERE intAssetId = @intCurrentAssetId
END

PRINT N'END Update tblFAFixedAsset, tblFABookDepreciation and tblFAFixedAssetDepreciation'

IF OBJECT_ID('tempdb..#tblFACurrentAssets') IS NOT NULL
BEGIN
	DROP TABLE #tblFACurrentAssets
END