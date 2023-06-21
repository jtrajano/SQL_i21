CREATE PROCEDURE [dbo].[uspRKM2MBasisValidate]
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @PreviousErrMsg NVARCHAR(MAX)
		, @mRowNumber INT
		, @strType NVARCHAR(50) 
		, @strFutMarketName NVARCHAR(200)
		, @strCommodityCode NVARCHAR(200)
		, @strItemNo NVARCHAR(200)
		, @strLocation NVARCHAR(200)
		, @strMarketZone NVARCHAR(200)
		, @strOriginPort NVARCHAR(200)
		, @strDestinationPort NVARCHAR(200)
		, @strCropYear NVARCHAR(200)
		, @strStorageLocation NVARCHAR(200)
		, @strStorageUnit NVARCHAR(200)
		, @strPeriodTo NVARCHAR(200)
		, @strContractType NVARCHAR(200)
		, @strProductType NVARCHAR(200)
		, @strGrade NVARCHAR(200)
		, @strRegion NVARCHAR(200)
		, @strProductLine NVARCHAR(200)
		, @strClass NVARCHAR(200)
		, @strCertification NVARCHAR(MAX)
		, @strMTMPoint NVARCHAR(200)
		, @strCurrency NVARCHAR(200)
		, @strContractInventory NVARCHAR(200)
		, @dblBasis NUMERIC(18, 6)
		, @dblCash NUMERIC(18, 6)
		, @dblRatio NUMERIC(18, 6)
		, @strUnitMeasure NVARCHAR(200)

	DECLARE @ysnIncludeProductInformation BIT
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell BIT
		, @ysnEnterForwardCurveForMarketBasisDifferential BIT
		, @strEvaluationBy NVARCHAR(50)
		, @ysnEvaluationByLocation BIT
		, @ysnEvaluationByMarketZone BIT
		, @ysnEvaluationByOriginPort BIT
		, @ysnEvaluationByDestinationPort BIT
		, @ysnEvaluationByCropYear BIT
		, @ysnEvaluationByStorageLocation BIT
		, @ysnEvaluationByStorageUnit BIT
		, @ysnEnableMTMPoint BIT
	SELECT 
		  @ysnIncludeProductInformation = c.ysnIncludeProductInformation
		, @ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell = c.ysnEnterSeparateMarketBasisDifferentialsForBuyVsSell
		, @ysnEnterForwardCurveForMarketBasisDifferential = c.ysnEnterForwardCurveForMarketBasisDifferential
		, @strEvaluationBy = c.strEvaluationBy
		, @ysnEvaluationByLocation = c.ysnEvaluationByLocation
		, @ysnEvaluationByMarketZone = c.ysnEvaluationByMarketZone
		, @ysnEvaluationByOriginPort = c.ysnEvaluationByOriginPort
		, @ysnEvaluationByDestinationPort = c.ysnEvaluationByDestinationPort
		, @ysnEvaluationByCropYear = c.ysnEvaluationByCropYear
		, @ysnEvaluationByStorageLocation = c.ysnEvaluationByStorageLocation
		, @ysnEvaluationByStorageUnit = c.ysnEvaluationByStorageUnit
		, @ysnEnableMTMPoint = c.ysnEnableMTMPoint
	FROM vyuRKBasisEntryEvaluationConfig c
	
	DECLARE @LatestBasisEntries TABLE(intRowNumber INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strOriginDest NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPeriodTo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractInventory NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblCashOrFuture NUMERIC(16, 10)
		, dblBasisOrDiscount NUMERIC(16, 10)
		, dblRatio NUMERIC(16, 10)
		, strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, intItemId INT
		, intOriginId INT
		, intFutureMarketId INT
		, intFutureMonthId INT
		, intCompanyLocationId INT
		, intMarketZoneId INT
		, intCurrencyId INT
		, intPricingTypeId INT
		, intContractTypeId INT
		, intUnitMeasureId INT
		, intConcurrencyId INT
		, strMarketValuation NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, ysnLicensed BIT
		, intBoardMonthId INT
		, strBoardMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strOriginPort NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intOriginPortId INT
		, strDestinationPort NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intDestinationPortId INT
		, strCropYear NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCropYearId INT
		, strStorageLocation NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intStorageLocationId INT
		, strStorageUnit NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intStorageUnitId INT
		, strProductType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intProductTypeId INT
		, strProductLine NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intProductLineId INT
		, strGrade NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intGradeId INT
		, strCertification NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		, intCertificationId INT
		, strMTMPoint NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intMTMPointId INT
		, strClass NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strRegion NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, ysnEvaluationByLocation BIT
		, ysnEvaluationByMarketZone BIT
		, ysnEvaluationByOriginPort BIT
		, ysnEvaluationByDestinationPort BIT
		, ysnEvaluationByCropYear BIT
		, ysnEvaluationByStorageLocation BIT
		, ysnEvaluationByStorageUnit BIT
		, ysnIncludeProductInformation BIT
		, ysnEnableMTMPoint BIT
	)  

	INSERT INTO @LatestBasisEntries
	EXEC uspRKGetM2MBasis
	
	IF @strEvaluationBy <> 'Item' AND EXISTS(SELECT TOP 1 1
				FROM tblRKM2MBasisImport i
				WHERE i.strContractInventory = 'Inventory')
	BEGIN
		SET @ErrMsg = 'Template contains Inventory records which are only available on Evaluation By = ''Item'' Configuration.'
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
		RETURN
	END

	IF ((SELECT COUNT(1) FROM tblRKM2MBasisImport WHERE strContractInventory = 'Contract') <> 
		(SELECT COUNT(1) FROM @LatestBasisEntries WHERE strContractInventory = 'Contract'))
		OR 
		EXISTS (SELECT TOP 1 1
				FROM tblRKM2MBasisImport i
				LEFT JOIN @LatestBasisEntries t
					ON  RTRIM(LTRIM(REPLACE(ISNULL(t.strFutMarketName, ''), ',','.'))) = ISNULL(i.strFutMarketName, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strCommodityCode, ''), ',','.'))) = ISNULL(i.strCommodityCode, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strItemNo, ''), ',','.'))) = ISNULL(i.strItemNo, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strLocationName, ''), ',','.'))) = ISNULL(i.strLocation, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strMarketZoneCode, ''), ',','.'))) = ISNULL(i.strMarketZone, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strOriginPort, ''), ',','.'))) = ISNULL(i.strOriginPort, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strDestinationPort, ''), ',','.'))) = ISNULL(i.strDestinationPort, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strCropYear, ''), ',','.'))) = ISNULL(i.strCropYear, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strStorageLocation, ''), ',','.'))) = ISNULL(i.strStorageLocation, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strStorageUnit, ''), ',','.'))) = ISNULL(i.strStorageUnit, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strPeriodTo, ''), ',','.'))) = ISNULL(i.strPeriodTo, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strContractType, ''), ',','.'))) = ISNULL(i.strContractType, '')
					AND ((ISNULL(@ysnIncludeProductInformation, 0) = 0)
						  OR
						 (ISNULL(@ysnIncludeProductInformation, 0) = 1
							AND RTRIM(LTRIM(REPLACE(ISNULL(t.strProductType, ''), ',','.'))) = ISNULL(i.strProductType, '')
							AND RTRIM(LTRIM(REPLACE(ISNULL(t.strGrade, ''), ',','.'))) = ISNULL(i.strGrade, '')
							AND RTRIM(LTRIM(REPLACE(ISNULL(t.strProductLine, ''), ',','.'))) = ISNULL(i.strProductLine, '')
							AND RTRIM(LTRIM(REPLACE(ISNULL(t.strClass, ''), ',','.'))) = ISNULL(i.strClass, '')
							AND RTRIM(LTRIM(REPLACE(ISNULL(t.strCertification, ''), ',','.'))) = ISNULL(i.strCertification, '')
						))
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strMTMPoint, ''), ',','.'))) = ISNULL(i.strMTMPoint, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strContractInventory, ''), ',','.'))) = ISNULL(i.strContractInventory, '')
					AND t.strContractInventory = 'Contract'
				WHERE i.strContractInventory = 'Contract'
				AND t.intRowNumber IS NULL
			)
	BEGIN
		SET @ErrMsg = 'Imported file does not match with latest Basis Entry template. Please download a new template and try again.'
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
		RETURN
	END

	IF (SELECT COUNT(DISTINCT strType) FROM tblRKM2MBasisImport) > 1
	BEGIN 
		SET @ErrMsg = 'Import File contains multiple Type values. Should only contain 1 Type.'
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
		RETURN
	END

	IF EXISTS (	SELECT TOP 1 1
				FROM 
				(
					SELECT intRowNumber = ROW_NUMBER() OVER (
										PARTITION BY strType, strFutMarketName, strCommodityCode, strItemNo, CASE WHEN @ysnEvaluationByLocation = 1 THEN strLocation ELSE '' END
										ORDER BY intM2MBasisImportId)
					FROM tblRKM2MBasisImport i
					WHERE i.strContractInventory = 'Inventory'
				) t
				WHERE intRowNumber > 1
			)
	BEGIN
		SET @ErrMsg = 'Import File should only contain Inventory records with distinct values for Type, Commodity' 
						+ CASE WHEN @ysnEvaluationByLocation = 1 THEN ', Item No and Location.' ELSE ' and Item No.' END
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
		RETURN
	END

	SELECT @mRowNumber = MIN(intM2MBasisImportId) FROM tblRKM2MBasisImport
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @PreviousErrMsg = ''
			, @strType = NULL
			, @strFutMarketName = NULL
			, @strCommodityCode = NULL
			, @strItemNo = NULL
			, @strLocation = NULL
			, @strMarketZone = NULL
			, @strOriginPort = NULL
			, @strDestinationPort = NULL
			, @strCropYear = NULL
			, @strStorageLocation = NULL
			, @strStorageUnit = NULL
			, @strPeriodTo = NULL
			, @strContractType = NULL
			, @strProductType = NULL
			, @strGrade = NULL
			, @strRegion = NULL
			, @strProductLine = NULL
			, @strClass = NULL
			, @strCertification = NULL
			, @strMTMPoint = NULL
			, @strCurrency = NULL
			, @strContractInventory = NULL
			, @dblBasis = NULL
			, @dblCash = NULL
			, @dblRatio = NULL
			, @strUnitMeasure = NULL
		
		SELECT  @strType = strType
			, @strFutMarketName = strFutMarketName
			, @strCommodityCode = strCommodityCode
			, @strItemNo = strItemNo
			, @strLocation = strLocation
			, @strMarketZone = strMarketZone
			, @strOriginPort = strOriginPort
			, @strDestinationPort = strDestinationPort
			, @strCropYear = strCropYear
			, @strStorageLocation = strStorageLocation
			, @strStorageUnit = strStorageUnit
			, @strPeriodTo = strPeriodTo
			, @strContractType = strContractType
			, @strProductType = strProductType
			, @strGrade = strGrade
			, @strRegion = strRegion
			, @strProductLine = strProductLine
			, @strClass = strClass
			, @strCertification = strCertification
			, @strMTMPoint = strMTMPoint
			, @strCurrency = strCurrency
			, @strContractInventory = strContractInventory
			, @dblBasis = dblBasis
			, @dblCash = dblCash
			, @dblRatio = dblRatio
			, @strUnitMeasure = strUnitMeasure
		FROM tblRKM2MBasisImport
		WHERE intM2MBasisImportId = @mRowNumber
		
		IF @strType NOT IN ('Mark to Market', 'Stress Test', 'Forecast')
		BEGIN
			SET @PreviousErrMsg = 'Invalid Type ' +  @strType +'. Please select in ''Mark to Market'', ''Stress Test'' or ''Forecast'' '
		END
		
		IF NOT EXISTS(SELECT TOP 1 1 FROM tblICUnitMeasure WHERE strUnitMeasure = @strUnitMeasure)
		BEGIN
			SET @PreviousErrMsg += CASE WHEN @PreviousErrMsg <> '' THEN ', ' ELSE '' END
			SET @PreviousErrMsg += 'Invalid Weight UOM.'
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCurrency WHERE strCurrency = @strCurrency)
		BEGIN
			SET @PreviousErrMsg += CASE WHEN @PreviousErrMsg <> '' THEN ', ' ELSE '' END
			SET @PreviousErrMsg += 'Invalid Currency.'
		END

		-- INVENTORY RECORD VALIDATIONS
		IF @strContractInventory = 'Inventory'
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCommodity WHERE RTRIM(LTRIM(REPLACE(strCommodityCode, ',', '.'))) = @strCommodityCode)
			BEGIN
				SET @PreviousErrMsg += CASE WHEN @PreviousErrMsg <> '' THEN ', ' ELSE '' END
				SET @PreviousErrMsg += 'Invalid Commodity.'
			END

			IF NOT EXISTS(SELECT TOP 1 1 FROM tblICItem WHERE RTRIM(LTRIM(REPLACE(strItemNo, ',', '.'))) = @strItemNo)
			BEGIN
				SET @PreviousErrMsg += CASE WHEN @PreviousErrMsg <> '' THEN ', ' ELSE '' END
				SET @PreviousErrMsg += 'Invalid Item No.'
			END
			
			IF @ysnEvaluationByLocation = 1 AND NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyLocation WHERE RTRIM(LTRIM(REPLACE(strLocationName, ',', '.'))) = @strLocation)
			BEGIN
				SET @PreviousErrMsg += CASE WHEN @PreviousErrMsg <> '' THEN ', ' ELSE '' END
				SET @PreviousErrMsg += 'Invalid Location.'
			END

			IF ((ISNULL(@ysnEvaluationByLocation, 0) = 0 AND ISNULL(@strLocation, '') <> '')
				OR ISNULL(@strMarketZone, '') <> ''
				OR ISNULL(@strOriginPort, '') <> ''
				OR ISNULL(@strDestinationPort, '') <> ''
				OR ISNULL(@strCropYear, '') <> ''
				OR ISNULL(@strStorageLocation, '') <> ''
				OR ISNULL(@strStorageUnit, '') <> ''
				OR ISNULL(@strPeriodTo, '') <> ''
				OR ISNULL(@strContractType, '') <> ''
				--OR ISNULL(@strProductType, '') <> ''
				--OR ISNULL(@strGrade, '') <> ''
				--OR ISNULL(@strRegion, '') <> ''
				--OR ISNULL(@strProductLine, '') <> ''
				--OR ISNULL(@strClass, '') <> ''
				OR REPLACE(ISNULL(@strCertification, ''), ',','') <> ''
				OR ISNULL(@strMTMPoint, '') <> ''
			)
			BEGIN 
				SET @PreviousErrMsg += CASE WHEN @PreviousErrMsg <> '' THEN ', ' ELSE '' END
				SET @PreviousErrMsg += 'Invalid Inventory Record - Columns to be filled out are Type, Commodity, Item No,' + 
							CASE WHEN @ysnEvaluationByLocation = 1 THEN ' Location,' ELSE '' END + 
							' Currency, Cash, Basis, Weight UOM and Ratio only.'
			END
		END

		IF (ISNULL(LTRIM(@PreviousErrMsg), '') <> '')
		BEGIN
			INSERT INTO tblRKM2MBasisImport_ErrLog (
				  strType
				, strFutMarketName
				, strCommodityCode
				, strItemNo
				, strLocation
				, strMarketZone
				, strOriginPort
				, strDestinationPort
				, strCropYear
				, strStorageLocation
				, strStorageUnit
				, strPeriodTo
				, strContractType
				, strProductType
				, strGrade
				, strRegion
				, strProductLine
				, strClass
				, strCertification
				, strMTMPoint
				, strCurrency
				, strContractInventory
				, strUnitMeasure
				, dblCash
				, dblBasis
				, dblRatio
				, strErrMessage)
			VALUES (
			      @strType
				, @strFutMarketName
				, @strCommodityCode
				, @strItemNo
				, @strLocation
				, @strMarketZone
				, @strOriginPort
				, @strDestinationPort
				, @strCropYear
				, @strStorageLocation
				, @strStorageUnit
				, @strPeriodTo
				, @strContractType
				, @strProductType
				, @strGrade
				, @strRegion
				, @strProductLine
				, @strClass
				, @strCertification
				, @strMTMPoint
				, @strCurrency
				, @strContractInventory
				, @strUnitMeasure
				, @dblCash
				, @dblBasis
				, @dblRatio
				, @PreviousErrMsg)
		END
		
		SELECT @mRowNumber = MIN(intM2MBasisImportId) FROM tblRKM2MBasisImport WHERE intM2MBasisImportId > @mRowNumber
	END

	-- BRING BACK COMMAS ON MULTI-CERTIFICATION RECORDS.
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblRKM2MBasisImport_ErrLog)
	BEGIN 
		UPDATE i
		SET   i.strFutMarketName = t.strFutMarketName
			, i.strCommodityCode = t.strCommodityCode
			, i.strItemNo = t.strItemNo
			, i.strLocation = t.strLocationName
			, i.strMarketZone = t.strMarketZoneCode
			, i.strOriginPort = t.strOriginPort
			, i.strDestinationPort = t.strDestinationPort
			, i.strCropYear = t.strCropYear
			, i.strStorageLocation = t.strStorageLocation
			, i.strStorageUnit = t.strStorageUnit
			, i.strPeriodTo = t.strPeriodTo
			, i.strProductType = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strProductType ELSE NULL END
			, i.strGrade = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strGrade ELSE NULL END
			, i.strProductLine = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strProductLine ELSE NULL END
			, i.strClass = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strClass ELSE NULL END
			, i.strCertification = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strCertification ELSE NULL END
			, i.strMTMPoint = t.strMTMPoint
		FROM tblRKM2MBasisImport i
		INNER JOIN @LatestBasisEntries t
			ON  RTRIM(LTRIM(REPLACE(ISNULL(t.strFutMarketName, ''), ',','.'))) = ISNULL(i.strFutMarketName, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strCommodityCode, ''), ',','.'))) = ISNULL(i.strCommodityCode, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strItemNo, ''), ',','.'))) = ISNULL(i.strItemNo, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strLocationName, ''), ',','.'))) = ISNULL(i.strLocation, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strMarketZoneCode, ''), ',','.'))) = ISNULL(i.strMarketZone, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strOriginPort, ''), ',','.'))) = ISNULL(i.strOriginPort, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strDestinationPort, ''), ',','.'))) = ISNULL(i.strDestinationPort, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strCropYear, ''), ',','.'))) = ISNULL(i.strCropYear, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strStorageLocation, ''), ',','.'))) = ISNULL(i.strStorageLocation, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strStorageUnit, ''), ',','.'))) = ISNULL(i.strStorageUnit, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strPeriodTo, ''), ',','.'))) = ISNULL(i.strPeriodTo, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strContractType, ''), ',','.'))) = ISNULL(i.strContractType, '')
			AND ((ISNULL(@ysnIncludeProductInformation, 0) = 0)
					OR
					(ISNULL(@ysnIncludeProductInformation, 0) = 1
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strProductType, ''), ',','.'))) = ISNULL(i.strProductType, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strGrade, ''), ',','.'))) = ISNULL(i.strGrade, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strProductLine, ''), ',','.'))) = ISNULL(i.strProductLine, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strClass, ''), ',','.'))) = ISNULL(i.strClass, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strCertification, ''), ',','.'))) = ISNULL(i.strCertification, '')
				))
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strMTMPoint, ''), ',','.'))) = ISNULL(i.strMTMPoint, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strContractInventory, ''), ',','.'))) = ISNULL(i.strContractInventory, '')
			AND t.strContractInventory = 'Contract'
		WHERE i.strContractInventory = 'Contract'

		UPDATE i
		SET   i.strFutMarketName = t.strFutMarketName
			, i.strCommodityCode = t.strCommodityCode
			, i.strItemNo = t.strItemNo
			, i.strLocation = t.strLocationName
			, i.strMarketZone = t.strMarketZoneCode
			, i.strOriginPort = t.strOriginPort
			, i.strDestinationPort = t.strDestinationPort
			, i.strCropYear = t.strCropYear
			, i.strStorageLocation = t.strStorageLocation
			, i.strStorageUnit = t.strStorageUnit
			, i.strPeriodTo = t.strPeriodTo
			, i.strProductType = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strProductType ELSE NULL END
			, i.strGrade = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strGrade ELSE NULL END
			, i.strProductLine = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strProductLine ELSE NULL END
			, i.strClass = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strClass ELSE NULL END
			, i.strCertification = CASE WHEN ISNULL(@ysnIncludeProductInformation, 0) = 1 THEN t.strCertification ELSE NULL END
			, i.strMTMPoint = t.strMTMPoint
		FROM tblRKM2MBasisImport i
		INNER JOIN @LatestBasisEntries t
			ON  RTRIM(LTRIM(REPLACE(ISNULL(t.strFutMarketName, ''), ',','.'))) = ISNULL(i.strFutMarketName, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strCommodityCode, ''), ',','.'))) = ISNULL(i.strCommodityCode, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strItemNo, ''), ',','.'))) = ISNULL(i.strItemNo, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strLocationName, ''), ',','.'))) = ISNULL(i.strLocation, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strMarketZoneCode, ''), ',','.'))) = ISNULL(i.strMarketZone, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strOriginPort, ''), ',','.'))) = ISNULL(i.strOriginPort, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strDestinationPort, ''), ',','.'))) = ISNULL(i.strDestinationPort, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strCropYear, ''), ',','.'))) = ISNULL(i.strCropYear, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strStorageLocation, ''), ',','.'))) = ISNULL(i.strStorageLocation, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strStorageUnit, ''), ',','.'))) = ISNULL(i.strStorageUnit, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strPeriodTo, ''), ',','.'))) = ISNULL(i.strPeriodTo, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strContractType, ''), ',','.'))) = ISNULL(i.strContractType, '')
			AND ((ISNULL(@ysnIncludeProductInformation, 0) = 0)
					OR
					(ISNULL(@ysnIncludeProductInformation, 0) = 1
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strProductType, ''), ',','.'))) = ISNULL(i.strProductType, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strGrade, ''), ',','.'))) = ISNULL(i.strGrade, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strProductLine, ''), ',','.'))) = ISNULL(i.strProductLine, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strClass, ''), ',','.'))) = ISNULL(i.strClass, '')
					AND RTRIM(LTRIM(REPLACE(ISNULL(t.strCertification, ''), ',','.'))) = ISNULL(i.strCertification, '')
				))
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strMTMPoint, ''), ',','.'))) = ISNULL(i.strMTMPoint, '')
			AND RTRIM(LTRIM(REPLACE(ISNULL(t.strContractInventory, ''), ',','.'))) = ISNULL(i.strContractInventory, '')
			AND t.strContractInventory = 'Inventory'
		WHERE i.strContractInventory = 'Inventory'
	END
		
	SELECT DISTINCT 
		  intBasisImportErrId
		, intConcurrencyId = 0
		, strType
		, strFutMarketName
		, strCommodityCode
		, strItemNo
		, strLocation
		, strMarketZone
		, strOriginPort
		, strDestinationPort
		, strCropYear
		, strStorageLocation
		, strStorageUnit
		, strPeriodTo
		, strContractType
		, strProductType
		, strGrade
		, strRegion
		, strProductLine
		, strClass
		, strCertification
		, strMTMPoint
		, strCurrency
		, strContractInventory
		, strUnitMeasure
		, dblCash
		, dblBasis
		, dblRatio
		, strErrMessage
	FROM tblRKM2MBasisImport_ErrLog
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH