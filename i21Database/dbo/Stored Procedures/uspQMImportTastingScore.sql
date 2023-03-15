CREATE PROCEDURE [dbo].[uspQMImportTastingScore] @intImportLogId INT
AS
BEGIN TRY
	DECLARE @intProductValueId	INT
		  , @intOriginalItemId	INT
		  , @MFBatchTableType	MFBatchTableType
		  , @dtmCurrentDate		DATETIME
		  , @strBatchId			NVARCHAR(50)
		  , @strBulkDensity		NVARCHAR(50)
		  , @strTeaMoisture		NVARCHAR(50)
		  , @strFines			NVARCHAR(50)
		  , @strTeaVolume		NVARCHAR(50)
		  , @strDustContent		NVARCHAR(50)

	SELECT @dtmCurrentDate = Convert(CHAR, GETDATE(), 101)

	BEGIN TRANSACTION

	/* Validate Foreign Key Fields. */

	UPDATE IMP
	SET strLogResult	= 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage), charindex(',', reverse(MSG.strLogMessage)) + 1, len(MSG.strLogMessage)))
	  , ysnSuccess		= 0
	  , ysnProcessed	= 1
	FROM tblQMImportCatalogue IMP
	LEFT JOIN tblICCommodityAttribute AS Colour ON Colour.strType = 'Season' AND Colour.strDescription = IMP.strColour
	LEFT JOIN tblICBrand AS Size ON Size.strBrandCode = IMP.strSize 
	LEFT JOIN tblCTValuationGroup AS Style ON Style.strName = IMP.strStyle
	LEFT JOIN tblICItem AS Item ON Item.strItemNo = IMP.strTealingoItem
	LEFT JOIN tblMFBatch AS Batch ON Batch.strBatchId = IMP.strBatchNo
	LEFT JOIN tblQMSampleType AS SampleType ON SampleType.strSampleTypeName = IMP.strSampleTypeName
	LEFT JOIN tblCTBook AS Book ON (Book.strBook = IMP.strB1GroupNumber OR Book.strBookDescription = IMP.strB1GroupNumber)
	LEFT JOIN tblSMCompanyLocation Buyer1GroupNumber ON Buyer1GroupNumber.strLocationName = Book.strBook
	OUTER APPLY 
	(
		SELECT strLogMessage = CASE WHEN (Colour.intCommodityAttributeId IS NULL AND ISNULL(IMP.strColour, '') <> '') THEN 'COLOUR, '
									ELSE ''
							   END 
							 + CASE WHEN (Size.intBrandId IS NULL AND ISNULL(IMP.strSize, '') <> '') THEN 'SIZE, ' 
									ELSE ''
							   END 
							 + CASE WHEN (Style.intValuationGroupId IS NULL AND ISNULL(IMP.strStyle, '') <> '') THEN 'STYLE, '
									ELSE ''
							   END 
							 + CASE WHEN (Item.intItemId IS NULL AND ISNULL(IMP.strTealingoItem, '') <> '') THEN 'TEALINGO ITEM, '
									ELSE ''
							   END 
							 + CASE WHEN (SampleType.intSampleTypeId IS NULL AND ISNULL(IMP.strSampleTypeName, '') <> '') THEN 'SAMPLE TYPE, '
									ELSE ''
							   END 
							 + CASE WHEN (Buyer1GroupNumber.intCompanyLocationId IS NULL AND ISNULL(IMP.strB1GroupNumber, '') <> '') THEN 'BUYER1 GROUP NUMBER, '
									ELSE ''
							   END
	) MSG
	WHERE IMP.intImportLogId = @intImportLogId
		AND IMP.ysnSuccess = 1
		AND 
		(
			(Colour.intCommodityAttributeId IS NULL AND ISNULL(IMP.strColour, '') <> '')
		 OR (Size.intBrandId IS NULL AND ISNULL(IMP.strSize, '') <> '' )
		 OR (Style.intValuationGroupId IS NULL AND ISNULL(IMP.strStyle, '') <> '')
		 OR (Item.intItemId IS NULL AND ISNULL(IMP.strTealingoItem, '') <> '')
		 OR (SampleType.intSampleTypeId IS NULL AND ISNULL(IMP.strSampleTypeName, '') <> '')
		 OR (Buyer1GroupNumber.intCompanyLocationId IS NULL AND ISNULL(IMP.strB1GroupNumber, '') <> '')
		)

	/* End of Validate Foreign Key Fields. */

	EXECUTE uspQMImportValidationCatalogue @intImportLogId;

	DECLARE @intImportType INT
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
	DECLARE @intBatchSampleId INT
		,@ysnCreate BIT

	SELECT @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	SELECT TOP 1 @intDefaultItemId = [intDefaultItemId]
		,@intDefaultCategoryId = I.intCategoryId
	FROM tblQMCatalogueImportDefaults CID
	INNER JOIN tblICItem I ON I.intItemId = CID.intDefaultItemId

	IF OBJECT_ID('tempdb..##tmpQMCatalogueImport') IS NOT NULL
        DROP TABLE ##tmpQMCatalogueImport

	;WITH CTE AS (
		SELECT intImportType = 1 -- Auction/Non-Action Sample Import
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
			,[strBulkDensity] = IMP.strBulkDensity
			,[strTeaMoisture] = IMP.strTeaMoisture
			,[strFines] = IMP.strFines
			,[strTeaVolume] = IMP.strTeaVolume
			,[strDustContent] = IMP.strDustContent
		FROM tblQMSample S
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
		INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
		INNER JOIN (
			tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
			) ON V.intEntityId = S.intEntityId
		INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
		LEFT JOIN tblSMCountry ORIGIN ON ORIGIN.intCountryID = S.intCountryID
		LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
		INNER JOIN (
			tblQMImportCatalogue IMP INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
			-- Colour
			LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.strType = 'Season'
				AND COLOUR.strDescription = IMP.strColour
			-- Size
			LEFT JOIN tblICBrand SIZE ON SIZE.strBrandCode = IMP.strSize
			-- Style
			LEFT JOIN tblCTValuationGroup STYLE ON STYLE.strName = IMP.strStyle
			-- Tealingo Item
			LEFT JOIN tblICItem ITEM ON ITEM.strItemNo = IMP.strTealingoItem
			-- TBO
			LEFT JOIN tblSMCompanyLocation TBO ON TBO.strLocationName = IMP.strBuyingCenter
			) ON SY.strSaleYear = IMP.strSaleYear
			AND CL.strLocationName = IMP.strBuyingCenter
			AND S.strSaleNumber = IMP.strSaleNumber
			AND CT.strCatalogueType = IMP.strCatalogueType
			AND E.strName = IMP.strSupplier
			AND S.strRepresentLotNumber = IMP.strLotNumber
		WHERE IMP.intImportLogId = @intImportLogId
			AND ISNULL(IMP.strBatchNo, '') = ''
			AND IMP.ysnSuccess = 1
		
		UNION ALL
		
		SELECT intImportTypeId = 2 -- Pre-Shipment Sample Import
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
			,strOrigin = IMP.strGardenGeoOrigin 
			,strSustainability = IMP.strSustainability
			,strMusterLot = IMP.strMusterLot
			,strMissingLot = IMP.strMissingLot
			,strComments2 = IMP.strTastersRemarks
			,intItemId = ITEM.intItemId
			,intCategoryId = ITEM.intCategoryId
			,dtmDateCreated = IL.dtmImportDate
			,intEntityUserId = IL.intEntityId
			,intBatchId = BATCH_TBO.intBatchId
			,strBatchNo = IMP.strBatchNo
			,strTINNumber = IMP.strTINNumber
			-- Test Properties
			,strAppearance = IMP.strAppearance
			,strHue = IMP.strHue
			,strIntensity = IMP.strIntensity
			,strTaste = IMP.strTaste
			,strMouthFeel = IMP.strMouthfeel
			,[strBulkDensity] = IMP.strBulkDensity
			,[strTeaMoisture] = IMP.strTeaMoisture
			,[strFines] = IMP.strFines
			,[strTeaVolume] = IMP.strTeaVolume
			,[strDustContent] = IMP.strDustContent
		FROM tblQMSample S
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
		INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
		INNER JOIN (
			tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
			) ON V.intEntityId = S.intEntityId
		INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
		LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
		LEFT JOIN tblSMCountry ORIGIN ON ORIGIN.intCountryID = S.intCountryID
		INNER JOIN (
			tblQMImportCatalogue IMP INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
			-- Colour
			LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.strType = 'Season'
				AND COLOUR.strDescription = IMP.strColour
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
			LEFT JOIN tblMFBatch BATCH_MU ON BATCH_MU.strBatchId = IMP.strBatchNo
				AND BATCH_MU.intLocationId = MU.intCompanyLocationId
			-- Company Location
			LEFT JOIN tblSMCompanyLocation TBO ON TBO.intCompanyLocationId = BATCH_MU.intBuyingCenterLocationId
			-- Batch TBO
			LEFT JOIN tblMFBatch BATCH_TBO ON BATCH_TBO.strBatchId = BATCH_MU.strBatchId
				AND BATCH_TBO.intLocationId = TBO.intCompanyLocationId
			) ON SY.strSaleYear = IMP.strSaleYear
			AND CL.strLocationName = IMP.strBuyingCenter
			AND S.strSaleNumber = IMP.strSaleNumber
			AND CT.strCatalogueType = IMP.strCatalogueType
			AND E.strName = IMP.strSupplier
			AND S.strRepresentLotNumber = IMP.strLotNumber
		WHERE IMP.intImportLogId = @intImportLogId
			AND ISNULL(IMP.strBatchNo, '') <> ''
			AND IMP.ysnSuccess = 1
	)
	SELECT *
	INTO ##tmpQMCatalogueImport
	FROM CTE

	-- Clear test properties of the previous item
	DELETE TR
	FROM tblQMTestResult TR
	INNER JOIN ##tmpQMCatalogueImport R ON TR.intSampleId = R.intSampleId
	WHERE R.intSampleId IS NOT NULL
	AND R.intImportType = 1

	-- Loop through each valid import detail
	DECLARE @C AS CURSOR;

	SET @C = CURSOR LOCAL FAST_FORWARD
	FOR

	SELECT * FROM ##tmpQMCatalogueImport

	OPEN @C

	FETCH NEXT
	FROM @C
	INTO @intImportType
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
		,@strBulkDensity
		,@strTeaMoisture
		,@strFines
		,@strTeaVolume
		,@strDustContent

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ysnCreate = 0
		SET @intBatchSampleId = NULL

		
		-- Check if Batch ID is supplied in the template
		IF @intBatchId IS NOT NULL
		BEGIN
			IF @intMixingUnitLocationId IS NULL
			BEGIN
				UPDATE tblQMImportCatalogue
				SET strLogResult = 'BUYER1 GROUP NAME is required if the BATCH NO is supplied'
					,ysnProcessed = 1
					,ysnSuccess = 0
				WHERE intImportCatalogueId = @intImportCatalogueId

				GOTO CONT
			END

			SELECT TOP 1 @intBatchSampleId = intSampleId,@intSampleId = intSampleId
			FROM tblQMSample
			WHERE strBatchNo = @strBatchNo
				AND intSampleTypeId = @intTemplateSampleTypeId
				AND intCompanyLocationId = @intMixingUnitLocationId

			SELECT @intProductValueId = NULL

			SELECT @intProductValueId = intBatchId
			FROM tblMFBatch
			WHERE strBatchId = @strBatchNo
				AND intLocationId = @intMixingUnitLocationId

			-- Insert new sample with product type = 13
			IF @intBatchSampleId IS NULL
				AND @intProductValueId IS NOT NULL
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
					)
				-- ,intTINClearanceId
				SELECT intConcurrencyId = 1
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
				SET @ysnCreate = 1

				EXEC uspQMGenerateSampleCatalogueImportAuditLog @intSampleId = @intSampleId
					,@intUserEntityId = @intEntityUserId
					,@ysnCreate = 1

				SELECT @intOriginalItemId = NULL

				SELECT @intOriginalItemId = intTealingoItemId
				FROM tblMFBatch
				WHERE intBatchId = @intProductValueId

				UPDATE dbo.tblMFBatch
				SET intSampleId = @intSampleId
					,intTealingoItemId = @intItemId
					,intOriginalItemId = @intOriginalItemId
				WHERE intBatchId = @intProductValueId

				--IF @intItemId <> @intOriginalItemId
				--BEGIN
					EXEC dbo.uspMFBatchPreStage @intBatchId = @intProductValueId
						,@intUserId = @intEntityUserId
						,@intOriginalItemId = @intOriginalItemId
						,@intItemId = @intItemId
				--END

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
			ELSE
			BEGIN
				DELETE TR
				FROM tblQMTestResult TR
				WHERE TR.intSampleId = @intBatchSampleId

				EXEC uspQMGenerateSampleCatalogueImportAuditLog @intSampleId = @intBatchSampleId
					,@intUserEntityId = @intEntityUserId
					,@strRemarks = 'Updated from Tasting Score Import'
					,@ysnCreate = 0
					,@ysnBeforeUpdate = 1

				IF @intItemId IS NOT NULL
				BEGIN
					SELECT @intOriginalItemId = NULL

					SELECT @intOriginalItemId = intItemId
					FROM tblQMSample
					WHERE intSampleId = @intBatchSampleId

					UPDATE S
					SET intConcurrencyId = S.intConcurrencyId + 1
						,intLastModifiedUserId = @intEntityUserId
						,dtmLastModified = @dtmDateCreated
						,intItemId = @intItemId
					FROM tblQMSample S
					WHERE S.intSampleId = @intBatchSampleId

					SET @intSampleId = @intBatchSampleId

					UPDATE tblMFBatch
					SET intTealingoItemId = @intItemId
						,intOriginalItemId = @intOriginalItemId
					WHERE intBatchId = @intProductValueId

					EXEC dbo.uspMFBatchPreStage @intBatchId = @intProductValueId
						,@intUserId = @intEntityUserId
						,@intOriginalItemId = @intOriginalItemId
						,@intItemId = @intItemId
				END
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
							,@intBatchId = @intBatchId
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
		END

		IF @intBatchSampleId IS NULL
			AND @ysnCreate = 0
			EXEC uspQMGenerateSampleCatalogueImportAuditLog @intSampleId = @intSampleId
				,@intUserEntityId = @intEntityUserId
				,@strRemarks = 'Updated from Tasting Score Import'
				,@ysnCreate = 0
				,@ysnBeforeUpdate = 1

		SELECT @intOriginalItemId = NULL

		SELECT @intOriginalItemId = intItemId
		FROM tblQMSample
		WHERE intSampleId = @intSampleId

		IF @intItemId IS NULL
			SELECT TOP 1 @intItemId=ITEM.intItemId
			FROM tblQMSample S
			INNER JOIN tblICItem ITEM ON ITEM.strItemNo LIKE @strBrand -- Leaf Size
				-- TODO: To update filter once Sub Cluster is provided
				+ '%' -- To be updated by sub cluster
				+ @strValuationGroup -- Leaf Style
				+ @strOrigin -- Origin
				+(Case When @strSustainability<>'' Then '-' + @strSustainability Else '' End) -- Rain Forest / Sustainability
			 JOIN tblQMProduct P ON P.intProductValueId = ITEM.intItemId AND P.intProductTypeId =  2 -- Item
             JOIN tblQMProductProperty PP ON PP.intProductId = P.intProductId
             JOIN tblQMProperty PROP ON PROP.intPropertyId = PP.intPropertyId
			 JOIN tblQMProductPropertyValidityPeriod PPVP
                ON PP.intProductPropertyId = PPVP.intProductPropertyId
                AND DATEPART(dayofyear , GETDATE()) BETWEEN DATEPART(dayofyear , PPVP.dtmValidFrom) AND DATEPART(dayofyear , PPVP.dtmValidTo)
           
    		    AND (Case 
				When PROP.strPropertyName = 'Appearance' then Case When @strAppearance is not null and IsNUmeric(@strAppearance)=1 Then CAST(@strAppearance AS NUMERIC(18, 6)) Else PPVP.dblPinpointValue End
				When PROP.strPropertyName = 'Hue' then  Case When @strHue is not null and IsNUmeric(@strHue)=1 Then CAST(@strHue AS NUMERIC(18, 6)) Else PPVP.dblPinpointValue End 
				When PROP.strPropertyName = 'Intensity' then  Case When @strIntensity is not null and IsNUmeric(@strIntensity)=1 Then CAST(@strIntensity AS NUMERIC(18, 6)) Else PPVP.dblPinpointValue End 
				When PROP.strPropertyName = 'Taste' then  Case When @strTaste is not null and IsNUmeric(@strTaste)=1 Then CAST(@strTaste AS NUMERIC(18, 6)) Else PPVP.dblPinpointValue End 
				When PROP.strPropertyName = 'Mouth Feel' then Case When @strMouthFeel is not null and IsNUmeric(@strMouthFeel)=1 Then CAST(@strMouthFeel AS NUMERIC(18, 6)) Else PPVP.dblPinpointValue End 
				END) BETWEEN PPVP.dblMinValue  AND PPVP.dblMaxValue
			WHERE S.intSampleId = @intSampleId
			Group by ITEM.intItemId
			ORDER BY COUNT(1) Desc
			--ORDER BY ITEM.strItemNo

		---- If Tealingo Item is provided in the template but does not match the testing score, throw an error
		--IF (
		--		@intItemId IS NOT NULL
		--		AND dbo.fnQMValidateTealingoItemTastingScore(@intItemId, CASE 
		--				WHEN ISNULL(@strAppearance, '') = ''
		--					THEN NULL
		--				ELSE CAST(@strAppearance AS NUMERIC(18, 6))
		--				END -- APPEARANCE
		--			, CASE 
		--				WHEN ISNULL(@strHue, '') = ''
		--					THEN NULL
		--				ELSE CAST(@strHue AS NUMERIC(18, 6))
		--				END -- HUE
		--			, CASE 
		--				WHEN ISNULL(@strIntensity, '') = ''
		--					THEN NULL
		--				ELSE CAST(@strIntensity AS NUMERIC(18, 6))
		--				END -- INTENSITY
		--			, CASE 
		--				WHEN ISNULL(@strTaste, '') = ''
		--					THEN NULL
		--				ELSE CAST(@strTaste AS NUMERIC(18, 6))
		--				END -- TASTE
		--			, CASE 
		--				WHEN ISNULL(@strMouthFeel, '') = ''
		--					THEN NULL
		--				ELSE CAST(@strMouthFeel AS NUMERIC(18, 6))
		--				END -- MOUTH FEEL
		--		) = 0
		--		)
		--BEGIN
		--	UPDATE tblQMImportCatalogue
		--	SET strLogResult = 'WARNING: Import successful but the tasting score does not match the Tealingo item''s pinpoint values.'
		--	WHERE intImportCatalogueId = @intImportCatalogueId
		--END

		-- If Tealingo item cannot be determined, fallback to default item.
		IF @intItemId IS NULL 
		BEGIN
		 IF @intImportType=1
			BEGIN
				SELECT @intItemId = @intDefaultItemId
					,@intCategoryId = @intDefaultCategoryId
			END
			ELSE
			BEGIN
				SELECT @intItemId = @intOriginalItemId
					,@intCategoryId = @intDefaultCategoryId
			END
		END

		UPDATE S
		SET intConcurrencyId = S.intConcurrencyId + 1
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

		EXEC dbo.uspMFBatchPreStage @intBatchId = @intProductValueId
				,@intUserId = @intEntityUserId
				,@intOriginalItemId = @intOriginalItemId
				,@intItemId = @intItemId

		UPDATE tblMFBatch
		SET intTealingoItemId = @intItemId
			,intOriginalItemId = @intOriginalItemId
		WHERE intBatchId = @intProductValueId

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

		
		Begin


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
			,CASE 
				WHEN @intBatchId IS NOT NULL
					THEN 13
				ELSE 2
				END
			,CASE 
				WHEN @intBatchId IS NOT NULL
					THEN @intBatchId
				ELSE @intItemId
				END
			,PP.intTestId
			,PP.intPropertyId
			,''
			,CASE 
				WHEN PRT.strPropertyName = 'Density'
					THEN @strBulkDensity
				WHEN PRT.strPropertyName = 'Moisture'
					THEN @strTeaMoisture
				WHEN PRT.strPropertyName = 'Fines'
					THEN @strFines
				WHEN PRT.strPropertyName = 'Volume'
					THEN @strTeaVolume
				WHEN PRT.strPropertyName = 'Dust Level'
					THEN @strDustContent
				WHEN PRT.strPropertyName = 'Appearance' AND isNumeric(@strAppearance)=1 
					THEN @strAppearance
				WHEN PRT.strPropertyName = 'Appearance' AND isNumeric(@strAppearance)=0
					THEN Convert(nvarchar(50),PPV.dblPinpointValue)
				WHEN PRT.strPropertyName = 'Hue' AND isNumeric(@strHue)=1 
					THEN @strHue
					WHEN PRT.strPropertyName = 'Hue' AND isNumeric(@strHue)=0
					THEN Convert(nvarchar(50),PPV.dblPinpointValue)
				WHEN PRT.strPropertyName = 'Intensity' AND isNumeric(@strIntensity)=1 
					THEN @strIntensity
					WHEN PRT.strPropertyName = 'Intensity' AND isNumeric(@strIntensity)=0 
					THEN Convert(nvarchar(50),PPV.dblPinpointValue)
				WHEN PRT.strPropertyName = 'Taste' AND isNumeric(@strTaste)=1 
					THEN @strTaste
					WHEN PRT.strPropertyName = 'Taste' AND isNumeric(@strTaste)=0
					THEN Convert(nvarchar(50),PPV.dblPinpointValue)
				WHEN PRT.strPropertyName = 'Mouth Feel' AND isNumeric(@strMouthFeel)=1 
					THEN @strMouthFeel
					WHEN PRT.strPropertyName = 'Mouth Feel' AND isNumeric(@strMouthFeel)=0 
					THEN Convert(nvarchar(50),PPV.dblPinpointValue)
				END
			,@dtmDateCreated
			,''
			,0
			,@strComments 
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
		
		---- Begin Update Actual Test Result
		---- Appearance
		--UPDATE tblQMTestResult
		--SET strPropertyValue = (
		--		CASE P.intDataTypeId
		--			WHEN 4
		--				THEN LOWER(@strAppearance)
		--			ELSE (
		--					CASE 
		--						WHEN ISNULL(TR.strFormula, '') <> ''
		--							THEN ''
		--						ELSE @strAppearance
		--						END
		--					)
		--			END
		--		)
		--	,strComment = @strComments
		--	,dtmPropertyValueCreated = (
		--		CASE 
		--			WHEN ISNULL(@strAppearance, '') <> ''
		--				THEN GETDATE()
		--			ELSE NULL
		--			END
		--		)
		--FROM tblQMTestResult TR
		--JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		--	AND TR.intSampleId = @intSampleId
		--WHERE TR.intSampleId = @intSampleId
		--	AND P.strPropertyName = 'Appearance'

		---- Hue
		--UPDATE tblQMTestResult
		--SET strPropertyValue = (
		--		CASE P.intDataTypeId
		--			WHEN 4
		--				THEN LOWER(@strHue)
		--			ELSE (
		--					CASE 
		--						WHEN ISNULL(TR.strFormula, '') <> ''
		--							THEN ''
		--						ELSE @strHue
		--						END
		--					)
		--			END
		--		)
		--	,strComment = @strComments
		--	,dtmPropertyValueCreated = (
		--		CASE 
		--			WHEN ISNULL(@strHue, '') <> ''
		--				THEN GETDATE()
		--			ELSE NULL
		--			END
		--		)
		--FROM tblQMTestResult TR
		--JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		--	AND TR.intSampleId = @intSampleId
		--WHERE TR.intSampleId = @intSampleId
		--	AND P.strPropertyName = 'Hue'

		---- Intensity
		--UPDATE tblQMTestResult
		--SET strPropertyValue = (
		--		CASE P.intDataTypeId
		--			WHEN 4
		--				THEN LOWER(@strIntensity)
		--			ELSE (
		--					CASE 
		--						WHEN ISNULL(TR.strFormula, '') <> ''
		--							THEN ''
		--						ELSE @strIntensity
		--						END
		--					)
		--			END
		--		)
		--	,strComment = @strComments
		--	,dtmPropertyValueCreated = (
		--		CASE 
		--			WHEN ISNULL(@strIntensity, '') <> ''
		--				THEN GETDATE()
		--			ELSE NULL
		--			END
		--		)
		--FROM tblQMTestResult TR
		--JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		--	AND TR.intSampleId = @intSampleId
		--WHERE TR.intSampleId = @intSampleId
		--	AND P.strPropertyName = 'Intensity'

		---- Taste
		--UPDATE tblQMTestResult
		--SET strPropertyValue = (
		--		CASE P.intDataTypeId
		--			WHEN 4
		--				THEN LOWER(@strTaste)
		--			ELSE (
		--					CASE 
		--						WHEN ISNULL(TR.strFormula, '') <> ''
		--							THEN ''
		--						ELSE @strTaste
		--						END
		--					)
		--			END
		--		)
		--	,strComment = @strComments
		--	,dtmPropertyValueCreated = (
		--		CASE 
		--			WHEN ISNULL(@strTaste, '') <> ''
		--				THEN GETDATE()
		--			ELSE NULL
		--			END
		--		)
		--FROM tblQMTestResult TR
		--JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		--	AND TR.intSampleId = @intSampleId
		--WHERE TR.intSampleId = @intSampleId
		--	AND P.strPropertyName = 'Taste'

		---- Mouth Feel
		--UPDATE tblQMTestResult
		--SET strPropertyValue = (
		--		CASE P.intDataTypeId
		--			WHEN 4
		--				THEN LOWER(@strMouthFeel)
		--			ELSE (
		--					CASE 
		--						WHEN ISNULL(TR.strFormula, '') <> ''
		--							THEN ''
		--						ELSE @strMouthFeel
		--						END
		--					)
		--			END
		--		)
		--	,strComment = @strComments
		--	,dtmPropertyValueCreated = (
		--		CASE 
		--			WHEN ISNULL(@strMouthFeel, '') <> ''
		--				THEN GETDATE()
		--			ELSE NULL
		--			END
		--		)
		--FROM tblQMTestResult TR
		--JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		--	AND TR.intSampleId = @intSampleId
		--WHERE TR.intSampleId = @intSampleId
		--	AND P.strPropertyName = 'Mouth Feel'

		UPDATE tblQMImportCatalogue
		SET intSampleId = @intSampleId
		WHERE intImportCatalogueId = @intImportCatalogueId

		EXEC uspQMGenerateSampleCatalogueImportAuditLog @intSampleId = @intSampleId
			,@intUserEntityId = @intEntityUserId
			,@strRemarks = 'Updated from Tasting Score Import'
			,@ysnCreate = 0
			,@ysnBeforeUpdate = 0
		End

		IF @intImportType = 2
			AND NOT EXISTS (
				SELECT *
				FROM tblMFBatch
				WHERE strBatchId = @strBatchNo
				)
		BEGIN
			INSERT INTO @MFBatchTableType (
				strBatchId
				,intSales
				,intSalesYear
				,dtmSalesDate
				,strTeaType
				,intBrokerId
				,strVendorLotNumber
				,intBuyingCenterLocationId
				,intStorageLocationId
				,intStorageUnitId
				,intBrokerWarehouseId
				,intParentBatchId
				,intInventoryReceiptId
				,intSampleId
				,intContractDetailId
				,str3PLStatus
				,strSupplierReference
				,strAirwayBillCode
				,strAWBSampleReceived
				,strAWBSampleReference
				,dblBasePrice
				,ysnBoughtAsReserved
				,dblBoughtPrice
				,dblBulkDensity
				,strBuyingOrderNumber
				,intSubBookId
				,strContainerNumber
				,intCurrencyId
				,dtmProductionBatch
				,dtmTeaAvailableFrom
				,strDustContent
				,ysnEUCompliant
				,strTBOEvaluatorCode
				,strEvaluatorRemarks
				,dtmExpiration
				,intFromPortId
				,dblGrossWeight
				,dtmInitialBuy
				,dblWeightPerUnit
				,dblLandedPrice
				,strLeafCategory
				,strLeafManufacturingType
				,strLeafSize
				,strLeafStyle
				,intBookId
				,dblPackagesBought
				,intItemUOMId
				,intWeightUOMId
				,strTeaOrigin
				,intOriginalItemId
				,dblPackagesPerPallet
				,strPlant
				,dblTotalQuantity
				,strSampleBoxNumber
				,dblSellingPrice
				,dtmStock
				,ysnStrategic
				,strTeaLingoSubCluster
				,dtmSupplierPreInvoiceDate
				,strSustainability
				,strTasterComments
				,dblTeaAppearance
				,strTeaBuyingOffice
				,strTeaColour
				,strTeaGardenChopInvoiceNumber
				,intGardenMarkId
				,strTeaGroup
				,dblTeaHue
				,dblTeaIntensity
				,strLeafGrade
				,dblTeaMoisture
				,dblTeaMouthFeel
				,ysnTeaOrganic
				,dblTeaTaste
				,dblTeaVolume
				,intTealingoItemId
				,dtmWarehouseArrival
				,intYearManufacture
				,strPackageSize
				,intPackageUOMId
				,dblTareWeight
				,strTaster
				,strFeedStock
				,strFlourideLimit
				,strLocalAuctionNumber
				,strPOStatus
				,strProductionSite
				,strReserveMU
				,strQualityComments
				,strRareEarth
				,strFreightAgent
				,strSealNumber
				,strContainerType
				,strVoyage
				,strVessel
				,intLocationId
				,intMixingUnitLocationId
				,intMarketZoneId
				,dblTeaTastePinpoint
				,dblTeaHuePinpoint
				,dblTeaIntensityPinpoint
				,dblTeaMouthFeelPinpoint
				,dblTeaAppearancePinpoint
				,dtmShippingDate
				,strFines
				)
			SELECT strBatchId = @strBatchNo
				,intSales = CAST(S.strSaleNumber AS INT)
				,intSalesYear = CAST(SY.strSaleYear AS INT)
				,dtmSalesDate = S.dtmSaleDate
				,strTeaType = CT.strCatalogueType
				,intBrokerId = S.intBrokerId
				,strVendorLotNumber = S.strRepresentLotNumber
				,intBuyingCenterLocationId = S.intCompanyLocationId
				,intStorageLocationId = S.intDestinationStorageLocationId
				,intStorageUnitId = NULL
				,intBrokerWarehouseId = NULL
				,intParentBatchId = NULL
				,intInventoryReceiptId = S.intInventoryReceiptId
				,intSampleId = S.intSampleId
				,intContractDetailId = S.intContractDetailId
				,str3PLStatus = S.str3PLStatus
				,strSupplierReference = S.strAdditionalSupplierReference
				,strAirwayBillCode = S.strCourierRef
				,strAWBSampleReceived = CAST(S.intAWBSampleReceived AS NVARCHAR(50))
				,strAWBSampleReference = S.strAWBSampleReference
				,dblBasePrice = S.dblB1Price
				,ysnBoughtAsReserved = S.ysnBoughtAsReserve
				,dblBoughtPrice = S.dblB1Price
				,dblBulkDensity = CASE 
					WHEN ISNULL(Density.strPropertyValue, '') = ''
						THEN NULL
					ELSE CAST(Density.strPropertyValue AS NUMERIC(18, 6))
					END
				,strBuyingOrderNumber = S.strBuyingOrderNo
				,intSubBookId = S.intSubBookId
				,strContainerNumber = S.strContainerNumber
				,intCurrencyId = S.intCurrencyId
				,dtmProductionBatch = S.dtmManufacturingDate
				,dtmTeaAvailableFrom = NULL
				,strDustContent = DustLevel.strPropertyValue
				,ysnEUCompliant = S.ysnEuropeanCompliantFlag
				,strTBOEvaluatorCode = ECTBO.strName
				,strEvaluatorRemarks = S.strComments3
				,dtmExpiration = NULL
				,intFromPortId = S.intFromLocationCodeId
				,dblGrossWeight = S.dblGrossWeight
				,dtmInitialBuy = @dtmCurrentDate
				,dblWeightPerUnit = dbo.fnCalculateQtyBetweenUOM(QIUOM.intItemUOMId, WIUOM.intItemUOMId, 1)
				,dblLandedPrice = NULL
				,strLeafCategory = LEAF_CATEGORY.strAttribute2
				,strLeafManufacturingType = LEAF_TYPE.strDescription
				,strLeafSize = BRAND.strBrandCode
				,strLeafStyle = STYLE.strName
				,intBookId = S.intBookId
				,dblPackagesBought = IsNULL(S.dblB1QtyBought, S.dblRepresentingQty)
				,intItemUOMId = S.intSampleUOMId
				,intWeightUOMId = S.intSampleUOMId
				,strTeaOrigin = S.strCountry
				,intOriginalItemId = S.intItemId
				,dblPackagesPerPallet = IsNULL(I.intUnitPerLayer *I.intLayerPerPallet,20)
				,strPlant = MU.strVendorRefNoPrefix 
				,dblTotalQuantity = S.dblSampleQty 
				,strSampleBoxNumber = S.strSampleBoxNumber
				,dblSellingPrice = NULL
				,dtmStock = @dtmCurrentDate
				,ysnStrategic = NULL
				,strTeaLingoSubCluster = REGION.strDescription
				,dtmSupplierPreInvoiceDate = NULL
				,strSustainability = SUSTAINABILITY.strDescription
				,strTasterComments = S.strComments2
				,dblTeaAppearance = CASE 
					WHEN ISNULL(APPEARANCE.strPropertyValue, '') = ''
						THEN NULL
					ELSE CAST(APPEARANCE.strPropertyValue AS NUMERIC(18, 6))
					END
				,strTeaBuyingOffice = IMP.strBuyingCenter
				,strTeaColour = COLOUR.strDescription
				,strTeaGardenChopInvoiceNumber = S.strChopNumber
				,intGardenMarkId = S.intGardenMarkId
				,strTeaGroup = ISNULL(BRAND.strBrandCode, '') + ISNULL(REGION.strDescription, '') + ISNULL(STYLE.strName, '')
				,dblTeaHue = CASE 
					WHEN ISNULL(HUE.strPropertyValue, '') = ''
						THEN NULL
					ELSE CAST(HUE.strPropertyValue AS NUMERIC(18, 6))
					END
				,dblTeaIntensity = CASE 
					WHEN ISNULL(INTENSITY.strPropertyValue, '') = ''
						THEN NULL
					ELSE CAST(INTENSITY.strPropertyValue AS NUMERIC(18, 6))
					END
				,strLeafGrade = GRADE.strDescription
				,dblTeaMoisture = CASE 
					WHEN ISNULL(Moisture.strPropertyValue, '') = ''
						THEN NULL
					ELSE CAST(Moisture.strPropertyValue AS NUMERIC(18, 6))
					END
				,dblTeaMouthFeel = CASE 
					WHEN ISNULL(MOUTH_FEEL.strPropertyValue, '') = ''
						THEN NULL
					ELSE CAST(MOUTH_FEEL.strPropertyValue AS NUMERIC(18, 6))
					END
				,ysnTeaOrganic = S.ysnOrganic
				,dblTeaTaste = CASE 
					WHEN ISNULL(TASTE.strPropertyValue, '') = ''
						THEN NULL
					ELSE CAST(TASTE.strPropertyValue AS NUMERIC(18, 6))
					END
				,dblTeaVolume = CASE 
					WHEN ISNULL(Volume.strPropertyValue, '') = ''
						THEN NULL
					ELSE CAST(Volume.strPropertyValue AS NUMERIC(18, 6))
					END
				,intTealingoItemId = S.intItemId
				,dtmWarehouseArrival = NULL
				,intYearManufacture =  Datepart(YYYY,S.dtmManufacturingDate)
				,strPackageSize = PT.strUnitMeasure
				,intPackageUOMId = S.intNetWtPerPackagesUOMId
				,dblTareWeight = S.dblTareWeight
				,strTaster = IMP.strTaster
				,strFeedStock = NULL
				,strFlourideLimit = NULL
				,strLocalAuctionNumber = NULL
				,strPOStatus = NULL
				,strProductionSite = NULL
				,strReserveMU = NULL
				,strQualityComments = NULL
				,strRareEarth = NULL
				,strFreightAgent = NULL
				,strSealNumber = NULL
				,strContainerType = NULL
				,strVoyage = NULL
				,strVessel = NULL
				,intLocationId = MU.intCompanyLocationId
				,intMixingUnitLocationId = MU.intCompanyLocationId
				,intMarketZoneId = S.intMarketZoneId
				,dblTeaTastePinpoint = TASTE.dblPinpointValue
				,dblTeaHuePinpoint = HUE.dblPinpointValue
				,dblTeaIntensityPinpoint = INTENSITY.dblPinpointValue
				,dblTeaMouthFeelPinpoint = MOUTH_FEEL.dblPinpointValue
				,dblTeaAppearancePinpoint = APPEARANCE.dblPinpointValue
				,dtmShippingDate = @dtmCurrentDate
				,strFines = Fines.strPropertyValue 
			FROM tblQMSample S
			INNER JOIN tblQMImportCatalogue IMP ON IMP.intSampleId = S.intSampleId
			INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
			INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
			INNER JOIN tblICItem I ON I.intItemId = S.intItemId
			LEFT JOIN tblICCommodityAttribute REGION ON REGION.intCommodityAttributeId = I.intRegionId
			LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
			LEFT JOIN tblSMCompanyLocation MU ON MU.strLocationName = B.strBook
			LEFT JOIN tblICBrand BRAND ON BRAND.intBrandId = S.intBrandId
			LEFT JOIN tblCTValuationGroup STYLE ON STYLE.intValuationGroupId = S.intValuationGroupId
			LEFT JOIN tblICUnitMeasure PT on PT.intUnitMeasureId=S.intPackageTypeId
			-- Appearance
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Appearance'
				WHERE TR.intSampleId = S.intSampleId
				) APPEARANCE
			-- Hue
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Hue'
				WHERE TR.intSampleId = S.intSampleId
				) HUE
			-- Intensity
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Intensity'
				WHERE TR.intSampleId = S.intSampleId
				) INTENSITY
			-- Taste
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Taste'
				WHERE TR.intSampleId = S.intSampleId
				) TASTE
			-- Mouth Feel
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Mouth Feel'
				WHERE TR.intSampleId = S.intSampleId
				) MOUTH_FEEL

			-- Density
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Density'
				WHERE TR.intSampleId = S.intSampleId
				) Density

			-- Moisture
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Moisture'
				WHERE TR.intSampleId = S.intSampleId
				) Moisture

			-- Fines
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Fines'
				WHERE TR.intSampleId = S.intSampleId
				) Fines

			-- Volume
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Volume'
				WHERE TR.intSampleId = S.intSampleId
				) Volume

			-- Dust Level
			OUTER APPLY (
				SELECT TR.strPropertyValue
					,TR.dblPinpointValue
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND P.strPropertyName = 'Dust Level'
				WHERE TR.intSampleId = S.intSampleId
				) DustLevel

			-- Colour
			LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.intCommodityAttributeId = S.intSeasonId
			-- Manufacturing Leaf Type
			LEFT JOIN tblICCommodityAttribute LEAF_TYPE ON LEAF_TYPE.intCommodityAttributeId = S.intManufacturingLeafTypeId
			-- Evaluator's Code at TBO
			LEFT JOIN tblEMEntity ECTBO ON ECTBO.intEntityId = S.intEvaluatorsCodeAtTBOId
			-- Leaf Category
			LEFT JOIN tblICCommodityAttribute2 LEAF_CATEGORY ON LEAF_CATEGORY.intCommodityAttributeId2 = S.intLeafCategoryId
			-- Sustainability / Rainforest
			LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
			-- Grade
			LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.intCommodityAttributeId = S.intGradeId
			-- Weight Item UOM
			LEFT JOIN tblICItemUOM WIUOM ON WIUOM.intItemId = S.intItemId
				AND WIUOM.intUnitMeasureId = S.intSampleUOMId
			-- Qty Item UOM
			LEFT JOIN tblICItemUOM QIUOM ON QIUOM.intItemId = S.intItemId
				AND QIUOM.intUnitMeasureId = IsNULL(S.intB1QtyUOMId,S.intRepresentingUOMId)
			WHERE S.intSampleId = @intSampleId
				AND IMP.intImportLogId = @intImportLogId
				AND IsNULL(S.dblB1QtyBought, 0) > 0

			DECLARE @intInput INT
				,@intInputSuccess INT

			IF EXISTS (
					SELECT *
					FROM @MFBatchTableType
					)
			BEGIN
				EXEC uspMFUpdateInsertBatch @MFBatchTableType
					,@intInput
					,@intInputSuccess
					,@strBatchId OUTPUT
					,1

				SELECT @intBatchId = NULL

				SELECT @intBatchId = intBatchId
				FROM tblMFBatch
				WHERE strBatchId = @strBatchNo

				EXEC dbo.uspMFBatchPreStage @intBatchId = @intBatchId
					,@intUserId = @intEntityUserId
					,@intOriginalItemId = @intItemId
					,@intItemId = @intItemId

				UPDATE tblQMSample
				SET strBatchNo = @strBatchId
					,intProductTypeId = 13
					,intProductValueId = @intBatchId
				WHERE intSampleId = @intSampleId

				UPDATE tblQMTestResult
				SET intProductTypeId = 13
					,intProductValueId = @intBatchId
				WHERE intSampleId = @intSampleId
			END
		END

		CONT:

		FETCH NEXT
		FROM @C
		INTO @intImportType
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
			,@strBulkDensity
			,@strTeaMoisture
			,@strFines
			,@strTeaVolume
			,@strDustContent
	END

	CLOSE @C

	DEALLOCATE @C

	-- Setting correct date format
	UPDATE TR
	SET strPropertyValue = CONVERT(DATETIME, TR.strPropertyValue, 120)
	FROM tblQMTestResult TR
	INNER JOIN tblQMImportCatalogue IC ON IC.intSampleId = TR.intSampleId
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		AND IC.intImportLogId = @intImportLogId
		AND ISNULL(TR.strPropertyValue, '') <> ''
		AND P.intDataTypeId = 12
		
	-- Setting result for formula properties and the result which is not sent in excel
	UPDATE TR
	SET strResult = T.strResult
	FROM tblQMTestResult TR
	INNER JOIN tblQMImportCatalogue IC ON IC.intSampleId = TR.intSampleId
	OUTER APPLY dbo.fnQMGetPropertyTestResult2(TR.intTestResultId) T
	WHERE IC.intImportLogId = @intImportLogId
		AND ISNULL(TR.strResult, '') = ''

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