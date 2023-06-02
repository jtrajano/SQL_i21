CREATE PROCEDURE [dbo].[uspQMImportCatalogueMain] @intImportLogId INT
AS
BEGIN TRY
	-- B1
	DECLARE @strItemLog			NVARCHAR(MAX)
		  , @strUnitMeasureLog	NVARCHAR(MAX)
		  ,@strPackageType nvarchar(50) 
		  ,@intPackageTypeId int
		  ,@dblTareWeight Numeric(18,6)
		  ,@intWgtUnitMeasureId Numeric(18,6)

	BEGIN TRANSACTION

	-- Validate Foreign Key Fields
	UPDATE IMP
	SET strLogResult = 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage), charindex(',', reverse(MSG.strLogMessage)) + 1, len(MSG.strLogMessage)))
		,ysnSuccess = 0
		,ysnProcessed = 1
	FROM tblQMImportCatalogue IMP
	-- Company Location
	LEFT JOIN tblSMCompanyLocation TBO ON TBO.strLocationName = IMP.strBuyingCenter
	-- Grade
	LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.strType = 'Grade'
		AND GRADE.strDescription = IMP.strGrade
	-- Manufacturing Leaf Type
	LEFT JOIN tblICCommodityAttribute LEAF_TYPE ON LEAF_TYPE.strType = 'ProductType'
		AND LEAF_TYPE.strDescription = IMP.strManufacturingLeafType
	-- Season
	LEFT JOIN tblICCommodityAttribute SEASON ON SEASON.strType = 'Season'
		AND SEASON.strDescription = IMP.strColour
	-- Garden Mark
	LEFT JOIN tblQMGardenMark GARDEN ON GARDEN.strGardenMark = IMP.strGardenMark
	-- Producer
	LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = GARDEN.intProducerId
	-- Producer Type
	LEFT JOIN tblEMEntityType ProdType ON ProdType.intEntityId = Producer.intEntityId AND ProdType.strType = 'Producer'
	-- Garden Geo Origin
	LEFT JOIN tblSMCountry ORIGIN ON ORIGIN.strISOCode = IMP.strGardenGeoOrigin AND ISNULL(ORIGIN.strISOCode, '') <> ''
	-- Sustainability
	LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.strDescription = IMP.strSustainability
	-- Evaluator's Code at TBO
	LEFT JOIN vyuQMSearchEntityUser ECTBO ON ECTBO.strUser = IMP.strEvaluatorsCodeAtTBO
	-- From Location Code
	--LEFT JOIN tblSMCity FROM_LOC_CODE ON FROM_LOC_CODE.strCity = IMP.strFromLocationCode
	-- Channel
	LEFT JOIN tblARMarketZone MARKET_ZONE ON MARKET_ZONE.strMarketZoneCode = IMP.strChannel
	-- Sample Type
	LEFT JOIN tblQMSampleType SAMPLE_TYPE ON IMP.strSampleTypeName IS NOT NULL
		AND SAMPLE_TYPE.strSampleTypeName = IMP.strSampleTypeName
	-- Net Weight Per Packages / Quantity UOM
	LEFT JOIN tblICUnitMeasure UOM ON IMP.strNoOfPackagesUOM IS NOT NULL
		AND UOM.strSymbol = IMP.strNoOfPackagesUOM
	-- Net Weight 2nd Package-Break / Quantity UOM
	LEFT JOIN tblICUnitMeasure UOM2 ON IMP.strNoOfPackagesSecondPackageBreakUOM IS NOT NULL
		AND UOM2.strSymbol = IMP.strNoOfPackagesSecondPackageBreakUOM
	-- Net Weight 3rd Package-Break / Quantity UOM
	LEFT JOIN tblICUnitMeasure UOM3 ON IMP.strNoOfPackagesThirdPackageBreakUOM IS NOT NULL
		AND UOM3.strSymbol = IMP.strNoOfPackagesThirdPackageBreakUOM
	-- Broker
	LEFT JOIN vyuEMSearchEntityBroker BROKERS ON IMP.strBroker IS NOT NULL
		AND BROKERS.strName = IMP.strBroker
	---- Receiving Storage Location
	--LEFT JOIN (
	--	tblSMCompanyLocationSubLocation RSL INNER JOIN tblSMCompanyLocation TBO2 ON TBO2.intCompanyLocationId = RSL.intCompanyLocationId
	--	) ON IMP.strReceivingStorageLocation IS NOT NULL
	--	AND RSL.strSubLocationName = IMP.strReceivingStorageLocation
	--	AND TBO2.strLocationName = IMP.strBuyingCenter
	-- Warehouse Code
	LEFT JOIN tblSMCompanyLocationSubLocation WAREHOUSE_CODE ON WAREHOUSE_CODE.strSubLocationName = IMP.strWarehouseCode AND WAREHOUSE_CODE.intCompanyLocationId = TBO.intCompanyLocationId
	-- Format log message
	OUTER APPLY (
		SELECT strLogMessage = CASE 
				WHEN (
						GRADE.intCommodityAttributeId IS NULL
						--AND ISNULL(IMP.strGrade, '') <> ''
						)
					THEN 'GRADE, '
				ELSE ''
				END + CASE 
				WHEN (
						LEAF_TYPE.intCommodityAttributeId IS NULL
						--AND ISNULL(IMP.strManufacturingLeafType, '') <> ''
						)
					THEN 'MANUFACTURING LEAF TYPE, '
				ELSE ''
				END 
				--+ CASE 
				--WHEN (
				--		SEASON.intCommodityAttributeId IS NULL
				--		AND ISNULL(IMP.strColour, '') <> ''
				--		)
				--	THEN 'SEASON, '
				--ELSE ''
				--END 
				+ CASE 
				WHEN (
						GARDEN.intGardenMarkId IS NULL
						--AND ISNULL(IMP.strGardenMark, '') <> ''
						)
					THEN 'GARDEN MARK, '
				ELSE ''
				END + CASE 
				WHEN (
						Producer.intEntityId IS NULL
						--AND ISNULL(IMP.strGardenMark, '') <> ''
						)
					THEN 'Proudcer ID, '
				ELSE ''
				END + CASE 
				WHEN (
						ORIGIN.intCountryID IS NULL
						--AND ISNULL(IMP.strGardenGeoOrigin, '') <> ''
						)
					THEN 'GARDEN GEO ORIGIN, '
				ELSE ''
				END + CASE 
				WHEN (
						IMP.strChannel = 'AUC' AND
						WAREHOUSE_CODE.intCompanyLocationSubLocationId IS NULL
						--AND ISNULL(IMP.strWarehouseCode, '') <> ''
						)
					THEN 'WAREHOUSE CODE, '
				ELSE ''
				END + CASE 
				WHEN (
						SUSTAINABILITY.intCommodityProductLineId IS NULL
						AND ISNULL(IMP.strSustainability, '') <> ''
						)
					THEN 'SUSTAINABILITY, '
				ELSE ''
				END + CASE 
				WHEN (
						ECTBO.intUserId IS NULL
						AND ISNULL(IMP.strEvaluatorsCodeAtTBO, '') <> ''
						)
					THEN 'EVALUATORS CODE AT TBO, '
				ELSE ''
				END 
				--+ CASE 
				--WHEN (
				--		FROM_LOC_CODE.intCityId IS NULL
				--		AND ISNULL(IMP.strFromLocationCode, '') <> ''
				--		)
				--	THEN 'FROM LOCATION CODE, '
				--ELSE ''
				--END 
				+ CASE 
				WHEN (
						MARKET_ZONE.intMarketZoneId IS NULL
						--AND ISNULL(IMP.strChannel, '') <> ''
						)
					THEN 'CHANNEL, '
				ELSE ''
				END + CASE 
				WHEN (
						SAMPLE_TYPE.intSampleTypeId IS NULL
						AND ISNULL(IMP.strSampleTypeName, '') <> ''
						)
					THEN 'SAMPLE TYPE, '
				ELSE ''
				END + CASE 
				WHEN (
						UOM.intUnitMeasureId IS NULL
						--AND ISNULL(IMP.strNoOfPackagesUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.intNoOfPackages, 0) <> 0
						AND ISNULL(IMP.strNoOfPackagesUOM, '') = ''
						)
					THEN 'NO OF PACKAGES UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						UOM2.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strNoOfPackagesSecondPackageBreakUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.intNoOfPackagesSecondPackageBreak, 0) <> 0
						AND ISNULL(IMP.strNoOfPackagesSecondPackageBreakUOM, '') = ''
						)
					THEN 'NO OF PACKAGES UOM (2ND PACKAGE-BREAK), '
				ELSE ''
				END + CASE 
				WHEN (
						UOM3.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strNoOfPackagesThirdPackageBreakUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.intNoOfPackagesThirdPackageBreak, 0) <> 0
						AND ISNULL(IMP.strNoOfPackagesThirdPackageBreakUOM, '') = ''
						)
					THEN 'NO OF PACKAGES UOM (3RD PACKAGE-BREAK), '
				ELSE ''
				END + CASE 
				WHEN (
						BROKERS.intEntityId IS NULL
						AND ISNULL(IMP.strBroker, '') <> ''
						)
					THEN 'BROKER, '
				ELSE ''
				END 
				--+ CASE 
				--WHEN (
				--		RSL.intCompanyLocationSubLocationId IS NULL
				--		AND ISNULL(IMP.strReceivingStorageLocation, '') <> ''
				--		)
				--	THEN 'RECEIVING STORAGE LOCATION, '
				--ELSE ''
				--END
				+ CASE 
				WHEN (
						IMP.strPackageType = ''
						)
					THEN 'PACKAGE TYPE, '
				ELSE ''
				END
				+ CASE 
				WHEN (
						IMP.strChopNumber  = ''
						)
					THEN 'CHOP NUMBER, '
				ELSE ''
				END
				+ CASE 
				WHEN (
						IsDate(IMP.dtmManufacturingDate)=0
						)
					THEN 'MANUFACTURING DATE, '
				ELSE ''
				END
				+ CASE 
				WHEN (
						IsNumeric(IMP.dblTotalQtyOffered )=0
						)
					THEN 'TOTAL QTY OFFERED, '
				ELSE ''
				END
				+ CASE 
				WHEN (
						IsNumeric(IMP.intTotalNumberOfPackageBreakups)=0
						)
					THEN 'TOTAL NUMBER OF PACKAGE BREAKUPS, '
				ELSE ''
				END
				+ CASE 
				WHEN (
						 IsNumeric(IMP.intNoOfPackages )=0
						)
					THEN 'NO OF PACKAGES, '
				ELSE ''
				END
				+ CASE 
				WHEN (
						IMP.strChannel = 'AUC' AND
						IsDate(IMP.dtmSaleDate)=0
						)
					THEN 'SALE DATE, '
				ELSE ''
				END
				
		) MSG
	WHERE IMP.intImportLogId = @intImportLogId
		AND IMP.ysnSuccess = 1
		AND ISNULL(IMP.strBatchNo, '') = '' -- Validation does not apply to pre-shipment sample
		AND (
			(
				GRADE.intCommodityAttributeId IS NULL
				--AND ISNULL(IMP.strGrade, '') <> ''
				)
			OR (
				LEAF_TYPE.intCommodityAttributeId IS NULL
				--AND ISNULL(IMP.strManufacturingLeafType, '') <> ''
				)
			--OR (
			--	SEASON.intCommodityAttributeId IS NULL
			--	AND ISNULL(IMP.strColour, '') <> ''
			--	)
			OR (
				GARDEN.intGardenMarkId IS NULL
				--AND ISNULL(IMP.strGardenMark, '') <> ''
				)
			OR (
				Producer.intEntityId IS NULL
				--AND ISNULL(IMP.strGardenMark, '') <> ''
				)
			OR (
				ORIGIN.intCountryID IS NULL
				--AND ISNULL(IMP.strGardenGeoOrigin, '') <> ''
				)
			OR (
				IMP.strChannel = 'AUC' AND
				WAREHOUSE_CODE.intCompanyLocationSubLocationId IS NULL
				--AND ISNULL(IMP.strWarehouseCode, '') <> ''
				)
			OR (
				SUSTAINABILITY.intCommodityProductLineId IS NULL
				AND ISNULL(IMP.strSustainability, '') <> ''
				)
			OR (
				ECTBO.intUserId IS NULL
				AND ISNULL(IMP.strEvaluatorsCodeAtTBO, '') <> ''
				)
			--OR (
			--	FROM_LOC_CODE.intCityId IS NULL
			--	AND ISNULL(IMP.strFromLocationCode, '') <> ''
			--	)
			OR (
				MARKET_ZONE.intMarketZoneId IS NULL
				--AND ISNULL(IMP.strChannel, '') <> ''
				)
			OR (
				SAMPLE_TYPE.intSampleTypeId IS NULL
				AND ISNULL(IMP.strSampleTypeName, '') <> ''
				)
			OR (
				(
					UOM.intUnitMeasureId IS NULL
					--AND ISNULL(IMP.strNoOfPackagesUOM, '') <> ''
					)
				OR (
					ISNULL(IMP.intNoOfPackages, 0) <> 0
					AND ISNULL(IMP.strNoOfPackagesUOM, '') = ''
					)
				)
			OR (
				(
					UOM2.intUnitMeasureId IS NULL
					AND ISNULL(IMP.strNoOfPackagesSecondPackageBreakUOM, '') <> ''
					)
				OR (
					ISNULL(IMP.intNoOfPackagesSecondPackageBreak, 0) <> 0
					AND ISNULL(IMP.strNoOfPackagesSecondPackageBreakUOM, '') = ''
					)
				)
			OR (
				(
					UOM3.intUnitMeasureId IS NULL
					AND ISNULL(IMP.strNoOfPackagesThirdPackageBreakUOM, '') <> ''
					)
				OR (
					ISNULL(IMP.intNoOfPackagesThirdPackageBreak, 0) <> 0
					AND ISNULL(IMP.strNoOfPackagesThirdPackageBreakUOM, '') = ''
					)
				)
			OR (
				BROKERS.intEntityId IS NULL
				AND ISNULL(IMP.strBroker, '') <> ''
				)
			--OR (
			--	RSL.intCompanyLocationSubLocationId IS NULL
			--	AND ISNULL(IMP.strReceivingStorageLocation, '') <> ''
			--	)
				OR ISNULL(IMP.strPackageType , '') = ''
				OR ISNULL(IMP.strChopNumber , '') = ''
				OR IsDate(IMP.dtmManufacturingDate)=0
				OR IsNumeric(IMP.dblTotalQtyOffered )=0
				OR IsNumeric(IMP.intTotalNumberOfPackageBreakups)=0
				OR IsNumeric(IMP.intNoOfPackages )=0
				OR (IsDate(IMP.dtmSaleDate )=0 AND IMP.strChannel = 'AUC')
			)

	-- Check if vendor is mapped to the TBO
	UPDATE IMP
	SET strLogResult = 'Supplier ' + E.strName + ' is not maintained in location ' + CL.strLocationName
		,ysnSuccess = 0
		,ysnProcessed = 1
	FROM tblQMImportCatalogue IMP
	INNER JOIN tblSMCompanyLocation CL ON CL.strLocationName = IMP.strBuyingCenter
	INNER JOIN vyuAPVendor E ON E.strName = IMP.strSupplier
	WHERE IMP.intImportLogId = @intImportLogId
		AND ISNULL(IMP.strBatchNo, '') = ''
		AND (
			NOT EXISTS (
				SELECT 1
				FROM tblAPVendorCompanyLocation V
				WHERE V.intEntityVendorId = E.intEntityId
					AND V.intCompanyLocationId = CL.intCompanyLocationId
				)
			OR NOT EXISTS (
				SELECT 1
				FROM tblEMEntity E2
				LEFT JOIN tblAPVendorCompanyLocation V2 ON E2.intEntityId = V2.intEntityVendorId
				WHERE V2.intVendorCompanyLocationId IS NULL
				)
			)

	-- End Validation
	DECLARE @intImportType INT
		,@strSampleNumber NVARCHAR(30)
		,@intImportCatalogueId INT
		,@intSaleYearId INT
		,@strSaleYear NVARCHAR(50)
		,@intMixingUnitLocationId INT
		,@intTBOLocationId INT
		,@strSaleNumber NVARCHAR(50)
		,@intCatalogueTypeId INT
		,@strCatalogueType NVARCHAR(50)
		,@intSupplierEntityId INT
		,@strRefNo NVARCHAR(30)
		,@strChopNumber NVARCHAR(50)
		,@intGradeId INT
		,@strGrade NVARCHAR(50)
		,@intManufacturingLeafTypeId INT
		,@strManufacturingLeafType NVARCHAR(50)
		,@intSeasonId INT
		,@strSeason NVARCHAR(50)
		,@dblGrossWeight NUMERIC(18, 6)
		,@intGardenMarkId INT
		,@intProducerId INT
		,@strGardenMark NVARCHAR(100)
		,@intOriginId INT
		,@strCountry NVARCHAR(100)
		,@intCompanyLocationSubLocationId INT
		,@dtmManufacturingDate DATETIME
		,@dblSampleQty NUMERIC(18, 6)
		,@intTotalNumberOfPackageBreakups BIGINT
		,@intNetWtPerPackagesUOMId INT
		,@intRepresentingUOMId INT
		,@intNoOfPackages BIGINT
		,@intNetWtSecondPackageBreakUOMId INT
		,@intNoOfPackagesSecondPackageBreak BIGINT
		,@intNetWtThirdPackageBreakUOMId INT
		,@intNoOfPackagesThirdPackageBreak BIGINT
		,@intProductLineId INT
		,@strProductLine NVARCHAR(50)
		,@ysnOrganic BIT
		,@dtmSaleDate DATETIME
		,@dtmPromptDate DATETIME
		,@strComments NVARCHAR(MAX)
		,@str3PLStatus NVARCHAR(50)
		,@strAdditionalSupplierReference NVARCHAR(50)
		,@intAWBSampleReceived BIGINT
		,@strAWBSampleReference NVARCHAR(50)
		,@strCourierRef NVARCHAR(50)
		,@dblBasePrice NUMERIC(18, 6)
		,@ysnBoughtAsReserve BIT
		,@ysnEuropeanCompliantFlag BIT
		,@intEvaluatorsCodeAtTBOId INT
		,@strEvaluatorsCodeAtTBO NVARCHAR(50)
		,@strComments3 NVARCHAR(MAX)
		,@intFromLocationCodeId INT
		,@strFromLocationCode NVARCHAR(50)
		,@intDestinationStorageLocationId INT
		,@strSampleBoxNumber NVARCHAR(50)
		,@strMarketZoneCode NVARCHAR(100)
		,@intMarketZoneId INT
		,@intSampleTypeId INT
		,@strBatchNo NVARCHAR(50)
		,@intEntityUserId INT
		,@dtmDateCreated DATETIME
		,@intBrokerId INT
		,@strBroker NVARCHAR(100)
		,@strBuyingOrderNumber NVARCHAR(50)
		,@intSubBookId INT
		,@intBatchId INT
		,@strTINNumber NVARCHAR(100)
		,@intCropYearId INT
	DECLARE @intSampleId INT
	DECLARE @intItemId INT
	DECLARE @intCategoryId INT
	DECLARE @intValidDate INT

	SELECT @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	SELECT TOP 1 @intItemId = [intDefaultItemId]
		,@intCategoryId = I.intCategoryId
	FROM tblQMCatalogueImportDefaults CID
	INNER JOIN tblICItem I ON I.intItemId = CID.intDefaultItemId

	-- Loop through each valid import detail
	DECLARE @C AS CURSOR;

	SET @C = CURSOR FAST_FORWARD
	FOR

	SELECT intImportType = 1 -- Auction/Non-Action Sample Import
		,intImportCatalogueId = IMP.intImportCatalogueId
		,intSaleYearId = SY.intSaleYearId
		,strSaleYear = SY.strSaleYear
		,intMixingUnitLocationId = NULL
		,intTBOLocationId = TBO.intCompanyLocationId
		,strSaleNumber = IMP.strSaleNumber
		,intCatalogueTypeId = CT.intCatalogueTypeId
		,strCatalogueType = CT.strCatalogueType
		,intSupplierEntityId = E.intEntityId
		,strRefNo = IMP.strLotNumber
		,strChopNumber = IMP.strChopNumber
		,intGradeId = GRADE.intCommodityAttributeId
		,strGrade = GRADE.strDescription
		,intManufacturingLeafTypeId = LEAF_TYPE.intCommodityAttributeId
		,strManufacturingLeafType = LEAF_TYPE.strDescription
		,intSeasonId = SEASON.intCommodityAttributeId
		,strSeason = SEASON.strDescription
		,dblGrossWeight = IMP.dblGrossWeight
		,intGardenMarkId = GARDEN.intGardenMarkId
		,intProducerId = Producer.intEntityId
		,strGardenMark = GARDEN.strGardenMark
		,intOriginId = CA.intCommodityAttributeId
		,strCountry = CA.strDescription
		,intCompanyLocationSubLocationId = WAREHOUSE_CODE.intCompanyLocationSubLocationId
		,dtmManufacturingDate = IMP.dtmManufacturingDate
		,dblSampleQty = IMP.dblTotalQtyOffered
		,intTotalNumberOfPackageBreakups = IMP.intTotalNumberOfPackageBreakups
		,intNetWtPerPackagesUOMId = UOM.intUnitMeasureId
		,intRepresentingUOMId = UOM.intUnitMeasureId
		,intNoOfPackages = IMP.intNoOfPackages
		,intNetWtSecondPackageBreakUOMId = UOM2.intUnitMeasureId
		,intNoOfPackagesSecondPackageBreak = IMP.intNoOfPackagesSecondPackageBreak
		,intNetWtThirdPackageBreakUOMId = UOM3.intUnitMeasureId
		,intNoOfPackagesThirdPackageBreak = IMP.intNoOfPackagesThirdPackageBreak
		,intProductLineId = SUSTAINABILITY.intCommodityProductLineId
		,strProductLine = SUSTAINABILITY.strDescription
		,ysnOrganic = IMP.ysnOrganic
		,dtmSaleDate = IMP.dtmSaleDate
		,dtmPromptDate = IMP.dtmPromptDate
		,strComments = IMP.strRemarks
		,str3PLStatus = IMP.str3PLStatus
		,strAdditionalSupplierReference = IMP.strAdditionalSupplierReference
		,intAWBSampleReceived = IMP.intAWBSampleReceived
		,strAWBSampleReference = IMP.strAWBSampleReference
		,strCourierRef = IMP.strAirwayBillNumberCode
		,dblBasePrice = IMP.dblBasePrice
		,ysnBoughtAsReserve = IMP.ysnBoughtAsReserve
		,ysnEuropeanCompliantFlag = IMP.ysnEuropeanCompliantFlag
		,intEvaluatorsCodeAtTBOId = ECTBO.intUserId
		,strEvaluatorsCodeAtTBO = ECTBO.strUser
		,strComments3 = IMP.strEvaluatorsRemarks
		,intFromLocationCodeId = FROM_LOC_CODE.intCityId
		,strFromLocationCode = FROM_LOC_CODE.strCity
		,intStorageLocationId = RSL.intCompanyLocationSubLocationId
		,strSampleBoxNumber = IMP.strSampleBoxNumberTBO
		,strMarketZoneCode = MARKET_ZONE.strMarketZoneCode
		,intMarketZoneId = MARKET_ZONE.intMarketZoneId
		,intSampleTypeId = SAMPLE_TYPE.intSampleTypeId
		,strBatchNo = IMP.strBatchNo
		,intEntityUserId = IL.intEntityId
		,dtmDateCreated = GETDATE()
		,intBrokerId = BROKERS.intEntityId
		,strBroker = BROKERS.strName
		,strBuyingOrderNumber = IMP.strBuyingOrderNumber
		,intBatchId = NULL
		,strTINNumber = NULL
		,intSubBookId = STRATEGY.intSubBookId
		,strPackageType=strPackageType
		,SeasonCropYear.intCropYearId
		,intWgtUnitMeasureId=B1PUOM.intUnitMeasureId
	FROM tblQMImportCatalogue IMP
	INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
	-- Sale Year
	LEFT JOIN tblQMSaleYear SY ON SY.strSaleYear = IMP.strSaleYear
	-- Sale Number
	LEFT JOIN tblQMSample AS S ON IMP.strSaleNumber = S.strSampleNumber
	-- Company Location
	LEFT JOIN tblSMCompanyLocation TBO ON TBO.strLocationName = IMP.strBuyingCenter
	-- Catalogue Type
	LEFT JOIN tblQMCatalogueType CT ON CT.strCatalogueType = IMP.strCatalogueType
	-- Supplier
	LEFT JOIN (
		tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
		) ON E.strName = IMP.strSupplier
	-- Grade
	LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.strType = 'Grade'
		AND GRADE.strDescription = IMP.strGrade
	-- Manufacturing Leaf Type
	LEFT JOIN tblICCommodityAttribute LEAF_TYPE ON LEAF_TYPE.strType = 'ProductType'
		AND LEAF_TYPE.strDescription = IMP.strManufacturingLeafType
	-- Season
	LEFT JOIN tblICCommodityAttribute SEASON ON SEASON.strType = 'Season'
		AND SEASON.strDescription = IMP.strColour
	-- Garden Mark
	LEFT JOIN tblQMGardenMark GARDEN ON GARDEN.strGardenMark = IMP.strGardenMark
	-- PRODUCER
	LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = GARDEN.intProducerId 
	-- Producer Type
	LEFT JOIN tblEMEntityType ProdType ON ProdType.intEntityId = Producer.intEntityId AND ProdType.strType = 'Producer'
	-- Garden Geo Origin
	LEFT JOIN (
		tblICCommodityAttribute CA INNER JOIN tblSMCountry ORIGIN ON ORIGIN.intCountryID = CA.intCountryID
		) ON ORIGIN.strISOCode = IMP.strGardenGeoOrigin
	-- Warehouse Code
	LEFT JOIN tblSMCompanyLocationSubLocation WAREHOUSE_CODE ON WAREHOUSE_CODE.strSubLocationName = IMP.strWarehouseCode AND WAREHOUSE_CODE.intCompanyLocationId = TBO.intCompanyLocationId
	-- Sustainability
	LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.strDescription = IMP.strSustainability
	-- Evaluator's Code at TBO
	LEFT JOIN vyuQMSearchEntityUser ECTBO ON ECTBO.strUser = IMP.strEvaluatorsCodeAtTBO
	-- From Location Code
	LEFT JOIN tblSMCity FROM_LOC_CODE ON FROM_LOC_CODE.strCity = IMP.strFromLocationCode
	-- Channel
	LEFT JOIN tblARMarketZone MARKET_ZONE ON MARKET_ZONE.strMarketZoneCode = IMP.strChannel
	-- Sample Type
	LEFT JOIN tblQMSampleType SAMPLE_TYPE ON IMP.strSampleTypeName IS NOT NULL
		AND SAMPLE_TYPE.strSampleTypeName = IMP.strSampleTypeName
	-- Net Weight Per Packages / Quantity UOM
	LEFT JOIN tblICUnitMeasure UOM ON IMP.strNoOfPackagesUOM IS NOT NULL
		AND UOM.strSymbol = IMP.strNoOfPackagesUOM
	-- Net Weight 2nd Package-Break / Quantity UOM
	LEFT JOIN tblICUnitMeasure UOM2 ON IMP.strNoOfPackagesSecondPackageBreakUOM IS NOT NULL
		AND UOM2.strSymbol = IMP.strNoOfPackagesSecondPackageBreakUOM
	-- Net Weight 3rd Package-Break / Quantity UOM
	LEFT JOIN tblICUnitMeasure UOM3 ON IMP.strNoOfPackagesThirdPackageBreakUOM IS NOT NULL
		AND UOM3.strSymbol = IMP.strNoOfPackagesThirdPackageBreakUOM
	-- Broker
	LEFT JOIN vyuEMSearchEntityBroker BROKERS ON IMP.strBroker IS NOT NULL
		AND BROKERS.strName = IMP.strBroker
	-- Receiving Storage Location
	LEFT JOIN tblSMCompanyLocation MU ON MU.strLocationName = IMP.strB1GroupNumber
	LEFT JOIN tblSMCompanyLocationSubLocation RSL ON IMP.strReceivingStorageLocation IS NOT NULL
		AND RSL.strSubLocationName = IMP.strReceivingStorageLocation
		AND RSL.intCompanyLocationId = MU.intCompanyLocationId
	LEFT JOIN tblMFBatch BATCH_MU ON BATCH_MU.strBatchId = IMP.strBatchNo
		AND BATCH_MU.intLocationId = MU.intCompanyLocationId
	-- Buyer1 Quantity UOM
	LEFT JOIN tblICUnitMeasure B1QUOM ON B1QUOM.strSymbol = IMP.strB1QtyUOM
	-- Buyer1 Price UOM
	LEFT JOIN tblICUnitMeasure B1PUOM ON B1PUOM.strSymbol = IMP.strB1PriceUOM
	-- Buyer1 Group Number
	LEFT JOIN tblCTBook BOOK ON BOOK.strBook = IMP.strB1GroupNumber
	-- Strategy
	LEFT JOIN tblCTSubBook STRATEGY ON IMP.strStrategy IS NOT NULL
		AND STRATEGY.strSubBook = IMP.strStrategy
		AND STRATEGY.intBookId = BOOK.intBookId
	OUTER APPLY (SELECT TOP 1 intCropYearId
				 FROM tblCTCropYear
				 WHERE strCropYear = IMP.strSeason) AS SeasonCropYear
	WHERE IMP.intImportLogId = @intImportLogId
		AND ISNULL(BATCH_MU.strBatchId, '') = ''
		AND IMP.ysnSuccess = 1
	
	UNION ALL
	
	SELECT intImportType = 2 -- Pre-Shipment Sample Import
		,intImportCatalogueId = IMP.intImportCatalogueId
		,intSaleYearId = NULL
		,strSaleYear = NULL
		,intMixingUnitLocationId = MU.intCompanyLocationId
		,intTBOLocationId = TBO.intCompanyLocationId
		,strSaleNumber = IMP.strSaleNumber
		,intCatalogueTypeId = NULL
		,strCatalogueType = NULL
		,intSupplierEntityId = NULL
		,strRefNo = NULL
		,strChopNumber = NULL
		,intGradeId = NULL
		,strGrade = NULL
		,intManufacturingLeafTypeId = NULL
		,strManufacturingLeafType = NULL
		,intSeasonId = NULL
		,strSeason = NULL
		,dblGrossWeight = NULL
		,intGardenMarkId = NULL
		,intProducerId = NULL
		,strGardenMark = NULL
		,intOriginId = NULL
		,strCountry = NULL
		,intCompanyLocationSubLocationId = NULL
		,dtmManufacturingDate = NULL
		,dblSampleQty = NULL
		,intTotalNumberOfPackageBreakups = NULL
		,intNetWtPerPackagesUOMId = NULL
		,intRepresentingUOMId = NULL
		,intNoOfPackages = NULL
		,intNetWtSecondPackageBreakUOMId = NULL
		,intNoOfPackagesSecondPackageBreak = NULL
		,intNetWtThirdPackageBreakUOMId = NULL
		,intNoOfPackagesThirdPackageBreak = NULL
		,intProductLineId = NULL
		,strProductLine = NULL
		,ysnOrganic = NULL
		,dtmSaleDate = NULL
		,dtmPromptDate = NULL
		,strComments = NULL
		,str3PLStatus = NULL
		,strAdditionalSupplierReference = NULL
		,intAWBSampleReceived = NULL
		,strAWBSampleReference = NULL
		,strCourierRef = NULL
		,dblBasePrice = NULL
		,ysnBoughtAsReserve = NULL
		,ysnEuropeanCompliantFlag = NULL
		,intEvaluatorsCodeAtTBOId = NULL
		,strEvaluatorsCodeAtTBO = NULL
		,strComments3 = NULL
		,intFromLocationCodeId = NULL
		,strFromLocationCode = NULL
		,intStorageLocationId = NULL
		,strSampleBoxNumber = NULL
		,strMarketZoneCode = NULL
		,intMarketZoneId = NULL
		,intSampleTypeId = SAMPLE_TYPE.intSampleTypeId
		,strBatchNo = BATCH_TBO.strBatchId
		,intEntityUserId = IL.intEntityId
		,dtmDateCreated = GETDATE()
		,intBrokerId = NULL
		,strBroker = NULL
		,strBuyingOrderNumber = NULL
		,intBatchId = BATCH_TBO.intBatchId
		,strTINNumber = IMP.strTINNumber
		,intSubBookId = NULL
		,strPackageType=strPackageType
		,SeasonCropYear.intCropYearId
		,intWgtUnitMeasureId=NULL
	FROM tblQMImportCatalogue IMP
	INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
	-- Sample Type
	LEFT JOIN tblQMSampleType SAMPLE_TYPE ON IMP.strSampleTypeName IS NOT NULL
		AND SAMPLE_TYPE.strSampleTypeName = IMP.strSampleTypeName
	-- Sale Number
	LEFT JOIN tblQMSample AS S ON IMP.strSaleNumber = S.strSampleNumber
	-- Mixing Location
	LEFT JOIN tblSMCompanyLocation MU
		ON MU.strLocationName = CASE WHEN ISNULL(IMP.strGroupNumber, '') <> '' AND ISNULL(IMP.strContractNumber, '') <> '' THEN IMP.strGroupNumber ELSE IMP.strB1GroupNumber END
	-- Batch MU
	LEFT JOIN tblMFBatch BATCH_MU ON BATCH_MU.strBatchId = IMP.strBatchNo
		AND BATCH_MU.intLocationId = MU.intCompanyLocationId
	-- Company Location
	LEFT JOIN tblSMCompanyLocation TBO ON TBO.intCompanyLocationId = BATCH_MU.intBuyingCenterLocationId
	-- Batch TBO
	LEFT JOIN tblMFBatch BATCH_TBO ON BATCH_TBO.strBatchId = BATCH_MU.strBatchId
		AND BATCH_TBO.intLocationId = TBO.intCompanyLocationId
	OUTER APPLY (SELECT TOP 1 intCropYearId
				 FROM tblCTCropYear
				 WHERE strCropYear = IMP.strSeason) AS SeasonCropYear
	WHERE IMP.intImportLogId = @intImportLogId
		AND ISNULL(BATCH_MU.strBatchId, '') <> ''
		AND IMP.ysnSuccess = 1

	OPEN @C

	FETCH NEXT
	FROM @C
	INTO @intImportType
		,@intImportCatalogueId
		,@intSaleYearId
		,@strSaleYear
		,@intMixingUnitLocationId
		,@intTBOLocationId
		,@strSaleNumber
		,@intCatalogueTypeId
		,@strCatalogueType
		,@intSupplierEntityId
		,@strRefNo
		,@strChopNumber
		,@intGradeId
		,@strGrade
		,@intManufacturingLeafTypeId
		,@strManufacturingLeafType
		,@intSeasonId
		,@strSeason
		,@dblGrossWeight
		,@intGardenMarkId
		,@intProducerId
		,@strGardenMark
		,@intOriginId
		,@strCountry
		,@intCompanyLocationSubLocationId
		,@dtmManufacturingDate
		,@dblSampleQty
		,@intTotalNumberOfPackageBreakups
		,@intNetWtPerPackagesUOMId
		,@intRepresentingUOMId
		,@intNoOfPackages
		,@intNetWtSecondPackageBreakUOMId
		,@intNoOfPackagesSecondPackageBreak
		,@intNetWtThirdPackageBreakUOMId
		,@intNoOfPackagesThirdPackageBreak
		,@intProductLineId
		,@strProductLine
		,@ysnOrganic
		,@dtmSaleDate
		,@dtmPromptDate
		,@strComments
		,@str3PLStatus
		,@strAdditionalSupplierReference
		,@intAWBSampleReceived
		,@strAWBSampleReference
		,@strCourierRef
		,@dblBasePrice
		,@ysnBoughtAsReserve
		,@ysnEuropeanCompliantFlag
		,@intEvaluatorsCodeAtTBOId
		,@strEvaluatorsCodeAtTBO
		,@strComments3
		,@intFromLocationCodeId
		,@strFromLocationCode
		,@intDestinationStorageLocationId
		,@strSampleBoxNumber
		,@strMarketZoneCode
		,@intMarketZoneId
		,@intSampleTypeId
		,@strBatchNo
		,@intEntityUserId
		,@dtmDateCreated
		,@intBrokerId
		,@strBroker
		,@strBuyingOrderNumber
		,@intBatchId
		,@strTINNumber
		,@intSubBookId
		,@strPackageType
		,@intCropYearId
		,@intWgtUnitMeasureId

	WHILE @@FETCH_STATUS = 0
	BEGIN
		Select @intPackageTypeId=NULL,@dblTareWeight=0
		SELECT @intPackageTypeId = intUnitMeasureId
		FROM tblICUnitMeasure 
		WHERE strUnitMeasure = @strPackageType;

		Select @dblTareWeight=dblConversionToStock  from tblICUnitMeasureConversion 
		Where intUnitMeasureId=@intPackageTypeId

		SET @intSampleId = NULL

		-- Check if Batch ID is supplied in the template
		IF @intBatchId IS NOT NULL
		BEGIN
			DECLARE @intProductValueId INT
				,@intOriginalItemId INT
			DECLARE @ysnCreate BIT

			SET @ysnCreate = 0

			IF @intMixingUnitLocationId IS NULL
			BEGIN
				UPDATE tblQMImportCatalogue
				SET strLogResult = 'BUYER1 GROUP NAME is required if the BATCH NO is supplied'
					,ysnProcessed = 1
					,ysnSuccess = 0
				WHERE intImportCatalogueId = @intImportCatalogueId

				GOTO CONT
			END

			DECLARE @intBatchSampleId INT

			SET @intBatchSampleId = NULL

			SELECT TOP 1 @intBatchSampleId = intSampleId
			FROM tblQMSample
			WHERE strBatchNo = @strBatchNo
				AND intSampleTypeId = @intSampleTypeId
				AND intCompanyLocationId = @intMixingUnitLocationId

			SELECT @intProductValueId = NULL

			SELECT @intProductValueId = intBatchId
			FROM tblMFBatch
			WHERE strBatchId = @strBatchNo
				AND intLocationId = @intMixingUnitLocationId			

			-- Insert new sample with product type = 13
			IF @intBatchSampleId IS NULL AND @intProductValueId IS NOT NULL
				BEGIN
					DECLARE @intItemInsert				INT
						  , @intRepresentingUOMInsert	INT;

					SELECT @intItemInsert = S.intItemId
						 , @intRepresentingUOMInsert = S.intRepresentingUOMId
					FROM tblQMSample S
					INNER JOIN tblMFBatch B ON B.intSampleId = S.intSampleId
					WHERE B.intBatchId = @intBatchId
				
					/* Item UOM Validation. */
					IF @intImportType =1 AND NOT EXISTS (SELECT * FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId = @intRepresentingUOMId)
						BEGIN	
							SELECT @strItemLog = strItemNo
							FROM tblICItem 
							WHERE intItemId = @intItemId;

							SELECT @strUnitMeasureLog = strUnitMeasure
							FROM tblICUnitMeasure 
							WHERE intUnitMeasureId = @intRepresentingUOMId;

							UPDATE tblQMImportCatalogue
							SET strLogResult = 'Unit of Measure '''+ IsNULL(@strUnitMeasureLog,'') +''' does not exists on Item ''' + IsNULL(@strItemLog,'') +'''.' 
								,ysnProcessed = 1
								,ysnSuccess = 0
							WHERE intImportCatalogueId = @intImportCatalogueId;

							GOTO CONT
						END

					--New Sample Creation
					EXEC uspMFGeneratePatternId @intCategoryId = NULL
						,@intItemId = NULL
						,@intManufacturingId = NULL
						,@intSubLocationId = NULL
						,@intLocationId = @intMixingUnitLocationId
						,@intOrderTypeId = NULL
						,@intBlendRequirementId = NULL
						,@intPatternCode = 62
						,@ysnProposed = 0
						,@strPatternString = @strSampleNumber OUTPUT

					SET @ysnCreate = 1

					-- Insert Entry in Sample Table
					INSERT INTO tblQMSample (
						intConcurrencyId
						,intSampleTypeId
						,strSampleNumber
						,intProductTypeId
						,intProductValueId
						,intSampleStatusId
						,intItemId
						,intCountryID
						,intEntityId
						,dtmSampleReceivedDate
						,dblSampleQty
						,dblRepresentingQty
						,intSampleUOMId
						,intRepresentingUOMId
						,strRepresentLotNumber
						,dtmTestingStartDate
						,dtmTestingEndDate
						,dtmSamplingEndDate
						,strCountry
						,intLocationId
						,intCompanyLocationId
						,intCompanyLocationSubLocationId
						,strComment
						,intCreatedUserId
						,dtmCreated
						,intBookId
						,intSubBookId
						-- Auction Fields
						,intSaleYearId
						,strSaleNumber
						,dtmSaleDate
						,intCatalogueTypeId
						,dtmPromptDate
						,strChopNumber
						,intGradeId
						,intManufacturingLeafTypeId
						,intSeasonId
						,intGardenMarkId
						,intProducerId
						,dtmManufacturingDate
						,intTotalNumberOfPackageBreakups
						,intNetWtPerPackagesUOMId
						,intNoOfPackages
						,intNetWtSecondPackageBreakUOMId
						,intNoOfPackagesSecondPackageBreak
						,intNetWtThirdPackageBreakUOMId
						,intNoOfPackagesThirdPackageBreak
						,intProductLineId
						,ysnOrganic
						,dblGrossWeight
						,strBatchNo
						,str3PLStatus
						,strAdditionalSupplierReference
						,intAWBSampleReceived
						,strAWBSampleReference
						,dblBasePrice
						,ysnBoughtAsReserve
						,ysnEuropeanCompliantFlag
						,intEvaluatorsCodeAtTBOId
						,intFromLocationCodeId
						,intDestinationStorageLocationId
						,strSampleBoxNumber
						,strComments3
						,intBrokerId
						,intPackageTypeId
						,dblTareWeight
						,strCourierRef
						,intCropYearId
						,intMarketZoneId
						,intCurrencyId
						)
					-- ,intTINClearanceId
					SELECT intConcurrencyId = 1
						,intSampleTypeId = @intSampleTypeId
						,strSampleNumber = @strSampleNumber
						,intProductTypeId = 13 -- Batch
						,intProductValueId = @intProductValueId
						,intSampleStatusId = 1 -- Received
						,intItemId = S.intItemId
						,intCountryID = S.intCountryID
						,intEntityId = S.intEntityId
						,dtmSampleReceivedDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
						,dblSampleQty = S.dblSampleQty
						,dblRepresentingQty = S.dblRepresentingQty
						,intSampleUOMId = S.intSampleUOMId
						,intRepresentingUOMId = S.intRepresentingUOMId
						,strRepresentLotNumber = S.strRepresentLotNumber
						,dtmTestingStartDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
						,dtmTestingEndDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
						,dtmSamplingEndDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
						,strCountry = S.strCountry
						,intLocationId = B.intMixingUnitLocationId
						,intCompanyLocationId = B.intMixingUnitLocationId
						,intCompanyLocationSubLocationId = NULL
						,strComment = S.strComment
						,intCreatedUserId = @intEntityUserId
						,dtmCreated = @dtmDateCreated
						,intBookId = S.intBookId
						,intSubBookId = S.intSubBookId
						-- Auction Fields
						,intSaleYearId = S.intSaleYearId
						,strSaleNumber = @strSaleNumber
						,dtmSaleDate = S.dtmSaleDate
						,intCatalogueTypeId = S.intCatalogueTypeId
						,dtmPromptDate = S.dtmPromptDate
						,strChopNumber = S.strChopNumber
						,intGradeId = S.intGradeId
						,intManufacturingLeafTypeId = S.intManufacturingLeafTypeId
						,intSeasonId = S.intSeasonId
						,intGardenMarkId = S.intGardenMarkId
						,intProducerId = S.intProducerId
						,dtmManufacturingDate = S.dtmManufacturingDate
						,intTotalNumberOfPackageBreakups = S.intTotalNumberOfPackageBreakups
						,intNetWtPerPackagesUOMId = S.intNetWtPerPackagesUOMId
						,intNoOfPackages = S.intNoOfPackages
						,intNetWtSecondPackageBreakUOMId = S.intNetWtSecondPackageBreakUOMId
						,intNoOfPackagesSecondPackageBreak = S.intNoOfPackagesSecondPackageBreak
						,intNetWtThirdPackageBreakUOMId = S.intNetWtThirdPackageBreakUOMId
						,intNoOfPackagesThirdPackageBreak = S.intNoOfPackagesThirdPackageBreak
						,intProductLineId = S.intProductLineId
						,ysnOrganic = S.ysnOrganic
						,dblGrossWeight = S.dblGrossWeight
						,strBatchNo = @strBatchNo
						,str3PLStatus = S.str3PLStatus
						,strAdditionalSupplierReference = S.strAdditionalSupplierReference
						,intAWBSampleReceived = S.intAWBSampleReceived
						,strAWBSampleReference = S.strAWBSampleReference
						,dblBasePrice = S.dblBasePrice
						,ysnBoughtAsReserve = S.ysnBoughtAsReserve
						,ysnEuropeanCompliantFlag = S.ysnEuropeanCompliantFlag
						,intEvaluatorsCodeAtTBOId = S.intEvaluatorsCodeAtTBOId
						,intFromLocationCodeId = S.intFromLocationCodeId
						,intDestinationStorageLocationId = S.intDestinationStorageLocationId
						,strSampleBoxNumber = S.strSampleBoxNumber
						,strComments3 = S.strComments3
						,intBrokerId = S.intBrokerId
						,intPackageTypeId=@intPackageTypeId
						,dblTareWeight=@dblTareWeight
						,strCourierRef = @strCourierRef
						,@intCropYearId
						,intMarketZoneId = S.intMarketZoneId
						,intCurrencyId = S.intCurrencyId
					FROM tblQMSample S
					INNER JOIN tblMFBatch B ON B.intSampleId = S.intSampleId
					WHERE B.intBatchId = @intBatchId

					SET @intSampleId = SCOPE_IDENTITY()

					EXEC uspQMGenerateSampleCatalogueImportAuditLog @intSampleId = @intSampleId
						,@intUserEntityId = @intEntityUserId
						,@strRemarks = 'Created from Catalogue Import'
						,@ysnCreate = 1
						,@ysnBeforeUpdate = 1

					SELECT @intOriginalItemId = NULL

					SELECT @intOriginalItemId = intTealingoItemId
					FROM tblMFBatch
					WHERE intBatchId = @intProductValueId

					if @intImportType=1
					Begin
						UPDATE dbo.tblMFBatch
						SET intSampleId = @intSampleId
							,intTealingoItemId = @intItemId
							,intOriginalItemId = @intOriginalItemId
						WHERE intBatchId = @intProductValueId
					End

					-- Sample Detail
					INSERT INTO tblQMSampleDetail (
						intConcurrencyId
						,intSampleId
						,intAttributeId
						,strAttributeValue
						,intListItemId
						,ysnIsMandatory
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						)
					SELECT 1
						,@intSampleId
						,A.intAttributeId
						,ISNULL(A.strAttributeValue, '') AS strAttributeValue
						,A.intListItemId
						,ST.ysnIsMandatory
						,@intEntityUserId
						,@dtmDateCreated
						,@intEntityUserId
						,@dtmDateCreated
					FROM tblQMSampleTypeDetail ST
					JOIN tblQMAttribute A ON A.intAttributeId = ST.intAttributeId
					WHERE ST.intSampleTypeId = @intSampleTypeId

				/* End of Insert new sample with product type = 13 */
				END

			/* Update if existing sample exists. */
			ELSE
				BEGIN
					EXEC uspQMGenerateSampleCatalogueImportAuditLog @intSampleId = @intBatchSampleId
						,@intUserEntityId = @intEntityUserId
						,@strRemarks = 'Updated from Catalogue Import'
						,@ysnCreate = 0
						,@ysnBeforeUpdate = 1

					SELECT @intOriginalItemId = NULL

					SELECT @intOriginalItemId = intItemId
					FROM tblQMSample
					WHERE intSampleId = @intBatchSampleId

					UPDATE S
					SET intConcurrencyId = S.intConcurrencyId + 1
					  , intLastModifiedUserId = @intEntityUserId
					  , dtmLastModified = @dtmDateCreated
					  , intItemId = @intItemId
					  , dblB1QtyBought = null
					  , intB1QtyUOMId = null
					  , dblB1Price = null
					  , intB1PriceUOMId = null
					  , intBookId = null
					  ,intPackageTypeId=@intPackageTypeId
					  ,dblTareWeight=@dblTareWeight
					FROM tblQMSample S
					WHERE S.intSampleId = @intBatchSampleId

					SET @intSampleId = @intBatchSampleId


					IF @intImportType=1
					BEGIN
						UPDATE tblMFBatch
						SET intTealingoItemId = @intItemId
							,intOriginalItemId = @intOriginalItemId
						WHERE intBatchId = @intProductValueId
					END
				END

				/* Item UOM Validation. */
				IF @intImportType =1 AND NOT EXISTS (SELECT * FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId = @intRepresentingUOMId)
					BEGIN
						SELECT @strItemLog = strItemNo
						FROM tblICItem 
						WHERE intItemId = @intItemId;

						SELECT @strUnitMeasureLog = strUnitMeasure
						FROM tblICUnitMeasure 
						WHERE intUnitMeasureId = @intRepresentingUOMId;

						UPDATE tblQMImportCatalogue
						SET strLogResult = 'Unit of Measure '''+ @strUnitMeasureLog +''' does not exists on Item ''' + @strItemLog +'''.' 
							,ysnProcessed = 1
							,ysnSuccess = 0
						WHERE intImportCatalogueId = @intImportCatalogueId;

						GOTO CONT
					END

				IF @strTINNumber IS NOT NULL
					BEGIN
						DECLARE @strOldTINNumber NVARCHAR(100)
							,@intOldCompanyLocationId INT

						-- Insert / Update TIN number linked to the sample / batch
						SELECT @strOldTINNumber = TIN.strTINNumber
							,@intOldCompanyLocationId = B.intLocationId
						FROM tblQMTINClearance TIN
						INNER JOIN tblQMSample S ON S.intTINClearanceId = TIN.intTINClearanceId
						OUTER APPLY (
							SELECT intBatchId
								,intLocationId
							FROM tblMFBatch
							WHERE intBatchId = @intProductValueId
							) B
						WHERE S.intSampleId = @intSampleId

						IF ISNULL(@strOldTINNumber, '') <> IsNULL(@strTINNumber, '') 
							OR ISNULL(@intOldCompanyLocationId, 0) <> @intMixingUnitLocationId
						BEGIN
							-- Delink old TIN number if there's an existing one and the TIN number has changed.
							IF @strOldTINNumber IS NOT NULL
							BEGIN
								EXEC uspQMUpdateTINBatchId @strTINNumber = @strOldTINNumber
									,@intBatchId = @intProductValueId
									,@intCompanyLocationId = @intOldCompanyLocationId
									,@intEntityId = @intEntityUserId
									,@ysnDelink = 1
							END

							-- Link new TIN number with the pre-shipment sample / batch
							EXEC uspQMUpdateTINBatchId @strTINNumber = @strTINNumber
								,@intBatchId = @intProductValueId
								,@intCompanyLocationId = @intMixingUnitLocationId
								,@intEntityId = @intEntityUserId
								,@ysnDelink = 0

							UPDATE tblQMSample
							SET intTINClearanceId = (
									SELECT TOP 1 intTINClearanceId
									FROM tblQMTINClearance
									WHERE strTINNumber = @strTINNumber
										AND intBatchId = @intProductValueId
										AND intCompanyLocationId = @intMixingUnitLocationId
									)
							WHERE intSampleId = @intSampleId

						END
					END

				UPDATE tblQMImportCatalogue
				SET intSampleId = @intSampleId
				WHERE intImportCatalogueId = @intImportCatalogueId

				GOTO CONT

				END

		SELECT @intSampleId = S.intSampleId
		FROM tblQMSample S
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
		INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
		INNER JOIN (
			tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
			) ON V.intEntityId = S.intEntityId
		LEFT JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
		WHERE SY.strSaleYear = @strSaleYear
			AND CL.intCompanyLocationId = @intTBOLocationId
			AND S.strSaleNumber = @strSaleNumber
			AND CT.intCatalogueTypeId = @intCatalogueTypeId
			AND E.intEntityId = @intSupplierEntityId
			AND S.strRepresentLotNumber = @strRefNo

		-- If sample does not exist yet
		IF @intSampleId IS NULL
		BEGIN
			-- Assign sample type based on mapping table if it is not supplied in the template
			IF @intSampleTypeId IS NULL
				AND @strMarketZoneCode IS NOT NULL
				SELECT @intSampleTypeId = MZSTM.intSampleTypeId
				FROM tblQMMarketZoneSampleTypeMapping MZSTM
				INNER JOIN tblARMarketZone MZ ON MZ.intMarketZoneId = MZSTM.intMarketZoneId
				WHERE MZ.strMarketZoneCode = @strMarketZoneCode

			--New Sample Creation
			EXEC uspMFGeneratePatternId @intCategoryId = NULL
				,@intItemId = NULL
				,@intManufacturingId = NULL
				,@intSubLocationId = NULL
				,@intLocationId = @intTBOLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 62
				,@ysnProposed = 0
				,@strPatternString = @strSampleNumber OUTPUT

			/* Item UOM Validation. */
			IF NOT EXISTS (SELECT * FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId = @intRepresentingUOMId)
				BEGIN
					SELECT @strItemLog = strItemNo
					FROM tblICItem 
					WHERE intItemId = @intItemId;

					SELECT @strUnitMeasureLog = strUnitMeasure
					FROM tblICUnitMeasure 
					WHERE intUnitMeasureId = @intRepresentingUOMId;

					UPDATE tblQMImportCatalogue
					SET strLogResult = 'Unit of Measure '''+ @strUnitMeasureLog +''' does not exists on Item ''' + @strItemLog +'''.' 
						,ysnProcessed = 1
						,ysnSuccess = 0
					WHERE intImportCatalogueId = @intImportCatalogueId;

					GOTO CONT
				END

			-- Insert Entry in Sample Table
			INSERT INTO tblQMSample (
				intConcurrencyId
				,intSampleTypeId
				,strSampleNumber
				,intProductTypeId
				,intProductValueId
				,intSampleStatusId
				,intItemId
				,intCountryID
				,intEntityId
				,dtmSampleReceivedDate
				,dblSampleQty
				,dblRepresentingQty
				,intSampleUOMId
				,intRepresentingUOMId
				,strRepresentLotNumber
				,dtmTestingStartDate
				,dtmTestingEndDate
				,dtmSamplingEndDate
				,strCountry
				,intLocationId
				,intCompanyLocationId
				,intCompanyLocationSubLocationId
				,strComment
				,intCreatedUserId
				,dtmCreated
				,intMarketZoneId
				,intSubBookId
				-- Auction Fields
				,intSaleYearId
				,strSaleNumber
				,dtmSaleDate
				,intCatalogueTypeId
				,dtmPromptDate
				,strChopNumber
				,intGradeId
				,intManufacturingLeafTypeId
				,intSeasonId
				,intGardenMarkId
				,intProducerId
				,dtmManufacturingDate
				,intTotalNumberOfPackageBreakups
				,intNetWtPerPackagesUOMId
				,intNoOfPackages
				,intNetWtSecondPackageBreakUOMId
				,intNoOfPackagesSecondPackageBreak
				,intNetWtThirdPackageBreakUOMId
				,intNoOfPackagesThirdPackageBreak
				,intProductLineId
				,ysnOrganic
				,dblGrossWeight
				,strBatchNo
				,str3PLStatus
				,strAdditionalSupplierReference
				,intAWBSampleReceived
				,strAWBSampleReference
				,dblBasePrice
				,ysnBoughtAsReserve
				,ysnEuropeanCompliantFlag
				,intEvaluatorsCodeAtTBOId
				,intFromLocationCodeId
				-- ,intDestinationStorageLocationId
				,strSampleBoxNumber
				,strComments3
				,intBrokerId
				,intPackageTypeId 
				,dblTareWeight
				,intCropYearId
				,intCurrencyId
				,intBookId
				)
			-- ,strBuyingOrderNo
			SELECT intConcurrencyId = 1
				,intSampleTypeId = @intSampleTypeId
				,strSampleNumber = @strSampleNumber
				,intProductTypeId = 2 -- Item
				,intProductValueId = @intItemId
				,intSampleStatusId = 1 -- Received
				,intItemId = @intItemId
				,intCountryID = @intOriginId
				,intEntityId = @intSupplierEntityId
				,dtmSampleReceivedDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
				,dblSampleQty = @dblSampleQty
				,dblRepresentingQty = (
					SELECT
						-- No of Packages
						CASE 
							WHEN ISNULL(@intNoOfPackages, 0) > 0
								THEN CAST(@intNoOfPackages AS NUMERIC(18, 6))
							ELSE 0
							END
						-- No of Packages 2nd Break
						+ CASE 
							WHEN ISNULL(@intNoOfPackagesSecondPackageBreak, 0) > 0
								THEN dbo.fnCalculateQtyBetweenUOM(IUOM2.intItemUOMId, IUOM1.intItemUOMId, CAST(@intNoOfPackagesSecondPackageBreak AS NUMERIC(18, 6)))
							ELSE 0
							END
						-- No of Packages 3nd Break
						+ CASE 
							WHEN ISNULL(@intNoOfPackagesThirdPackageBreak, 0) > 0
								THEN dbo.fnCalculateQtyBetweenUOM(IUOM3.intItemUOMId, IUOM1.intItemUOMId, CAST(@intNoOfPackagesThirdPackageBreak AS NUMERIC(18, 6)))
							ELSE 0
							END
					FROM tblICItemUOM IUOM1
					LEFT JOIN tblICItemUOM IUOM2 ON IUOM1.intItemId = IUOM2.intItemId
						AND IUOM2.intUnitMeasureId = @intNetWtSecondPackageBreakUOMId
					LEFT JOIN tblICItemUOM IUOM3 ON IUOM1.intItemId = IUOM3.intItemId
						AND IUOM3.intUnitMeasureId = @intNetWtThirdPackageBreakUOMId
					WHERE IUOM1.intItemId = @intItemId
						AND IUOM1.intUnitMeasureId = @intRepresentingUOMId
					)
				,intSampleUOMId = IsNULL(@intWgtUnitMeasureId,(
					SELECT TOP 1 [intDefaultSampleUOMId]
					FROM tblQMCatalogueImportDefaults
					))
				,intRepresentingUOMId = @intRepresentingUOMId
				,strRepresentLotNumber = @strRefNo
				,dtmTestingStartDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
				,dtmTestingEndDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
				,dtmSamplingEndDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
				,strCountry = @strCountry
				,intLocationId = @intTBOLocationId
				,intCompanyLocationId = @intTBOLocationId
				,intCompanyLocationSubLocationId = @intCompanyLocationSubLocationId
				,strComment = @strComments
				,intCreatedUserId = @intEntityUserId
				,dtmCreated = @dtmDateCreated
				,intMarketZoneId = @intMarketZoneId
				,intSubBookId = @intSubBookId
				-- Auction Fields
				,intSaleYearId = @intSaleYearId
				,strSaleNumber = @strSaleNumber
				,dtmSaleDate = @dtmSaleDate
				,intCatalogueTypeId = @intCatalogueTypeId
				,dtmPromptDate = @dtmPromptDate
				,strChopNumber = @strChopNumber
				,intGradeId = @intGradeId
				,intManufacturingLeafTypeId = @intManufacturingLeafTypeId
				,intSeasonId = @intSeasonId
				,intGardenMarkId = @intGardenMarkId
				,intProducerId = @intProducerId
				,dtmManufacturingDate = @dtmManufacturingDate
				,intTotalNumberOfPackageBreakups = @intTotalNumberOfPackageBreakups
				,intNetWtPerPackagesUOMId = @intNetWtPerPackagesUOMId
				,intNoOfPackages = @intNoOfPackages
				,intNetWtSecondPackageBreakUOMId = @intNetWtSecondPackageBreakUOMId
				,intNoOfPackagesSecondPackageBreak = @intNoOfPackagesSecondPackageBreak
				,intNetWtThirdPackageBreakUOMId = @intNetWtThirdPackageBreakUOMId
				,intNoOfPackagesThirdPackageBreak = @intNoOfPackagesThirdPackageBreak
				,intProductLineId = @intProductLineId
				,ysnOrganic = @ysnOrganic
				,dblGrossWeight = @dblGrossWeight
				,strBatchNo = @strBatchNo
				,str3PLStatus = @str3PLStatus
				,strAdditionalSupplierReference = @strAdditionalSupplierReference
				,intAWBSampleReceived = @intAWBSampleReceived
				,strAWBSampleReference = @strAWBSampleReference
				,dblBasePrice = @dblBasePrice
				,ysnBoughtAsReserve = @ysnBoughtAsReserve
				,ysnEuropeanCompliantFlag = @ysnEuropeanCompliantFlag
				,intEvaluatorsCodeAtTBOId = @intEvaluatorsCodeAtTBOId
				,intFromLocationCodeId = @intFromLocationCodeId
				-- ,intDestinationStorageLocationId = @intDestinationStorageLocationId
				,strSampleBoxNumber = @strSampleBoxNumber
				,strComments3 = @strComments3
				,intBrokerId = @intBrokerId
				,intPackageTypeId =@intPackageTypeId
				,dblTareWeight=@dblTareWeight
				,intCropYearId = @intCropYearId

				-- Populated for bulking process only
				,intCurrencyId = (SELECT CUR.intCurrencyID
									FROM tblQMImportCatalogue IMP
									INNER JOIN tblSMCurrency CUR ON CUR.strCurrency = IMP.strCurrency
									WHERE ISNULL(IMP.strBatchNo, '') <> ''
									AND IMP.intImportCatalogueId = @intImportCatalogueId)
				,intBookId = (SELECT BOOK.intBookId
									FROM tblQMImportCatalogue IMP
									INNER JOIN tblSMCompanyLocation MU
										ON MU.strLocationName = CASE WHEN ISNULL(IMP.strGroupNumber, '') <> '' AND ISNULL(IMP.strContractNumber, '') <> '' THEN IMP.strGroupNumber ELSE IMP.strB1GroupNumber END
									INNER JOIN tblCTBook BOOK ON BOOK.strBook = MU.strLocationName
									WHERE ISNULL(IMP.strBatchNo, '') <> ''
									AND IMP.intImportCatalogueId = @intImportCatalogueId)
			SET @intSampleId = SCOPE_IDENTITY()

			-- Sample Detail
			INSERT INTO tblQMSampleDetail (
				intConcurrencyId
				,intSampleId
				,intAttributeId
				,strAttributeValue
				,intListItemId
				,ysnIsMandatory
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				)
			SELECT 1
				,@intSampleId
				,A.intAttributeId
				,ISNULL(A.strAttributeValue, '') AS strAttributeValue
				,A.intListItemId
				,ST.ysnIsMandatory
				,@intEntityUserId
				,@dtmDateCreated
				,@intEntityUserId
				,@dtmDateCreated
			FROM tblQMSampleTypeDetail ST
			JOIN tblQMAttribute A ON A.intAttributeId = ST.intAttributeId
			WHERE ST.intSampleTypeId = @intSampleTypeId

			DECLARE @intProductId INT

			-- Template
			IF (
					ISNULL(@intItemId, 0) > 0
					AND ISNULL(@intSampleTypeId, 0) > 0
					)
			BEGIN
				SELECT @intProductId = (
						SELECT P.intProductId
						FROM tblQMProduct AS P
						JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
						WHERE P.intProductTypeId = 2 -- Item
							AND P.intProductValueId = @intItemId
							AND PC.intSampleTypeId = @intSampleTypeId
							AND P.ysnActive = 1
						)

				IF (
						@intProductId IS NULL
						AND ISNULL(@intCategoryId, 0) > 0
						)
					SELECT @intProductId = (
							SELECT P.intProductId
							FROM tblQMProduct AS P
							JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
							WHERE P.intProductTypeId = 1 -- Item Category
								AND P.intProductValueId = @intCategoryId
								AND PC.intSampleTypeId = @intSampleTypeId
								AND P.ysnActive = 1
							)
			END

			-- Insert Test Result
			INSERT INTO tblQMTestResult (
				intConcurrencyId
				,intSampleId
				,intProductId
				,intProductTypeId
				,intProductValueId
				,intTestId
				,intPropertyId
				,strPanelList
				,strPropertyValue
				,dtmCreateDate
				,strResult
				,ysnFinal
				,strComment
				,intSequenceNo
				,dtmValidFrom
				,dtmValidTo
				,strPropertyRangeText
				,dblMinValue
				,dblPinpointValue
				,dblMaxValue
				,dblLowValue
				,dblHighValue
				,intUnitMeasureId
				,strFormulaParser
				,dblCrdrPrice
				,dblCrdrQty
				,intProductPropertyValidityPeriodId
				,intPropertyValidityPeriodId
				,intControlPointId
				,intParentPropertyId
				,intRepNo
				,strFormula
				,intListItemId
				,strIsMandatory
				,dtmPropertyValueCreated
				,intCreatedUserId
				,dtmCreated
				,intLastModifiedUserId
				,dtmLastModified
				)
			SELECT DISTINCT 1
				,@intSampleId
				,@intProductId
				,2 -- Item
				,@intItemId
				,PP.intTestId
				,PP.intPropertyId
				,''
				,''
				,@dtmDateCreated
				,''
				,0
				,''
				,PP.intSequenceNo
				,PPV.dtmValidFrom
				,PPV.dtmValidTo
				,PPV.strPropertyRangeText
				,PPV.dblMinValue
				,PPV.dblPinpointValue
				,PPV.dblMaxValue
				,PPV.dblLowValue
				,PPV.dblHighValue
				,PPV.intUnitMeasureId
				,PP.strFormulaParser
				,NULL
				,NULL
				,PPV.intProductPropertyValidityPeriodId
				,NULL
				,PC.intControlPointId
				,NULL
				,0
				,PP.strFormulaField
				,NULL
				,PP.strIsMandatory
				,NULL
				,@intEntityUserId
				,@dtmDateCreated
				,@intEntityUserId
				,@dtmDateCreated
			FROM tblQMProduct AS PRD
			JOIN tblQMProductControlPoint PC ON PC.intProductId = PRD.intProductId
			JOIN tblQMProductProperty AS PP ON PP.intProductId = PRD.intProductId
			JOIN tblQMProductTest AS PT ON PT.intProductId = PP.intProductId
				AND PT.intProductId = PRD.intProductId
			JOIN tblQMTest AS T ON T.intTestId = PP.intTestId
				AND T.intTestId = PT.intTestId
			JOIN tblQMTestProperty AS TP ON TP.intPropertyId = PP.intPropertyId
				AND TP.intTestId = PP.intTestId
				AND TP.intTestId = T.intTestId
				AND TP.intTestId = PT.intTestId
			JOIN tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
				AND PRT.intPropertyId = TP.intPropertyId
			JOIN tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
			WHERE PRD.intProductId = @intProductId
				AND PC.intSampleTypeId = @intSampleTypeId
				AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
					AND DATEPART(dy, PPV.dtmValidTo)
			ORDER BY PP.intSequenceNo

			-- End Insert Test Result
			EXEC uspQMGenerateSampleCatalogueImportAuditLog @intSampleId = @intSampleId
				,@intUserEntityId = @intEntityUserId
				,@strRemarks = 'Created from Catalogue Import'
				,@ysnCreate = 1
		END
				-- Update if combination exists
		ELSE
		BEGIN
			/* Item UOM Validation. */
			IF NOT EXISTS (SELECT * FROM tblICItemUOM WHERE intItemId = @intItemId AND intUnitMeasureId = @intRepresentingUOMId)
				BEGIN
					SELECT @strItemLog = strItemNo
					FROM tblICItem 
					WHERE intItemId = @intItemId;

					SELECT @strUnitMeasureLog = strUnitMeasure
					FROM tblICUnitMeasure 
					WHERE intUnitMeasureId = @intRepresentingUOMId;

					UPDATE tblQMImportCatalogue
					SET strLogResult = 'Unit of Measure '''+ @strUnitMeasureLog +''' does not exists on Item ''' + @strItemLog +'''.' 
						,ysnProcessed = 1
						,ysnSuccess = 0
					WHERE intImportCatalogueId = @intImportCatalogueId;

					GOTO CONT
				END
			
			EXEC uspQMGenerateSampleCatalogueImportAuditLog @intSampleId = @intSampleId
				,@intUserEntityId = @intEntityUserId
				,@strRemarks = 'Updated from Catalogue Import'
				,@ysnCreate = 0
				,@ysnBeforeUpdate = 1

			UPDATE S
			SET intConcurrencyId = S.intConcurrencyId + 1
				,strRepresentLotNumber = @strRefNo
				,intCountryID = @intOriginId
				,dblSampleQty = @dblSampleQty
				,dblRepresentingQty = (
					SELECT
						-- No of Packages
						CASE 
							WHEN ISNULL(@intNoOfPackages, 0) > 0
								THEN CAST(@intNoOfPackages AS NUMERIC(18, 6))
							ELSE 0
							END
						-- No of Packages 2nd Break
						+ CASE 
							WHEN ISNULL(@intNoOfPackagesSecondPackageBreak, 0) > 0
								THEN dbo.fnCalculateQtyBetweenUOM(IUOM2.intItemUOMId, IUOM1.intItemUOMId, CAST(@intNoOfPackagesSecondPackageBreak AS NUMERIC(18, 6)))
							ELSE 0
							END
						-- No of Packages 3nd Break
						+ CASE 
							WHEN ISNULL(@intNoOfPackagesThirdPackageBreak, 0) > 0
								THEN dbo.fnCalculateQtyBetweenUOM(IUOM3.intItemUOMId, IUOM1.intItemUOMId, CAST(@intNoOfPackagesThirdPackageBreak AS NUMERIC(18, 6)))
							ELSE 0
							END
					FROM tblICItemUOM IUOM1
					LEFT JOIN tblICItemUOM IUOM2 ON IUOM1.intItemId = IUOM2.intItemId
						AND IUOM2.intUnitMeasureId = @intNetWtSecondPackageBreakUOMId
					LEFT JOIN tblICItemUOM IUOM3 ON IUOM1.intItemId = IUOM3.intItemId
						AND IUOM3.intUnitMeasureId = @intNetWtThirdPackageBreakUOMId
					WHERE IUOM1.intItemId = @intItemId
						AND IUOM1.intUnitMeasureId = @intRepresentingUOMId
					)
				,intRepresentingUOMId = @intRepresentingUOMId
				,strCountry = @strCountry
				,intCompanyLocationSubLocationId = @intCompanyLocationSubLocationId
				,strComment = @strComments
				,intLastModifiedUserId = @intEntityUserId
				,dtmLastModified = @dtmDateCreated
				,intMarketZoneId = @intMarketZoneId
				,intSubBookId = @intSubBookId
				-- Auction Fields
				,intSaleYearId = @intSaleYearId
				,strSaleNumber = @strSaleNumber
				,dtmSaleDate = @dtmSaleDate
				,intCatalogueTypeId = @intCatalogueTypeId
				,dtmPromptDate = @dtmPromptDate
				,strChopNumber = @strChopNumber
				,intGradeId = @intGradeId
				,intManufacturingLeafTypeId = @intManufacturingLeafTypeId
				,intSeasonId = @intSeasonId
				,intGardenMarkId = @intGardenMarkId
				,intProducerId = @intProducerId
				,dtmManufacturingDate = @dtmManufacturingDate
				,intTotalNumberOfPackageBreakups = @intTotalNumberOfPackageBreakups
				,intNetWtPerPackagesUOMId = @intNetWtPerPackagesUOMId
				,intNoOfPackages = @intNoOfPackages
				,intNetWtSecondPackageBreakUOMId = @intNetWtSecondPackageBreakUOMId
				,intNoOfPackagesSecondPackageBreak = @intNoOfPackagesSecondPackageBreak
				,intNetWtThirdPackageBreakUOMId = @intNetWtThirdPackageBreakUOMId
				,intNoOfPackagesThirdPackageBreak = @intNoOfPackagesThirdPackageBreak
				,intProductLineId = @intProductLineId
				,ysnOrganic = @ysnOrganic
				,dblGrossWeight = @dblGrossWeight
				,strBatchNo = CASE WHEN ISNULL(@strBatchNo, '') = '' THEN S.strBatchNo ELSE @strBatchNo END
				,str3PLStatus = @str3PLStatus
				,strAdditionalSupplierReference = @strAdditionalSupplierReference
				,intAWBSampleReceived = @intAWBSampleReceived
				,strAWBSampleReference = @strAWBSampleReference
				,dblBasePrice = @dblBasePrice
				,ysnBoughtAsReserve = @ysnBoughtAsReserve
				,ysnEuropeanCompliantFlag = @ysnEuropeanCompliantFlag
				,intEvaluatorsCodeAtTBOId = @intEvaluatorsCodeAtTBOId
				,intFromLocationCodeId = @intFromLocationCodeId
				-- ,intDestinationStorageLocationId = @intDestinationStorageLocationId
				,strSampleBoxNumber = @strSampleBoxNumber
				,strComments3 = @strComments3
				,intBrokerId = @intBrokerId
				-- ,strBuyingOrderNo = @strBuyingOrderNumber
				-- B1
				,dblB1QtyBought = null
				,intB1QtyUOMId = null
				,dblB1Price = null
				,intB1PriceUOMId = null
				-- ,intBookId = null
				,intPackageTypeId=@intPackageTypeId
				,strCourierRef = @strCourierRef
				,intCropYearId = @intCropYearId

				-- Populated for bulking process only
				,intCurrencyId = ISNULL((SELECT CUR.intCurrencyID
									FROM tblQMImportCatalogue IMP
									INNER JOIN tblSMCurrency CUR ON CUR.strCurrency = IMP.strCurrency
									WHERE ISNULL(IMP.strBatchNo, '') <> ''
									AND IMP.intImportCatalogueId = @intImportCatalogueId), S.intCurrencyId)
				,intBookId = ISNULL((SELECT BOOK.intBookId
									FROM tblQMImportCatalogue IMP
									INNER JOIN tblSMCompanyLocation MU
										ON MU.strLocationName = CASE WHEN ISNULL(IMP.strGroupNumber, '') <> '' AND ISNULL(IMP.strContractNumber, '') <> '' THEN IMP.strGroupNumber ELSE IMP.strB1GroupNumber END
									INNER JOIN tblCTBook BOOK ON BOOK.strBook = MU.strLocationName
									WHERE ISNULL(IMP.strBatchNo, '') <> ''
									AND IMP.intImportCatalogueId = @intImportCatalogueId), S.intBookId)
			FROM tblQMSample S
			WHERE S.intSampleId = @intSampleId

		END

		UPDATE tblQMImportCatalogue
		SET intSampleId = @intSampleId
		WHERE intImportCatalogueId = @intImportCatalogueId

		CONT:

		FETCH NEXT
		FROM @C
		INTO @intImportType
			,@intImportCatalogueId
			,@intSaleYearId
			,@strSaleYear
			,@intMixingUnitLocationId
			,@intTBOLocationId
			,@strSaleNumber
			,@intCatalogueTypeId
			,@strCatalogueType
			,@intSupplierEntityId
			,@strRefNo
			,@strChopNumber
			,@intGradeId
			,@strGrade
			,@intManufacturingLeafTypeId
			,@strManufacturingLeafType
			,@intSeasonId
			,@strSeason
			,@dblGrossWeight
			,@intGardenMarkId
			,@intProducerId
			,@strGardenMark
			,@intOriginId
			,@strCountry
			,@intCompanyLocationSubLocationId
			,@dtmManufacturingDate
			,@dblSampleQty
			,@intTotalNumberOfPackageBreakups
			,@intNetWtPerPackagesUOMId
			,@intRepresentingUOMId
			,@intNoOfPackages
			,@intNetWtSecondPackageBreakUOMId
			,@intNoOfPackagesSecondPackageBreak
			,@intNetWtThirdPackageBreakUOMId
			,@intNoOfPackagesThirdPackageBreak
			,@intProductLineId
			,@strProductLine
			,@ysnOrganic
			,@dtmSaleDate
			,@dtmPromptDate
			,@strComments
			,@str3PLStatus
			,@strAdditionalSupplierReference
			,@intAWBSampleReceived
			,@strAWBSampleReference
			,@strCourierRef
			,@dblBasePrice
			,@ysnBoughtAsReserve
			,@ysnEuropeanCompliantFlag
			,@intEvaluatorsCodeAtTBOId
			,@strEvaluatorsCodeAtTBO
			,@strComments3
			,@intFromLocationCodeId
			,@strFromLocationCode
			,@intDestinationStorageLocationId
			,@strSampleBoxNumber
			,@strMarketZoneCode
			,@intMarketZoneId
			,@intSampleTypeId
			,@strBatchNo
			,@intEntityUserId
			,@dtmDateCreated
			,@intBrokerId
			,@strBroker
			,@strBuyingOrderNumber
			,@intBatchId
			,@strTINNumber
			,@intSubBookId
			,@strPackageType
			,@intCropYearId
			,@intWgtUnitMeasureId
	END

	CLOSE @C

	DEALLOCATE @C

	EXEC uspQMGenerateSampleCatalogueImportAuditLog
		@intUserEntityId = @intEntityUserId
		,@strRemarks = 'Updated from Catalogue Import'
		,@ysnCreate = 0
		,@ysnBeforeUpdate = 0

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()

	RAISERROR (
			@strErrorMsg
			,11
			,1
			)
END CATCH