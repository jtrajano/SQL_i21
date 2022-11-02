CREATE PROCEDURE uspQMImportCatalogueMain
    @intImportLogId INT
AS

BEGIN TRY
	BEGIN TRANSACTION

    -- Validate Foreign Key Fields
    UPDATE IMP
    SET strLogResult = 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage),charindex(',',reverse(MSG.strLogMessage))+1,len(MSG.strLogMessage)))
        ,ysnSuccess = 0
        ,ysnProcessed = 1
    FROM tblQMImportCatalogue IMP
    -- Grade
    LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.strType = 'Grade' AND GRADE.strDescription = IMP.strGrade
    -- Manufacturing Leaf Type
    LEFT JOIN tblICCommodityAttribute LEAF_TYPE ON LEAF_TYPE.strType = 'ProductType' AND LEAF_TYPE.strDescription = IMP.strManufacturingLeafType
    -- Season
    LEFT JOIN tblICCommodityAttribute SEASON ON SEASON.strType = 'Season' AND SEASON.strDescription = IMP.strColour
    -- Garden Mark
    LEFT JOIN tblQMGardenMark GARDEN ON GARDEN.strGardenMark = IMP.strGardenMark
    -- Garden Geo Origin
    LEFT JOIN tblSMCountry ORIGIN ON ORIGIN.strISOCode = IMP.strGardenGeoOrigin
    -- Warehouse Code
    LEFT JOIN tblSMCompanyLocationSubLocation WAREHOUSE_CODE ON WAREHOUSE_CODE.strSubLocationName = IMP.strWarehouseCode
    -- Sustainability
    LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.strDescription = IMP.strSustainability
    -- Evaluator's Code at TBO
    LEFT JOIN tblEMEntity ECTBO ON ECTBO.strName = IMP.strEvaluatorsCodeAtTBO
    -- From Location Code
    LEFT JOIN tblSMCity FROM_LOC_CODE ON FROM_LOC_CODE.strCity = IMP.strFromLocationCode
    -- Sub Book
    LEFT JOIN tblCTSubBook SUBBOOK ON SUBBOOK.strSubBook = IMP.strChannel + IMP.strSubChannel
    -- Sample Type
    LEFT JOIN tblQMSampleType SAMPLE_TYPE ON IMP.strSampleTypeName IS NOT NULL AND SAMPLE_TYPE.strSampleTypeName = IMP.strSampleTypeName
    -- Net Weight Per Packages / Quantity UOM
    LEFT JOIN tblICUnitMeasure UOM ON IMP.dblNetWtPerPackages IS NOT NULL AND UOM.strSymbol LIKE CAST(FLOOR(IMP.dblNetWtPerPackages) AS NVARCHAR(50)) + '%'
    -- Broker
    LEFT JOIN vyuEMSearchEntityBroker BROKERS ON IMP.strBroker IS NOT NULL AND BROKERS.strName = IMP.strBroker
    -- Format log message
    OUTER APPLY (
        SELECT strLogMessage = 
            CASE WHEN (GRADE.intCommodityAttributeId IS NULL AND ISNULL(IMP.strGrade, '') <> '') THEN 'GRADE, ' ELSE '' END
            + CASE WHEN (LEAF_TYPE.intCommodityAttributeId IS NULL AND ISNULL(IMP.strManufacturingLeafType, '') <> '') THEN 'MANUFACTURING LEAF TYPE, ' ELSE '' END
            + CASE WHEN (SEASON.intCommodityAttributeId IS NULL AND ISNULL(IMP.strColour, '') <> '') THEN 'SEASON, ' ELSE '' END
            + CASE WHEN (GARDEN.intGardenMarkId IS NULL AND ISNULL(IMP.strGardenMark, '') <> '') THEN 'GARDEN MARK, ' ELSE '' END
            + CASE WHEN (ORIGIN.intCountryID IS NULL AND ISNULL(IMP.strGardenGeoOrigin, '') <> '') THEN 'GARDEN GEO ORIGIN, ' ELSE '' END
            + CASE WHEN (WAREHOUSE_CODE.intCompanyLocationSubLocationId IS NULL AND ISNULL(IMP.strWarehouseCode, '') <> '') THEN 'WAREHOUSE CODE, ' ELSE '' END
            + CASE WHEN (SUSTAINABILITY.intCommodityProductLineId IS NULL AND ISNULL(IMP.strSustainability, '') <> '') THEN 'SUSTAINABILITY, ' ELSE '' END
            + CASE WHEN (ECTBO.intEntityId IS NULL AND ISNULL(IMP.strEvaluatorsCodeAtTBO, '') <> '') THEN 'EVALUATORS CODE AT TBO, ' ELSE '' END
            + CASE WHEN (FROM_LOC_CODE.intCityId IS NULL AND ISNULL(IMP.strFromLocationCode, '') <> '') THEN 'FROM LOCATION CODE, ' ELSE '' END
            + CASE WHEN (SUBBOOK.intSubBookId IS NULL AND ISNULL(IMP.strChannel, '') + ISNULL(IMP.strSubChannel, '') <> '') THEN 'CHANNEL / SUB CHANNEL, ' ELSE '' END
            + CASE WHEN (SAMPLE_TYPE.intSampleTypeId IS NULL AND ISNULL(IMP.strSampleTypeName, '') <> '') THEN 'SAMPLE TYPE, ' ELSE '' END
            + CASE WHEN (UOM.intUnitMeasureId IS NULL AND ISNULL(IMP.dblNetWtPerPackages, 0) <> 0) THEN 'NET WEIGHT PER PACKAGES, ' ELSE '' END
            + CASE WHEN (BROKERS.intEntityId IS NULL AND ISNULL(IMP.strBroker, '') <> '') THEN 'BROKER, ' ELSE '' END
    ) MSG
    WHERE IMP.intImportLogId = @intImportLogId
    AND IMP.ysnSuccess = 1
    AND (
        (GRADE.intCommodityAttributeId IS NULL AND ISNULL(IMP.strGrade, '') <> '')
        OR (LEAF_TYPE.intCommodityAttributeId IS NULL AND ISNULL(IMP.strManufacturingLeafType, '') <> '')
        OR (SEASON.intCommodityAttributeId IS NULL AND ISNULL(IMP.strColour, '') <> '')
        OR (GARDEN.intGardenMarkId IS NULL AND ISNULL(IMP.strGardenMark, '') <> '')
        OR (ORIGIN.intCountryID IS NULL AND ISNULL(IMP.strGardenGeoOrigin, '') <> '')
        OR (WAREHOUSE_CODE.intCompanyLocationSubLocationId IS NULL AND ISNULL(IMP.strWarehouseCode, '') <> '')
        OR (SUSTAINABILITY.intCommodityProductLineId IS NULL AND ISNULL(IMP.strSustainability, '') <> '')
        OR (ECTBO.intEntityId IS NULL AND ISNULL(IMP.strEvaluatorsCodeAtTBO, '') <> '')
        OR (FROM_LOC_CODE.intCityId IS NULL AND ISNULL(IMP.strFromLocationCode, '') <> '')
        OR (SUBBOOK.intSubBookId IS NULL AND ISNULL(IMP.strChannel, '') + ISNULL(IMP.strSubChannel, '') <> '')
        OR (SAMPLE_TYPE.intSampleTypeId IS NULL AND ISNULL(IMP.strSampleTypeName, '') <> '')
        OR (UOM.intUnitMeasureId IS NULL AND ISNULL(IMP.dblNetWtPerPackages, 0) <> 0)
        OR (BROKERS.intEntityId IS NULL AND ISNULL(IMP.strBroker, '') <> '')
    )
    -- End Validation

    DECLARE
        @strSampleNumber NVARCHAR(30)
        ,@intImportCatalogueId INT
        ,@intSaleYearId INT
        ,@strSaleYear NVARCHAR(50)
        ,@intCompanyLocationId INT
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
        ,@strGardenMark NVARCHAR(100)
        ,@intOriginId INT
        ,@strCountry NVARCHAR(100)
        ,@intCompanyLocationSubLocationId INT
        ,@dtmManufacturingDate DATETIME
        ,@dblSampleQty NUMERIC(18, 6)
        ,@intTotalNumberOfPackageBreakups BIGINT
        ,@dblNetWtPerPackages NUMERIC(18, 6)
        ,@intRepresentingUOMId INT
        ,@intNoOfPackages BIGINT
        ,@dblNetWtSecondPackageBreak NUMERIC(18, 6)
        ,@intNoOfPackagesSecondPackageBreak BIGINT
        ,@dblNetWtThirdPackageBreak NUMERIC(18, 6)
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
        ,@strSampleBoxNumber NVARCHAR(50)
        ,@strSubBook NVARCHAR(100)
        ,@intSampleTypeId INT
        ,@strBatchNo NVARCHAR(50)
        ,@intEntityUserId INT
        ,@dtmDateCreated DATETIME
        ,@intBrokerId INT
        ,@strBroker NVARCHAR(100)
    
    DECLARE @intSampleId INT
    DECLARE @intItemId INT
    DECLARE @intCategoryId INT
    DECLARE @intValidDate INT

    SELECT @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

    SELECT TOP 1
        @intItemId = [intDefaultItemId]
        ,@intCategoryId = I.intCategoryId
    FROM tblQMCatalogueImportDefaults CID
    INNER JOIN tblICItem I ON I.intItemId = CID.intDefaultItemId

    -- Loop through each valid import detail
    DECLARE @C AS CURSOR;
	SET @C = CURSOR FAST_FORWARD FOR
        SELECT
            intImportCatalogueId = IMP.intImportCatalogueId
            ,intSaleYearId = SY.intSaleYearId
            ,strSaleYear = SY.strSaleYear
            ,intCompanyLocationId = CL.intCompanyLocationId
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
            ,strGardenMark = GARDEN.strGardenMark
            ,intOriginId = ORIGIN.intCountryID
            ,strCountry = ORIGIN.strCountry
            ,intCompanyLocationSubLocationId = WAREHOUSE_CODE.intCompanyLocationSubLocationId
            ,dtmManufacturingDate = IMP.dtmManufacturingDate
            ,dblSampleQty = IMP.dblTotalQtyOffered
            ,intTotalNumberOfPackageBreakups = IMP.intTotalNumberOfPackageBreakups
            ,dblNetWtPerPackages = IMP.dblNetWtPerPackages
            ,intRepresentingUOMId = UOM.intUnitMeasureId
            ,intNoOfPackages = IMP.intNoOfPackages
            ,dblNetWtSecondPackageBreak = IMP.dblNetWtSecondPackageBreak
            ,intNoOfPackagesSecondPackageBreak = IMP.intNoOfPackagesSecondPackageBreak
            ,dblNetWtThirdPackageBreak = IMP.dblNetWtThirdPackageBreak
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
            ,intEvaluatorsCodeAtTBOId = ECTBO.intEntityId
            ,strEvaluatorsCodeAtTBO = ECTBO.strName
            ,strComments3 = IMP.strEvaluatorsRemarks
            ,intFromLocationCodeId = FROM_LOC_CODE.intCityId
            ,strFromLocationCode = FROM_LOC_CODE.strCity
            ,strSampleBoxNumber = IMP.strSampleBoxNumberTBO
            ,strSubBook = ISNULL(IMP.strChannel, '') + ISNULL(IMP.strSubChannel, '')
            ,intSampleTypeId = SAMPLE_TYPE.intSampleTypeId
            ,strBatchNo = IMP.strBatchNo
            ,intEntityUserId = IL.intEntityId
            ,dtmDateCreated = GETDATE()
            ,intBrokerId = BROKERS.intEntityId
            ,strBroker = BROKERS.strName
        FROM tblQMImportCatalogue IMP
        INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
        -- Sale Year
        LEFT JOIN tblQMSaleYear SY ON SY.strSaleYear = IMP.strSaleYear
        -- Company Location
        LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = IMP.strBuyingCenter
        -- Catalogue Type
        LEFT JOIN tblQMCatalogueType CT ON CT.strCatalogueType = IMP.strCatalogueType
        -- Supplier
        LEFT JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId) ON E.strName = IMP.strSupplier
        -- Grade
        LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.strType = 'Grade' AND GRADE.strDescription = IMP.strGrade
        -- Manufacturing Leaf Type
        LEFT JOIN tblICCommodityAttribute LEAF_TYPE ON LEAF_TYPE.strType = 'ProductType' AND LEAF_TYPE.strDescription = IMP.strManufacturingLeafType
        -- Season
        LEFT JOIN tblICCommodityAttribute SEASON ON SEASON.strType = 'Season' AND SEASON.strDescription = IMP.strColour
        -- Garden Mark
        LEFT JOIN tblQMGardenMark GARDEN ON GARDEN.strGardenMark = IMP.strGardenMark
        -- Garden Geo Origin
        LEFT JOIN tblSMCountry ORIGIN ON ORIGIN.strISOCode = IMP.strGardenGeoOrigin
        -- Warehouse Code
        LEFT JOIN tblSMCompanyLocationSubLocation WAREHOUSE_CODE ON WAREHOUSE_CODE.strSubLocationName = IMP.strWarehouseCode
        -- Sustainability
        LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.strDescription = IMP.strSustainability
        -- Evaluator's Code at TBO
        LEFT JOIN tblEMEntity ECTBO ON ECTBO.strName = IMP.strEvaluatorsCodeAtTBO
        -- From Location Code
        LEFT JOIN tblSMCity FROM_LOC_CODE ON FROM_LOC_CODE.strCity = IMP.strFromLocationCode
        -- Sub Book
        LEFT JOIN tblCTSubBook SUBBOOK ON SUBBOOK.strSubBook = IMP.strChannel + IMP.strSubChannel
        -- Sample Type
        LEFT JOIN tblQMSampleType SAMPLE_TYPE ON IMP.strSampleTypeName IS NOT NULL AND SAMPLE_TYPE.strSampleTypeName = IMP.strSampleTypeName
        -- Net Weight Per Packages / Quantity UOM
        LEFT JOIN tblICUnitMeasure UOM ON IMP.dblNetWtPerPackages IS NOT NULL AND UOM.strSymbol LIKE CAST(FLOOR(IMP.dblNetWtPerPackages) AS NVARCHAR(50)) + '%'
        -- Broker
        LEFT JOIN vyuEMSearchEntityBroker BROKERS ON IMP.strBroker IS NOT NULL AND BROKERS.strName = IMP.strBroker

        WHERE IMP.intImportLogId = @intImportLogId
        AND IMP.ysnSuccess = 1

    OPEN @C 
	FETCH NEXT FROM @C INTO
		@intImportCatalogueId
		,@intSaleYearId
        ,@strSaleYear
        ,@intCompanyLocationId
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
        ,@strGardenMark
        ,@intOriginId
        ,@strCountry
        ,@intCompanyLocationSubLocationId
        ,@dtmManufacturingDate
        ,@dblSampleQty
        ,@intTotalNumberOfPackageBreakups
        ,@dblNetWtPerPackages
        ,@intRepresentingUOMId
        ,@intNoOfPackages
        ,@dblNetWtSecondPackageBreak
        ,@intNoOfPackagesSecondPackageBreak
        ,@dblNetWtThirdPackageBreak
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
        ,@strSampleBoxNumber
        ,@strSubBook
        ,@intSampleTypeId
        ,@strBatchNo
        ,@intEntityUserId
        ,@dtmDateCreated
        ,@intBrokerId
        ,@strBroker
	WHILE @@FETCH_STATUS = 0
	BEGIN
        SET @intSampleId = NULL

        SELECT @intSampleId = S.intSampleId
        FROM tblQMSample S
        INNER JOIN tblQMAuction A ON A.intSampleId = S.intSampleId
        INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
        INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = A.intCatalogueTypeId
        INNER JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
            ON V.intEntityId = S.intEntityId
        WHERE S.strSaleYear = @strSaleYear
        AND CL.intCompanyLocationId = @intCompanyLocationId
        AND S.strSaleNumber = @strSaleNumber
        AND CT.intCatalogueTypeId = @intCatalogueTypeId
        AND E.intEntityId = @intSupplierEntityId
        AND S.strRepresentLotNumber = @strRefNo
        -- If sample does not exist yet

        IF @intSampleId IS NULL
        BEGIN

            -- Assign sample type based on mapping table if it is not supplied in the template
            IF @intSampleTypeId IS NULL AND @strSubBook IS NOT NULL
                SELECT @intSampleTypeId = SBSTM.intSampleTypeId
                FROM tblQMSubBookSampleTypeMapping SBSTM
                INNER JOIN tblCTSubBook SB ON SB.intSubBookId = SBSTM.intSubBookId
                WHERE SB.strSubBook = @strSubBook

            --New Sample Creation
            EXEC uspMFGeneratePatternId @intCategoryId = NULL
                ,@intItemId = NULL
                ,@intManufacturingId = NULL
                ,@intSubLocationId = NULL
                ,@intLocationId = @intCompanyLocationId
                ,@intOrderTypeId = NULL
                ,@intBlendRequirementId = NULL
                ,@intPatternCode = 62
                ,@ysnProposed = 0
                ,@strPatternString = @strSampleNumber OUTPUT

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

                -- Auction Fields
                ,intSaleYearId
                ,strSaleYear
                ,strSaleNumber
                ,dtmSaleDate
                ,intCatalogueTypeId
                ,strCatalogueType
                ,dtmPromptDate
                ,strChopNumber
                ,intGradeId
                ,strGrade
                ,intManufacturingLeafTypeId
                ,strManufacturingLeafType
                ,intSeasonId
                ,strSeason
                ,intGardenMarkId
                ,strGardenMark
                ,dtmManufacturingDate
                ,intTotalNumberOfPackageBreakups
                ,dblNetWtPerPackages
                ,intNoOfPackages
                ,dblNetWtSecondPackageBreak
                ,intNoOfPackagesSecondPackageBreak
                ,dblNetWtThirdPackageBreak
                ,intNoOfPackagesThirdPackageBreak
                ,intProductLineId
                ,strProductLine
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
                ,strEvaluatorsCodeAtTBO
                ,intFromLocationCodeId
                ,strFromLocationCode
                ,strSampleBoxNumber
                ,strComments3
                ,intBrokerId
                ,strBroker
                )
            SELECT
                intConcurrencyId = 1
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
                ,dblRepresentingQty = CASE WHEN ISNULL(@intNoOfPackages, 0) IS NOT NULL THEN CAST(@intNoOfPackages AS NUMERIC(18, 6)) ELSE NULL END
                ,intSampleUOMId = (SELECT TOP 1 [intDefaultSampleUOMId] FROM tblQMCatalogueImportDefaults)
                ,intRepresentingUOMId = @intRepresentingUOMId
                ,strRepresentLotNumber = @strRefNo
                ,dtmTestingStartDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
                ,dtmTestingEndDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
                ,dtmSamplingEndDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmDateCreated)
                ,strCountry = @strCountry
                ,intLocationId = @intCompanyLocationId
                ,intCompanyLocationId = @intCompanyLocationId
                ,intCompanyLocationId = @intCompanyLocationSubLocationId
                ,strComment = @strComments
                ,intCreatedUserId = @intEntityUserId
                ,dtmCreated = @dtmDateCreated

                -- Auction Fields
                ,intSaleYearId = @intSaleYearId
                ,strSaleYear = @strSaleYear
                ,strSaleNumber = @strSaleNumber
                ,dtmSaleDate = @dtmSaleDate
                ,intCatalogueTypeId = @intCatalogueTypeId
                ,strCatalogueType = @strCatalogueType
                ,dtmPromptDate = @dtmPromptDate
                ,strChopNumber = @strChopNumber
                ,intGradeId = @intGradeId
                ,strGrade = @strGrade
                ,intManufacturingLeafTypeId = @intManufacturingLeafTypeId
                ,strManufacturingLeafType = @strManufacturingLeafType
                ,intSeasonId = @intSeasonId
                ,strSeason = @strSeason
                ,intGardenMarkId = @intGardenMarkId
                ,strGardenMark = @strGardenMark
                ,dtmManufacturingDate = @dtmManufacturingDate
                ,intTotalNumberOfPackageBreakups = @intTotalNumberOfPackageBreakups
                ,dblNetWtPerPackages = @dblNetWtPerPackages
                ,intNoOfPackages = @intNoOfPackages
                ,dblNetWtSecondPackageBreak = @dblNetWtSecondPackageBreak
                ,intNoOfPackagesSecondPackageBreak = @intNoOfPackagesSecondPackageBreak
                ,dblNetWtThirdPackageBreak = @dblNetWtThirdPackageBreak
                ,intNoOfPackagesThirdPackageBreak = @intNoOfPackagesThirdPackageBreak
                ,intProductLineId = @intProductLineId
                ,strProductLine = @strProductLine
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
                ,strEvaluatorsCodeAtTBO = @strEvaluatorsCodeAtTBO
                ,intFromLocationCodeId = @intFromLocationCodeId
                ,strFromLocationCode = @strFromLocationCode
                ,strSampleBoxNumber = @strSampleBoxNumber
                ,strComments3 = @strComments3
                ,intBrokerId = @intBrokerId
                ,strBroker = @strBroker
            
            SET @intSampleId = SCOPE_IDENTITY()

            INSERT INTO tblQMAuction (
                intConcurrencyId
                ,intSampleId
                ,intSaleYearId
                ,strSaleYear
                ,strSaleNumber
                ,dtmSaleDate
                ,intCatalogueTypeId
                ,strCatalogueType
                ,dtmPromptDate
                ,strChopNumber
                ,intGradeId
                ,strGrade
                ,intManufacturingLeafTypeId
                ,strManufacturingLeafType
                ,intSeasonId
                ,strSeason
                ,intGardenMarkId
                ,strGardenMark
                ,dtmManufacturingDate
                ,intTotalNumberOfPackageBreakups
                ,dblNetWtPerPackages
                ,intNoOfPackages
                ,dblNetWtSecondPackageBreak
                ,intNoOfPackagesSecondPackageBreak
                ,dblNetWtThirdPackageBreak
                ,intNoOfPackagesThirdPackageBreak
                ,intProductLineId
                ,strProductLine
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
                ,strEvaluatorsCodeAtTBO
                ,intFromLocationCodeId
                ,strFromLocationCode
                ,strSampleBoxNumber
                ,strComments3
                ,intBrokerId
                ,strBroker
            )
            SELECT
                intConcurrencyId = 1
                ,intSampleId = @intSampleId
                ,intSaleYearId = @intSaleYearId
                ,strSaleYear = @strSaleYear
                ,strSaleNumber = @strSaleNumber
                ,dtmSaleDate = @dtmSaleDate
                ,intCatalogueTypeId = @intCatalogueTypeId
                ,strCatalogueType = @strCatalogueType
                ,dtmPromptDate = @dtmPromptDate
                ,strChopNumber = @strChopNumber
                ,intGradeId = @intGradeId
                ,strGrade = @strGrade
                ,intManufacturingLeafTypeId = @intManufacturingLeafTypeId
                ,strManufacturingLeafType = @strManufacturingLeafType
                ,intSeasonId = @intSeasonId
                ,strSeason = @strSeason
                ,intGardenMarkId = @intGardenMarkId
                ,strGardenMark = @strGardenMark
                ,dtmManufacturingDate = @dtmManufacturingDate
                ,intTotalNumberOfPackageBreakups = @intTotalNumberOfPackageBreakups
                ,dblNetWtPerPackages = @dblNetWtPerPackages
                ,intNoOfPackages = @intNoOfPackages
                ,dblNetWtSecondPackageBreak = @dblNetWtSecondPackageBreak
                ,intNoOfPackagesSecondPackageBreak = @intNoOfPackagesSecondPackageBreak
                ,dblNetWtThirdPackageBreak = @dblNetWtThirdPackageBreak
                ,intNoOfPackagesThirdPackageBreak = @intNoOfPackagesThirdPackageBreak
                ,intProductLineId = @intProductLineId
                ,strProductLine = @strProductLine
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
                ,strEvaluatorsCodeAtTBO = @strEvaluatorsCodeAtTBO
                ,intFromLocationCodeId = @intFromLocationCodeId
                ,strFromLocationCode = @strFromLocationCode
                ,strSampleBoxNumber = @strSampleBoxNumber
                ,strComments3 = @strComments3
                ,intBrokerId = @intBrokerId
                ,strBroker = @strBroker
            
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
            IF (ISNULL(@intItemId, 0) > 0 AND ISNULL(@intSampleTypeId, 0) > 0)
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

                IF (@intProductId IS NULL AND ISNULL(@intCategoryId, 0) > 0)
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

            -- TODO: Audit Logs here
        END
        -- Update if combination exists
        ELSE
        BEGIN
            UPDATE S
            SET
                strRepresentLotNumber = @strRefNo
                ,intCountryID = @intOriginId
                ,dblSampleQty = @dblSampleQty
                ,dblRepresentingQty = CASE WHEN ISNULL(@intNoOfPackages, 0) IS NOT NULL THEN CAST(@intNoOfPackages AS NUMERIC(18, 6)) ELSE NULL END
                ,intRepresentingUOMId = @intRepresentingUOMId
                ,strCountry = @strCountry
                ,intCompanyLocationSubLocationId = @intCompanyLocationSubLocationId
                ,strComment = @strComments
                ,intLastModifiedUserId = @intEntityUserId
                ,dtmLastModified = @dtmDateCreated

                -- Auction Fields
                ,intSaleYearId = @intSaleYearId
                ,strSaleYear = @strSaleYear
                ,strSaleNumber = @strSaleNumber
                ,dtmSaleDate = @dtmSaleDate
                ,intCatalogueTypeId = @intCatalogueTypeId
                ,strCatalogueType = @strCatalogueType
                ,dtmPromptDate = @dtmPromptDate
                ,strChopNumber = @strChopNumber
                ,intGradeId = @intGradeId
                ,strGrade = @strGrade
                ,intManufacturingLeafTypeId = @intManufacturingLeafTypeId
                ,strManufacturingLeafType = @strManufacturingLeafType
                ,intSeasonId = @intSeasonId
                ,strSeason = @strSeason
                ,intGardenMarkId = @intGardenMarkId
                ,strGardenMark = @strGardenMark
                ,dtmManufacturingDate = @dtmManufacturingDate
                ,intTotalNumberOfPackageBreakups = @intTotalNumberOfPackageBreakups
                ,dblNetWtPerPackages = @dblNetWtPerPackages
                ,intNoOfPackages = @intNoOfPackages
                ,dblNetWtSecondPackageBreak = @dblNetWtSecondPackageBreak
                ,intNoOfPackagesSecondPackageBreak = @intNoOfPackagesSecondPackageBreak
                ,dblNetWtThirdPackageBreak = @dblNetWtThirdPackageBreak
                ,intNoOfPackagesThirdPackageBreak = @intNoOfPackagesThirdPackageBreak
                ,intProductLineId = @intProductLineId
                ,strProductLine = @strProductLine
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
                ,strEvaluatorsCodeAtTBO = @strEvaluatorsCodeAtTBO
                ,intFromLocationCodeId = @intFromLocationCodeId
                ,strFromLocationCode = @strFromLocationCode
                ,strSampleBoxNumber = @strSampleBoxNumber
                ,strComments3 = @strComments3
                ,intBrokerId = @intBrokerId
                ,strBroker = @strBroker
            FROM tblQMSample S
            WHERE S.intSampleId = @intSampleId

            UPDATE A
            SET
                intConcurrencyId = A.intConcurrencyId + 1
                ,intSaleYearId = @intSaleYearId
                ,strSaleYear = @strSaleYear
                ,strSaleNumber = @strSaleNumber
                ,dtmSaleDate = @dtmSaleDate
                ,intCatalogueTypeId = @intCatalogueTypeId
                ,strCatalogueType = @strCatalogueType
                ,dtmPromptDate = @dtmPromptDate
                ,strChopNumber = @strChopNumber
                ,intGradeId = @intGradeId
                ,strGrade = @strGrade
                ,intManufacturingLeafTypeId = @intManufacturingLeafTypeId
                ,strManufacturingLeafType = @strManufacturingLeafType
                ,intSeasonId = @intSeasonId
                ,strSeason = @strSeason
                ,intGardenMarkId = @intGardenMarkId
                ,strGardenMark = @strGardenMark
                ,dtmManufacturingDate = @dtmManufacturingDate
                ,intTotalNumberOfPackageBreakups = @intTotalNumberOfPackageBreakups
                ,dblNetWtPerPackages = @dblNetWtPerPackages
                ,intNoOfPackages = @intNoOfPackages
                ,dblNetWtSecondPackageBreak = @dblNetWtSecondPackageBreak
                ,intNoOfPackagesSecondPackageBreak = @intNoOfPackagesSecondPackageBreak
                ,dblNetWtThirdPackageBreak = @dblNetWtThirdPackageBreak
                ,intNoOfPackagesThirdPackageBreak = @intNoOfPackagesThirdPackageBreak
                ,intProductLineId = @intProductLineId
                ,strProductLine = @strProductLine
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
                ,strEvaluatorsCodeAtTBO = @strEvaluatorsCodeAtTBO
                ,intFromLocationCodeId = @intFromLocationCodeId
                ,strFromLocationCode = @strFromLocationCode
                ,strSampleBoxNumber = @strSampleBoxNumber
                ,strComments3 = @strComments3
                ,intBrokerId = @intBrokerId
                ,strBroker = @strBroker
            FROM tblQMSample S
            INNER JOIN tblQMAuction A ON A.intSampleId = S.intSampleId
            WHERE S.intSampleId = @intSampleId

        END

        UPDATE tblQMImportCatalogue
        SET intSampleId = @intSampleId
        WHERE intImportCatalogueId = @intImportCatalogueId

        FETCH NEXT FROM @C INTO
            @intImportCatalogueId
            ,@intSaleYearId
            ,@strSaleYear
            ,@intCompanyLocationId
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
            ,@strGardenMark
            ,@intOriginId
            ,@strCountry
            ,@intCompanyLocationSubLocationId
            ,@dtmManufacturingDate
            ,@dblSampleQty
            ,@intTotalNumberOfPackageBreakups
            ,@dblNetWtPerPackages
            ,@intRepresentingUOMId
            ,@intNoOfPackages
            ,@dblNetWtSecondPackageBreak
            ,@intNoOfPackagesSecondPackageBreak
            ,@dblNetWtThirdPackageBreak
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
            ,@strSampleBoxNumber
            ,@strSubBook
            ,@intSampleTypeId
            ,@strBatchNo
            ,@intEntityUserId
            ,@dtmDateCreated
            ,@intBrokerId
            ,@strBroker
    END
    CLOSE @C
	DEALLOCATE @C

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH