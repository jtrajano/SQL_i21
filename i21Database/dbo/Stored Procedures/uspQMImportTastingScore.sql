CREATE PROCEDURE uspQMImportTastingScore
    @intImportLogId INT
AS

BEGIN TRY
	Declare @intProductValueId int,@intOriginalItemId int
	BEGIN TRANSACTION

    -- Validate Foreign Key Fields
    UPDATE IMP
    SET strLogResult = 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage),charindex(',',reverse(MSG.strLogMessage))+1,len(MSG.strLogMessage)))
        ,ysnSuccess = 0
        ,ysnProcessed = 1
    FROM tblQMImportCatalogue IMP
    -- Colour
    LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.strType = 'Season' AND COLOUR.strDescription = IMP.strColour
    -- Size
    LEFT JOIN tblICBrand SIZE ON SIZE.strBrandCode = IMP.strSize
    -- Style
    LEFT JOIN tblCTValuationGroup STYLE ON STYLE.strName = IMP.strStyle
    -- Tealingo Item
    LEFT JOIN tblICItem ITEM ON ITEM.strItemNo = IMP.strTealingoItem
    -- Batch ID
    LEFT JOIN tblMFBatch BATCH ON BATCH.strBatchId = IMP.strBatchNo
    -- Template Sample Type
    LEFT JOIN tblQMSampleType TEMPLATE_SAMPLE_TYPE ON TEMPLATE_SAMPLE_TYPE.strSampleTypeName = IMP.strSampleTypeName
    -- Buyer1 Group Number
    LEFT JOIN tblSMCompanyLocation B1GN ON B1GN.strLocationName = IMP.strB1GroupNumber
    -- Format log message
    OUTER APPLY (
        SELECT strLogMessage = 
            CASE WHEN (COLOUR.intCommodityAttributeId IS NULL AND ISNULL(IMP.strColour, '') <> '') THEN 'COLOUR, ' ELSE '' END
            + CASE WHEN (SIZE.intBrandId IS NULL AND ISNULL(IMP.strSize, '') <> '') THEN 'SIZE, ' ELSE '' END
            + CASE WHEN (STYLE.intValuationGroupId IS NULL AND ISNULL(IMP.strStyle, '') <> '') THEN 'STYLE, ' ELSE '' END
            + CASE WHEN (ITEM.intItemId IS NULL AND ISNULL(IMP.strTealingoItem, '') <> '') THEN 'TEALINGO ITEM, ' ELSE '' END
            + CASE WHEN (BATCH.intBatchId IS NULL AND ISNULL(IMP.strBatchNo, '') <> '') THEN 'BATCH NO, ' ELSE '' END
            + CASE WHEN (TEMPLATE_SAMPLE_TYPE.intSampleTypeId IS NULL AND ISNULL(IMP.strSampleTypeName, '') <> '') THEN 'SAMPLE TYPE, ' ELSE '' END
            + CASE WHEN (B1GN.intCompanyLocationId IS NULL AND ISNULL(IMP.strB1GroupNumber, '') <> '') THEN 'BUYER1 GROUP NUMBER, ' ELSE '' END
    ) MSG
    WHERE IMP.intImportLogId = @intImportLogId
    AND IMP.ysnSuccess = 1
    AND (
        (COLOUR.intCommodityAttributeId IS NULL AND ISNULL(IMP.strColour, '') <> '')
        OR (SIZE.intBrandId IS NULL AND ISNULL(IMP.strSize, '') <> '')
        OR (STYLE.intValuationGroupId IS NULL AND ISNULL(IMP.strStyle, '') <> '')
        OR (ITEM.intItemId IS NULL AND ISNULL(IMP.strTealingoItem, '') <> '')
        OR (BATCH.intBatchId IS NULL AND ISNULL(IMP.strBatchNo, '') <> '')
        OR (TEMPLATE_SAMPLE_TYPE.intSampleTypeId IS NULL AND ISNULL(IMP.strSampleTypeName, '') <> '')
        OR (B1GN.intCompanyLocationId IS NULL AND ISNULL(IMP.strB1GroupNumber, '') <> '')
    )
    -- End Validation

    DECLARE
        @intImportType INT
        ,@intImportCatalogueId INT
        ,@intSampleTypeId INT
        ,@intTemplateSampleTypeId INT
        ,@intMixingUnitLocationId INT
        ,@intColourId INT
        ,@strColour NVARCHAR(50)
        ,@intBrandId INT -- Size
        ,@strBrand NVARCHAR(50)
        ,@strComments NVARCHAR(MAX)
        ,@intSampleId INT
        ,@intValuationGroupId INT -- Style
        ,@strValuationGroup NVARCHAR(50)
        ,@strOrigin NVARCHAR(50)
        ,@strSustainability NVARCHAR(50)
        ,@strMusterLot NVARCHAR(50)
	    ,@strMissingLot NVARCHAR(50)
        ,@strComments2 NVARCHAR(MAX)
        ,@intItemId INT
        ,@intCategoryId INT
        ,@dtmDateCreated DATETIME
        ,@intEntityUserId INT
        ,@intBatchId INT
        ,@strBatchNo NVARCHAR(50)
        ,@strTINNumber NVARCHAR(50)
        -- Test Properties
        ,@strAppearance NVARCHAR(MAX)
        ,@strHue NVARCHAR(MAX)
        ,@strIntensity NVARCHAR(MAX)
        ,@strTaste NVARCHAR(MAX)
        ,@strMouthFeel NVARCHAR(MAX)

    DECLARE @intValidDate INT
        ,@intDefaultItemId INT
        ,@intDefaultCategoryId INT

    SELECT @intValidDate = (SELECT DATEPART(dy, GETDATE()))

    SELECT TOP 1
        @intDefaultItemId = [intDefaultItemId]
        ,@intDefaultCategoryId = I.intCategoryId
    FROM tblQMCatalogueImportDefaults CID
    INNER JOIN tblICItem I ON I.intItemId = CID.intDefaultItemId

    -- Loop through each valid import detail
    DECLARE @C AS CURSOR;
	SET @C = CURSOR FAST_FORWARD FOR
        SELECT
            intImportType = 1 -- Auction/Non-Action Sample Import
            ,intImportCatalogueId = IMP.intImportCatalogueId
            ,intSampleTypeId = S.intSampleTypeId
            ,intTemplateSampleTypeId = NULL
            ,intCompanyLocationId = NULL
            ,intColourId = COLOUR.intCommodityAttributeId
            ,strColour = COLOUR.strDescription
            ,intBrandId = SIZE.intBrandId
            ,strBrand = SIZE.strBrandCode
            ,strComments = IMP.strRemarks
            ,intSampleId = S.intSampleId
            ,intValuationGroupId = STYLE.intValuationGroupId
            ,strValuationGroup = STYLE.strName
            ,strOrigin = ORIGIN.strISOCode
            ,strSustainability = SUSTAINABILITY.strDescription
            ,strMusterLot = IMP.strMusterLot
            ,strMissingLot = IMP.strMissingLot
            ,strComments2 = IMP.strTastersRemarks
            ,intItemId = ITEM.intItemId
            ,intCategoryId = ITEM.intCategoryId
            ,dtmDateCreated = IL.dtmImportDate
            ,intEntityUserId = IL.intEntityId
            ,intBatchId = NULL
            ,strBatchNo = NULL
            ,strTINNumber = NULL
            -- Test Properties
            ,strAppearance = IMP.strAppearance
            ,strHue = IMP.strHue
            ,strIntensity = IMP.strIntensity
            ,strTaste = IMP.strTaste
            ,strMouthFeel = IMP.strMouthfeel
        FROM tblQMSample S
        INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
        INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
        INNER JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
            ON V.intEntityId = S.intEntityId
        INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
        LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
        LEFT JOIN tblSMCountry ORIGIN ON ORIGIN.intCountryID = S.intCountryID
        INNER JOIN (
            tblQMImportCatalogue IMP
            INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
            -- Colour
            LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.strType = 'Season' AND COLOUR.strDescription = IMP.strColour
            -- Size
            LEFT JOIN tblICBrand SIZE ON SIZE.strBrandCode = IMP.strSize
            -- Style
            LEFT JOIN tblCTValuationGroup STYLE ON STYLE.strName = IMP.strStyle
            -- Tealingo Item
            LEFT JOIN tblICItem ITEM ON ITEM.strItemNo = IMP.strTealingoItem
            -- TBO
			LEFT JOIN tblSMCompanyLocation TBO ON TBO.strLocationName = IMP.strBuyingCenter
        )
            ON SY.strSaleYear = IMP.strSaleYear
            AND CL.strLocationName = IMP.strBuyingCenter
            AND S.strSaleNumber = IMP.strSaleNumber
            AND CT.strCatalogueType = IMP.strCatalogueType
            AND E.strName = IMP.strSupplier
            AND S.strRepresentLotNumber = IMP.strLotNumber
        WHERE IMP.intImportLogId = @intImportLogId
            AND ISNULL(IMP.strBatchNo, '') = ''
            AND IMP.ysnSuccess = 1
        
        UNION ALL

        SELECT
            intImportTypeId = 2 -- Pre-Shipment Sample Import
            ,intImportCatalogueId = IMP.intImportCatalogueId
            ,intSampleTypeId = S.intSampleTypeId
            ,intTemplateSampleTypeId = TEMPLATE_SAMPLE_TYPE.intSampleTypeId
            ,intCompanyLocationId = MU.intCompanyLocationId
            ,intColourId = COLOUR.intCommodityAttributeId
            ,strColour = COLOUR.strDescription
            ,intBrandId = SIZE.intBrandId
            ,strBrand = SIZE.strBrandCode
            ,strComments = IMP.strRemarks
            ,intSampleId = S.intSampleId
            ,intValuationGroupId = STYLE.intValuationGroupId
            ,strValuationGroup = STYLE.strName
            ,strOrigin = ORIGIN.strISOCode
            ,strSustainability = SUSTAINABILITY.strDescription
            ,strMusterLot = IMP.strMusterLot
            ,strMissingLot = IMP.strMissingLot
            ,strComments2 = IMP.strTastersRemarks
            ,intItemId = ITEM.intItemId
            ,intCategoryId = ITEM.intCategoryId
            ,dtmDateCreated = IL.dtmImportDate
            ,intEntityUserId = IL.intEntityId
            ,intBatchId = BATCH_TBO.intBatchId
            ,strBatchNo = BATCH_TBO.strBatchId
            ,strTINNumber = IMP.strTINNumber
            -- Test Properties
            ,strAppearance = IMP.strAppearance
            ,strHue = IMP.strHue
            ,strIntensity = IMP.strIntensity
            ,strTaste = IMP.strTaste
            ,strMouthFeel = IMP.strMouthfeel
        FROM tblQMSample S
        INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
        INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
        INNER JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
            ON V.intEntityId = S.intEntityId
        INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
        LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
        LEFT JOIN tblSMCountry ORIGIN ON ORIGIN.intCountryID = S.intCountryID
        INNER JOIN (
            tblQMImportCatalogue IMP
            INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
            -- Colour
            LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.strType = 'Season' AND COLOUR.strDescription = IMP.strColour
            -- Size
            LEFT JOIN tblICBrand SIZE ON SIZE.strBrandCode = IMP.strSize
            -- Style
            LEFT JOIN tblCTValuationGroup STYLE ON STYLE.strName = IMP.strStyle
            -- Tealingo Item
            LEFT JOIN tblICItem ITEM ON ITEM.strItemNo = IMP.strTealingoItem
            -- Template Sample Type
            LEFT JOIN tblQMSampleType TEMPLATE_SAMPLE_TYPE ON TEMPLATE_SAMPLE_TYPE.strSampleTypeName = IMP.strSampleTypeName
            -- Mixing Location
            LEFT JOIN tblSMCompanyLocation MU ON MU.strLocationName = IMP.strB1GroupNumber
            -- Batch MU
            LEFT JOIN tblMFBatch BATCH_MU ON BATCH_MU.strBatchId = IMP.strBatchNo AND BATCH_MU.intLocationId = MU.intCompanyLocationId
            -- Company Location
            LEFT JOIN tblSMCompanyLocation TBO ON TBO.intCompanyLocationId = BATCH_MU.intBuyingCenterLocationId
            -- Batch TBO
            LEFT JOIN tblMFBatch BATCH_TBO ON BATCH_TBO.strBatchId = BATCH_MU.strBatchId AND BATCH_TBO.intLocationId = TBO.intCompanyLocationId
        )
            ON BATCH_TBO.intSampleId = S.intSampleId
        WHERE IMP.intImportLogId = @intImportLogId
            AND ISNULL(IMP.strBatchNo, '') <> ''
            AND IMP.ysnSuccess = 1

    OPEN @C 
	FETCH NEXT FROM @C INTO
		@intImportType
        ,@intImportCatalogueId
        ,@intSampleTypeId
        ,@intTemplateSampleTypeId
        ,@intMixingUnitLocationId
        ,@intColourId
        ,@strColour
        ,@intBrandId
        ,@strBrand
        ,@strComments
        ,@intSampleId
        ,@intValuationGroupId
        ,@strValuationGroup
        ,@strOrigin
        ,@strSustainability
        ,@strMusterLot
	    ,@strMissingLot
        ,@strComments2
        ,@intItemId
        ,@intCategoryId
        ,@dtmDateCreated
        ,@intEntityUserId
        ,@intBatchId
        ,@strBatchNo
        ,@strTINNumber
        -- Test Properties
        ,@strAppearance
        ,@strHue
        ,@strIntensity
        ,@strTaste
        ,@strMouthFeel
	WHILE @@FETCH_STATUS = 0
	BEGIN
        SELECT @intBatchId
        -- Check if Batch ID is supplied in the template
        IF @intBatchId IS NOT NULL
        BEGIN
            IF @intMixingUnitLocationId IS NULL
            BEGIN
                UPDATE tblQMImportCatalogue
                SET
                    strLogResult = 'BUYER1 GROUP NAME is required if the BATCH NO is supplied'
                    ,ysnProcessed = 1
                    ,ysnSuccess = 0
                WHERE intImportCatalogueId = @intImportCatalogueId
                GOTO CONT
            END

            DECLARE @intBatchSampleId INT
            SET @intBatchSampleId = NULL

            SELECT TOP 1 @intBatchSampleId = intSampleId FROM tblQMSample WHERE strBatchNo = @strBatchNo AND intSampleTypeId = @intTemplateSampleTypeId AND intCompanyLocationId = @intMixingUnitLocationId
			SELECT @intProductValueId = NULL

			SELECT @intProductValueId = intBatchId
			FROM tblMFBatch
			WHERE strBatchId = @strBatchNo
				AND intLocationId = @intMixingUnitLocationId


            -- Insert new sample with product type = 13
            IF @intBatchSampleId IS NULL AND @intProductValueId IS NOT NULL
			 BEGIN
                DECLARE @strSampleNumber NVARCHAR(30)

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
                    ,strSampleBoxNumber
                    ,strComments3
                    ,intBrokerId
                    -- ,intTINClearanceId
                    )
                SELECT
                    intConcurrencyId = 1
                    ,intSampleTypeId = @intTemplateSampleTypeId
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
                    ,intSubBookId = S.intSubBookId

                    -- Auction Fields
                    ,intSaleYearId = S.intSaleYearId
                    ,strSaleNumber = S.strSaleNumber
                    ,dtmSaleDate = S.dtmSaleDate
                    ,intCatalogueTypeId = S.intCatalogueTypeId
                    ,dtmPromptDate = S.dtmPromptDate
                    ,strChopNumber = S.strChopNumber
                    ,intGradeId = S.intGradeId
                    ,intManufacturingLeafTypeId = S.intManufacturingLeafTypeId
                    ,intSeasonId = S.intSeasonId
                    ,intGardenMarkId = S.intGardenMarkId
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
                    ,strSampleBoxNumber = S.strSampleBoxNumber
                    ,strComments3 = S.strComments3
                    ,intBrokerId = S.intBrokerId
                    -- ,intTINClearanceId = @intTINClearanceId
                FROM tblQMSample S
                INNER JOIN tblMFBatch B ON B.intSampleId = S.intSampleId
                WHERE B.intBatchId = @intBatchId
                
                SET @intSampleId = SCOPE_IDENTITY()

				SELECT @intOriginalItemId=NULL
				Select @intOriginalItemId=intTealingoItemId
				from tblMFBatch 
				Where intBatchId = @intProductValueId

				Update dbo.tblMFBatch Set intSampleId =@intSampleId,intTealingoItemId =@intItemId,intOriginalItemId =@intOriginalItemId Where intBatchId = @intProductValueId
                
				IF @intItemId<>@intOriginalItemId
				BEGIN
					EXEC dbo.uspMFBatchPreStage 
						@intBatchId = @intProductValueId
						,@intUserId = @intEntityUserId
						,@intOriginalItemId = @intOriginalItemId
						,@intItemId = @intItemId
				END
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
                WHERE ST.intSampleTypeId = @intTemplateSampleTypeId
            END
            -- Update if existing sample exists
            ELSE BEGIN
				SELECT @intOriginalItemId=NULL
				Select @intOriginalItemId=intItemId
				from tblQMSample 
				Where intSampleId =@intBatchSampleId

                UPDATE S
                SET
                    intConcurrencyId = S.intConcurrencyId + 1
                    ,intLastModifiedUserId = @intEntityUserId
                    ,dtmLastModified = @dtmDateCreated
                    -- Auction Fields
                    -- ,intTINClearanceId = @intTINClearanceId
					,intItemId=@intItemId
                FROM tblQMSample S
                WHERE S.intSampleId = @intBatchSampleId

                SET @intSampleId = @intBatchSampleId

				Update tblMFBatch
				Set intTealingoItemId =@intItemId,intOriginalItemId =@intOriginalItemId
				Where intBatchId =@intProductValueId
            END

            IF @strTINNumber IS NOT NULL
            BEGIN
                DECLARE
                    @strOldTINNumber NVARCHAR(100)
                    ,@intOldCompanyLocationId INT
                -- Insert / Update TIN number linked to the sample / batch
                SELECT
                    @strOldTINNumber = TIN.strTINNumber
                    ,@intOldCompanyLocationId = B.intLocationId
                FROM tblQMTINClearance TIN
                INNER JOIN tblQMSample S ON S.intTINClearanceId = TIN.intTINClearanceId
                OUTER APPLY (SELECT intBatchId, intLocationId FROM tblMFBatch WHERE intBatchId = @intProductValueId) B                
                WHERE S.intSampleId = @intSampleId


                IF ISNULL(@strOldTINNumber, '') <> IsNULL(@strTINNumber,'') OR ISNULL(@intOldCompanyLocationId, 0) <> @intMixingUnitLocationId
                BEGIN
                    -- Delink old TIN number if there's an existing one and the TIN number has changed.
                    IF @strOldTINNumber IS NOT NULL
                    BEGIN
                        EXEC uspQMUpdateTINBatchId
                            @strTINNumber = @strOldTINNumber
                            ,@intBatchId = @intBatchId
                            ,@intCompanyLocationId = @intOldCompanyLocationId
                            ,@intEntityId = @intEntityUserId
                            ,@ysnDelink = 1
                    END

                    -- Link new TIN number with the pre-shipment sample / batch
                    EXEC uspQMUpdateTINBatchId
                        @strTINNumber = @strTINNumber
                        ,@intBatchId = @intProductValueId
                        ,@intCompanyLocationId = @intMixingUnitLocationId
                        ,@intEntityId = @intEntityUserId
                        ,@ysnDelink = 0

                    UPDATE tblQMSample
                    SET intTINClearanceId = (SELECT TOP 1 intTINClearanceId FROM tblQMTINClearance WHERE strTINNumber = @strTINNumber AND intBatchId = @intProductValueId AND intCompanyLocationId = @intMixingUnitLocationId)
                    WHERE intSampleId = @intSampleId
                END
            END
        END

        SELECT @intOriginalItemId = NULL
        SELECT @intOriginalItemId = intItemId
        FROM tblQMSample WHERE intSampleId = @intSampleId
        
        IF @intItemId IS NULL
            SELECT TOP 1 @intItemId = ITEM.intItemId
            FROM tblQMSample S
            INNER JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
            INNER JOIN (tblICCommodityAttribute CA INNER JOIN tblSMCountry ORIGIN ON ORIGIN.intCountryID = CA.intCountryID) ON CA.intCommodityAttributeId = S.intCountryID
            INNER JOIN tblICItem ITEM ON ITEM.strItemNo LIKE 
                @strBrand -- Leaf Size
                -- TODO: To update filter once Sub Cluster is provided
                + '%' -- To be updated by sub cluster
                + @strValuationGroup -- Leaf Style
                + ORIGIN.strISOCode -- Origin
                + '-'
                + SUSTAINABILITY.strDescription -- Rain Forest / Sustainability
            WHERE S.intSampleId = @intSampleId
            ORDER BY ITEM.strItemNo

        -- If Tealingo Item is provided in the template but does not match the testing score, throw an error
        IF (@intItemId IS NOT NULL AND dbo.fnQMValidateTealingoItemTastingScore(
                @intItemId
                ,CASE WHEN ISNULL(@strAppearance, '') = '' THEN NULL ELSE CAST(@strAppearance AS NUMERIC(18,6)) END -- APPEARANCE
                ,CASE WHEN ISNULL(@strHue, '') = '' THEN NULL ELSE CAST(@strHue AS NUMERIC(18,6)) END -- HUE
                ,CASE WHEN ISNULL(@strIntensity, '') = '' THEN NULL ELSE CAST(@strIntensity AS NUMERIC(18,6)) END -- INTENSITY
                ,CASE WHEN ISNULL(@strTaste, '') = '' THEN NULL ELSE CAST(@strTaste AS NUMERIC(18,6)) END -- TASTE
                ,CASE WHEN ISNULL(@strMouthFeel, '') = '' THEN NULL ELSE CAST(@strMouthFeel AS NUMERIC(18,6)) END -- MOUTH FEEL
            ) = 0
        )
        BEGIN
            UPDATE tblQMImportCatalogue
            SET strLogResult = 'WARNING: Import successful but the tasting score does not match the Tealingo item''s pinpoint values.'
            WHERE intImportCatalogueId = @intImportCatalogueId
        END
        
        -- If Tealingo item cannot be determined, fallback to default item.
        IF @intItemId IS NULL
            SELECT
                @intItemId = @intDefaultItemId
                ,@intCategoryId = @intDefaultCategoryId

        UPDATE S
        SET
            intConcurrencyId = S.intConcurrencyId + 1
            ,intSeasonId = @intColourId
            ,intBrandId = @intBrandId
            ,intValuationGroupId = @intValuationGroupId
            ,strMusterLot = @strMusterLot
            ,strMissingLot = @strMissingLot
            ,strComments2 = @strComments2
            ,intItemId = @intItemId
            ,intLastModifiedUserId = @intEntityUserId
            ,dtmLastModified = @dtmDateCreated
            ,intSampleStatusId = 3 -- Approved
        FROM tblQMSample S
        WHERE S.intSampleId = @intSampleId

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

        -- Clear test properties of the previous item
        DELETE FROM tblQMTestResult WHERE intSampleId = @intSampleId
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
            ,CASE WHEN @intBatchId IS NOT NULL THEN 13 ELSE 2 END
            ,CASE WHEN @intBatchId IS NOT NULL THEN @intBatchId ELSE @intItemId END 
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
            AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom) AND DATEPART(dy, PPV.dtmValidTo)
        ORDER BY PP.intSequenceNo

        -- Begin Update Actual Test Result

        -- Appearance
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strAppearance) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strAppearance END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strAppearance, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Appearance'

        -- Hue
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strHue) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strHue END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strHue, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Hue'

        -- Intensity
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strIntensity) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strIntensity END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strIntensity, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Intensity'

        -- Taste
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strTaste) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strTaste END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strTaste, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Taste'

        -- Mouth Feel
		UPDATE tblQMTestResult
		SET strPropertyValue = (CASE P.intDataTypeId WHEN 4 THEN LOWER(@strMouthFeel) ELSE (CASE WHEN ISNULL(TR.strFormula, '') <> '' THEN '' ELSE @strMouthFeel END) END)
			,strComment = @strComments
			,dtmPropertyValueCreated = (CASE WHEN ISNULL(@strMouthFeel, '') <> '' THEN GETDATE() ELSE NULL END)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId AND TR.intSampleId = @intSampleId
        WHERE TR.intSampleId = @intSampleId AND P.strPropertyName = 'Mouth Feel'

		-- Calculate and update formula property value
        DECLARE @FormulaProperty TABLE (
            intTestResultId INT
            ,strFormula NVARCHAR(MAX)
            ,strFormulaParser NVARCHAR(MAX)
		)

        DECLARE @intTestResultId INT
            ,@strFormula NVARCHAR(MAX)
            ,@strFormulaParser NVARCHAR(MAX)
            ,@strPropertyValue NVARCHAR(MAX)

		DELETE FROM @FormulaProperty

		INSERT INTO @FormulaProperty
		SELECT intTestResultId
			,strFormula
			,strFormulaParser
		FROM tblQMTestResult
		WHERE intSampleId = @intSampleId
			AND ISNULL(strFormula, '') <> ''
			AND ISNULL(strFormulaParser, '') <> ''
		ORDER BY intTestResultId

		SELECT @intTestResultId = MIN(intTestResultId) FROM @FormulaProperty

		WHILE (ISNULL(@intTestResultId, 0) > 0)
		BEGIN
			SELECT @strFormula = NULL
				,@strFormulaParser = NULL
				,@strPropertyValue = ''

			SELECT @strFormula = strFormula
				,@strFormulaParser = strFormulaParser
			FROM @FormulaProperty
			WHERE intTestResultId = @intTestResultId

			SELECT @strFormula = REPLACE(REPLACE(REPLACE(@strFormula, @strFormulaParser, ''), '{', ''), '}', '')

			IF @strFormulaParser = 'MAX'
			BEGIN
				SELECT @strPropertyValue = MAX(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END
			ELSE IF @strFormulaParser = 'MIN'
			BEGIN
				SELECT @strPropertyValue = MIN(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END
			ELSE IF @strFormulaParser = 'AVG'
			BEGIN
				SELECT @strPropertyValue = AVG(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END
			ELSE IF @strFormulaParser = 'SUM'
			BEGIN
				SELECT @strPropertyValue = SUM(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END

			IF @strPropertyValue <> ''
			BEGIN
				UPDATE tblQMTestResult
				SET strPropertyValue = dbo.fnRemoveTrailingZeroes(@strPropertyValue)
				WHERE intTestResultId = @intTestResultId
			END

			SELECT @intTestResultId = MIN(intTestResultId)
			FROM @FormulaProperty
			WHERE intTestResultId > @intTestResultId
		END

		-- Setting result for formula properties and the result which is not sent in excel
		UPDATE tblQMTestResult
		SET strResult = dbo.fnQMGetPropertyTestResult(TR.intTestResultId)
		FROM tblQMTestResult TR
		WHERE TR.intSampleId = @intSampleId
			AND ISNULL(TR.strResult, '') = ''

		-- Setting correct date format
		UPDATE tblQMTestResult
		SET strPropertyValue = CONVERT(DATETIME, TR.strPropertyValue, 120)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			AND TR.intSampleId = @intSampleId
			AND ISNULL(TR.strPropertyValue, '') <> ''
			AND P.intDataTypeId = 12

        UPDATE tblQMImportCatalogue
        SET intSampleId = @intSampleId
        WHERE intImportCatalogueId = @intImportCatalogueId

        CONT:
        FETCH NEXT FROM @C INTO
            @intImportType
            ,@intImportCatalogueId
            ,@intSampleTypeId
            ,@intTemplateSampleTypeId
            ,@intMixingUnitLocationId
            ,@intColourId
            ,@strColour
            ,@intBrandId
            ,@strBrand
            ,@strComments
            ,@intSampleId
            ,@intValuationGroupId
            ,@strValuationGroup
            ,@strOrigin
            ,@strSustainability
            ,@strMusterLot
            ,@strMissingLot
            ,@strComments2
            ,@intItemId
            ,@intCategoryId
            ,@dtmDateCreated
            ,@intEntityUserId
            ,@intBatchId
            ,@strBatchNo
            ,@strTINNumber
            -- Test Properties
            ,@strAppearance
            ,@strHue
            ,@strIntensity
            ,@strTaste
            ,@strMouthFeel
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