CREATE PROCEDURE uspQMSampleCreate @strXml NVARCHAR(Max)
	,@strSampleNumber NVARCHAR(30) OUTPUT
	,@intSampleId INT OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(Max)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @intLocationId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @intShiftId INT
	DECLARE @dtmBusinessDate DATETIME
	DECLARE @dtmCreated DATETIME = GETDATE()
	DECLARE @intInventoryReceiptId INT
	DECLARE @intInventoryShipmentId INT
	DECLARE @intWorkOrderId INT
	DECLARE @ysnEnableParentLot BIT
	DECLARE @strMarks NVARCHAR(100)
	DECLARE @intShipperEntityId INT
	DECLARE @intSampleTypeId INT
	DECLARE @intStorageLocationId INT
	DECLARE @dblSampleQty NUMERIC(18, 6)
	DECLARE @intSampleUOMId INT
	DECLARE @intPreviousSampleStatusId INT
	DECLARE @intItemId INT
	DECLARE @intLotId INT
	DECLARE @intLotStatusId INT
	DECLARE @dblQty NUMERIC(18, 6)
	DECLARE @intItemUOMId INT
	DECLARE @intCreatedUserId INT
	DECLARE @intSampleItemUOMId INT
	DECLARE @strReasonCode NVARCHAR(50)
	DECLARE @ysnAdjustInventoryQtyBySampleQty BIT
	DECLARE @intRepresentingUOMId INT
		,@dblRepresentingQty NUMERIC(18, 6)
		,@dblConvertedSampleQty NUMERIC(18, 6)
		,@intContractHeaderId INT
		,@ysnMultipleContractSeq BIT
	DECLARE @intOrgSampleTypeId INT
		,@intOrgItemId INT
		,@intOrgCountryID INT
		,@intOrgCompanyLocationSubLocationId INT
		,@intRelatedSampleId INT

	SELECT @intOrgSampleTypeId = intSampleTypeId
		,@intOrgItemId = intItemId
		,@intOrgCountryID = intCountryID
		,@intOrgCompanyLocationSubLocationId = intCompanyLocationSubLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSampleTypeId INT
			,intItemId INT
			,intCountryID INT
			,intCompanyLocationSubLocationId INT
			)
	
	SELECT @strSampleNumber = strSampleNumber
		,@strLotNumber = strLotNumber
		,@intLocationId = intLocationId
		,@intCompanyLocationId = intCompanyLocationId
		,@intInventoryReceiptId = intInventoryReceiptId
		,@intInventoryShipmentId = intInventoryShipmentId
		,@intWorkOrderId = intWorkOrderId
		,@strMarks = strMarks
		,@intSampleTypeId = intSampleTypeId
		,@intStorageLocationId = intStorageLocationId
		,@dblSampleQty = dblSampleQty
		,@intSampleUOMId = intSampleUOMId
		,@dblRepresentingQty = dblRepresentingQty
		,@intRepresentingUOMId = intRepresentingUOMId
		,@intPreviousSampleStatusId = intSampleStatusId
		,@intItemId = intItemId
		,@intCreatedUserId = intCreatedUserId
		,@intContractHeaderId = intContractHeaderId
		,@intRelatedSampleId = intRelatedSampleId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strSampleNumber NVARCHAR(30)
			,intCompanyLocationId INT
			,strLotNumber NVARCHAR(50)
			,intLocationId INT
			,intInventoryReceiptId INT
			,intInventoryShipmentId INT
			,intWorkOrderId INT
			,strMarks NVARCHAR(100)
			,intSampleTypeId INT
			,intStorageLocationId INT
			,dblSampleQty NUMERIC(18, 6)
			,intSampleUOMId INT
			,dblRepresentingQty NUMERIC(18, 6)
			,intRepresentingUOMId INT
			,intSampleStatusId INT
			,intItemId INT
			,intCreatedUserId INT
			,intContractHeaderId INT
			,intRelatedSampleId INT
			)

	-- Quantity Check
	IF ISNULL(@intSampleUOMId, 0) > 0
		AND ISNULL(@intRepresentingUOMId, 0) > 0
	BEGIN
		SELECT @dblConvertedSampleQty = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId, @intSampleUOMId, @intRepresentingUOMId, @dblSampleQty)

		IF (@dblConvertedSampleQty > @dblRepresentingQty)
    		AND (EXISTS (SELECT 1 FROM dbo.tblQMCompanyPreference WHERE ysnValidateSampleQty = 1)) 
		BEGIN
			RAISERROR (
					'Sample Qty cannot be greater than Representing Qty. '
					,16
					,1
					)
		END
	END

	-- If sample status is Approved / Rejected, setting default to Received
	IF @intPreviousSampleStatusId = 3 OR @intPreviousSampleStatusId = 4
	BEGIN
		SELECT @intPreviousSampleStatusId = 1
	END

	IF @intStorageLocationId IS NULL
		AND @strLotNumber IS NOT NULL
	BEGIN
		SELECT @intStorageLocationId = intStorageLocationId
		FROM tblICLot
		WHERE strLotNumber = @strLotNumber
	END

	IF (
			@strSampleNumber = ''
			OR @strSampleNumber IS NULL
			)
	BEGIN
		--EXEC dbo.uspSMGetStartingNumber 62
		--	,@strSampleNumber OUTPUT
		EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
			,@intItemId = NULL
			,@intManufacturingId = NULL
			,@intSubLocationId = NULL
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 62
			,@ysnProposed = 0
			,@strPatternString = @strSampleNumber OUTPUT
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblQMSample
			WHERE strSampleNumber = @strSampleNumber
			)
	BEGIN
		RAISERROR (
				'Sample number already exists. '
				,16
				,1
				)
	END

	IF (
			SELECT CASE 
					WHEN @strSampleNumber LIKE '%[@~$\`^&*()%?:<>!|\+;",{}'']%'
						THEN 0
					ELSE 1
					END
			) = 0
	BEGIN
		RAISERROR (
				'Special characters are not allowed for Sample Number. '
				,16
				,1
				)
	END

	IF (
			SELECT CASE 
					WHEN @strLotNumber LIKE '%[@~$\`^&*()%?<>!|\+;:",{}'']%'
						THEN 0
					ELSE 1
					END
			) = 0
	BEGIN
		RAISERROR (
				'Special characters are not allowed for Lot Number. '
				,16
				,1
				)
	END

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCreated, @intLocationId)

	SELECT @intShiftId = intShiftId
	FROM dbo.tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCreated BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	SELECT @ysnEnableParentLot = ysnEnableParentLot
	FROM dbo.tblQMCompanyPreference

	-- Inventory Receipt / Work Order No
	-- Creating sample from other screens should take value directly from xml
	IF ISNULL(@intInventoryReceiptId, 0) = 0
		AND ISNULL(@intWorkOrderId, 0) = 0
	BEGIN
		IF ISNULL(@strLotNumber, '') <> ''
		BEGIN
			IF @ysnEnableParentLot = 0 -- Lot
			BEGIN
				SELECT TOP 1 @intInventoryReceiptId = RI.intInventoryReceiptId
				FROM tblICInventoryReceiptItemLot RIL
				JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
				JOIN tblICLot L ON L.intLotId = RIL.intLotId
					AND L.strLotNumber = @strLotNumber
				ORDER BY RI.intInventoryReceiptId DESC

				IF ISNULL(@intInventoryReceiptId, 0) = 0
				BEGIN
					SELECT TOP 1 @intWorkOrderId = WPL.intWorkOrderId
					FROM tblMFWorkOrderProducedLot WPL
					JOIN tblICLot L ON L.intLotId = WPL.intLotId
						AND L.strLotNumber = @strLotNumber
					ORDER BY WPL.intWorkOrderId DESC
				END
			END
			ELSE -- Parent Lot
			BEGIN
				DECLARE @intParentLotId INT

				SELECT @intParentLotId = intParentLotId
				FROM tblICParentLot
				WHERE strParentLotNumber = @strLotNumber

				SELECT TOP 1 @intInventoryReceiptId = RI.intInventoryReceiptId
				FROM tblICInventoryReceiptItemLot RIL
				JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
				JOIN tblICLot L ON L.intLotId = RIL.intLotId
					AND L.intParentLotId = @intParentLotId
				ORDER BY RI.intInventoryReceiptId DESC

				IF ISNULL(@intInventoryReceiptId, 0) = 0
				BEGIN
					SELECT TOP 1 @intWorkOrderId = WPL.intWorkOrderId
					FROM tblMFWorkOrderProducedLot WPL
					JOIN tblICLot L ON L.intLotId = WPL.intLotId
						AND L.intParentLotId = @intParentLotId
					ORDER BY WPL.intWorkOrderId DESC
				END
			END
		END
	END

	-- Shipper Entity Id
	IF ISNULL(@strMarks, '') <> ''
	BEGIN
		DECLARE @strShipperCode NVARCHAR(MAX)
		DECLARE @intFirstIndex INT
		DECLARE @intSecondIndex INT

		SELECT @intFirstIndex = ISNULL(CHARINDEX('/', @strMarks), 0)

		SELECT @intSecondIndex = ISNULL(CHARINDEX('/', @strMarks, @intFirstIndex + 1), 0)

		IF (
				@intFirstIndex > 0
				AND @intSecondIndex > 0
				)
		BEGIN
			SELECT @strShipperCode = SUBSTRING(@strMarks, @intFirstIndex + 1, (@intSecondIndex - @intFirstIndex - 1))

			SELECT TOP 1 @intShipperEntityId = intEntityId
			FROM tblEMEntity
			WHERE strEntityNo = @strShipperCode
		END
		ELSE
		BEGIN
			SELECT @intShipperEntityId = NULL
		END
	END

	SELECT @ysnAdjustInventoryQtyBySampleQty = ysnAdjustInventoryQtyBySampleQty
		,@ysnMultipleContractSeq = ysnMultipleContractSeq
	FROM tblQMSampleType
	WHERE intSampleTypeId = @intSampleTypeId

	IF ISNULL(@strLotNumber, '') <> ''
	BEGIN
		IF @ysnEnableParentLot = 0 -- Lot
		BEGIN
			SELECT TOP 1 @intLotStatusId = intLotStatusId
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber
				AND intStorageLocationId = @intStorageLocationId
			ORDER BY intLotId DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1 @intLotStatusId = L.intLotStatusId
			FROM tblICParentLot PL
			JOIN tblICLot L ON L.intParentLotId = PL.intParentLotId
				AND PL.strParentLotNumber = @strLotNumber
			ORDER BY PL.intParentLotId DESC
		END
	END

	-- Contract Sequences check for Assign Contract to Multiple Sequences scenario
	IF @ysnMultipleContractSeq = 1
		AND ISNULL(@intContractHeaderId, 0) > 0
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM OPENXML(@idoc, 'root/SampleContractSequence', 2) WITH (intContractDetailId INT) x
				JOIN dbo.tblCTContractDetail CD ON CD.intContractDetailId = x.intContractDetailId
				WHERE CD.intContractHeaderId <> @intContractHeaderId
				)
		BEGIN
			RAISERROR (
					'Assigned Sequences should belongs to the same Contract. '
					,16
					,1
					)
		END
	END

	BEGIN TRAN

	--unlink existing related sample if related sample have value
	IF @intRelatedSampleId IS NOT NULL
		UPDATE tblQMSample SET intRelatedSampleId = NULL WHERE @intRelatedSampleId = intRelatedSampleId

	INSERT INTO dbo.tblQMSample (
		intConcurrencyId
		,intSampleTypeId
		,strSampleNumber
		,intCompanyLocationId
		,intParentSampleId
		,intRelatedSampleId
		,strSampleRefNo
		,intProductTypeId
		,intProductValueId
		,intSampleStatusId
		,intPreviousSampleStatusId
		,intItemId
		,intItemContractId
		,intContractHeaderId
		,intContractDetailId
		--,intShipmentBLContainerContractId
		--,intShipmentId
		--,intShipmentContractQtyId
		--,intShipmentBLContainerId
		,intLoadContainerId
		,intLoadDetailContainerLinkId
		,intLoadId
		,intLoadDetailId
		,intCountryID
		,ysnIsContractCompleted
		,intLotStatusId
		,intStorageLocationId
		,ysnAdjustInventoryQtyBySampleQty
		,intEntityId
		,intBookId
		,intSubBookId
		,intShipperEntityId
		,strShipmentNumber
		,strLotNumber
		,strSampleNote
		,dtmSampleReceivedDate
		--,dtmTestedOn
		--,intTestedById
		,dblSampleQty
		,intSampleUOMId
		,dblRepresentingQty
		,intRepresentingUOMId
		,strRefNo
		,dtmTestingStartDate
		,dtmTestingEndDate
		,dtmSamplingEndDate
		,dtmRequestedDate
		,dtmSampleSentDate
		,strSamplingMethod
		,strContainerNumber
		,strMarks
		,intCompanyLocationSubLocationId
		,strCountry
		,strComment
		,intItemBundleId
		,dtmBusinessDate
		,intShiftId
		,intLocationId
		,intInventoryReceiptId
		,intInventoryShipmentId
		,intWorkOrderId
		,strChildLotNumber
		,strCourier
		,strCourierRef
		,intForwardingAgentId
		,strForwardingAgentRef
		,strSentBy
		,intSentById
		,ysnImpactPricing
		,intSamplingCriteriaId
		,strSendSampleTo
		,strRepresentLotNumber
		, intSaleYearId 
  		, strSaleNumber 
		, strChopNumber 
		, dtmSaleDate   
		, intCatalogueTypeId 
		, dtmPromptDate   
		, intBrokerId 
		, intGradeId 
		, intLeafCategoryId 
		, intManufacturingLeafTypeId 
		, intSeasonId 
		, intGardenMarkId 
		, dtmManufacturingDate   
		, intTotalNumberOfPackageBreakups 
		, intNetWtPerPackagesUOMId
		, intNoOfPackages 
		, intNetWtSecondPackageBreakUOMId 
		, intNoOfPackagesSecondPackageBreak 
		, intNetWtThirdPackageBreakUOMId 
		, intNoOfPackagesThirdPackageBreak 
		, intProductLineId 
		, ysnOrganic 
		, dblSupplierValuationPrice
		, intProducerId 
		, intPurchaseGroupId 
		, strERPRefNo 
		, dblGrossWeight
		, dblTareWeight 
		, dblNetWeight
		, strBatchNo 
		, str3PLStatus 
		, strAdditionalSupplierReference 
		, intAWBSampleReceived 
		, strAWBSampleReference 
		, dblBasePrice
		, ysnBoughtAsReserve
		, intCurrencyId 
		, ysnEuropeanCompliantFlag 
		, intEvaluatorsCodeAtTBOId 
		, intFromLocationCodeId
		, strSampleBoxNumber 
		, intBrandId 
		, intValuationGroupId 
		, strMusterLot  
		, strMissingLot 
		, intMarketZoneId 
		, intDestinationStorageLocationId 
		, strComments2 
		, strComments3 
		, strBuyingOrderNo
		, intTINClearanceId
		, intBuyer1Id
		, dblB1QtyBought
		, intB1QtyUOMId
		, dblB1Price
		, intB1PriceUOMId
		, intBuyer2Id
		, dblB2QtyBought
		, intB2QtyUOMId
		, dblB2Price
		, intB2PriceUOMId
		, intBuyer3Id
		, dblB3QtyBought
		, intB3QtyUOMId
		, dblB3Price
		, intB3PriceUOMId
		, intBuyer4Id
		, dblB4QtyBought
		, intB4QtyUOMId
		, dblB4Price
		, intB4PriceUOMId
		, intBuyer5Id
		, dblB5QtyBought
		, intB5QtyUOMId
		, dblB5Price
		, intB5PriceUOMId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,intSampleTypeId
		,@strSampleNumber
		,@intCompanyLocationId
		,intParentSampleId
		,intRelatedSampleId
		,strSampleRefNo
		,intProductTypeId
		,intProductValueId
		,intSampleStatusId
		,@intPreviousSampleStatusId
		,intItemId
		,intItemContractId
		,intContractHeaderId
		,intContractDetailId
		--,intShipmentBLContainerContractId
		--,intShipmentId
		--,intShipmentContractQtyId
		--,intShipmentBLContainerId
		,intLoadContainerId
		,intLoadDetailContainerLinkId
		,intLoadId
		,intLoadDetailId
		,intCountryID
		,ysnIsContractCompleted
		,@intLotStatusId
		,IsNULL(intStorageLocationId, @intStorageLocationId)
		,IsNULL(ysnAdjustInventoryQtyBySampleQty, @ysnAdjustInventoryQtyBySampleQty)
		,intEntityId
		,intBookId
		,intSubBookId
		,@intShipperEntityId
		,strShipmentNumber
		,strLotNumber
		,strSampleNote
		,dtmSampleReceivedDate
		--,dtmTestedOn
		--,intTestedById
		,dblSampleQty
		,intSampleUOMId
		,dblRepresentingQty
		,intRepresentingUOMId
		,strRefNo
		,dtmTestingStartDate
		,dtmTestingEndDate
		,dtmSamplingEndDate
		,dtmRequestedDate = CASE WHEN dtmRequestedDate = CAST('' AS DATETIME) THEN NULL ELSE dtmRequestedDate END
		,dtmSampleSentDate = CASE WHEN dtmSampleSentDate = CAST('' AS DATETIME) THEN NULL ELSE dtmSampleSentDate END
		,strSamplingMethod
		,strContainerNumber
		,strMarks
		,intCompanyLocationSubLocationId
		,strCountry
		,strComment
		,intItemBundleId
		,@dtmBusinessDate
		,@intShiftId
		,intLocationId
		,@intInventoryReceiptId
		,@intInventoryShipmentId
		,@intWorkOrderId
		,strChildLotNumber
		,strCourier
		,strCourierRef
		,intForwardingAgentId
		,strForwardingAgentRef
		,strSentBy
		,intSentById
		,ysnImpactPricing
		,CASE intSamplingCriteriaId WHEN 0 THEN NULL ELSE intSamplingCriteriaId END intSamplingCriteriaId
		,strSendSampleTo
		,strRepresentLotNumber
		, intSaleYearId 
  		, strSaleNumber 
		, strChopNumber 
		, dtmSaleDate   
		, intCatalogueTypeId 
		, dtmPromptDate   
		, intBrokerId 
		, intGradeId 
		, intLeafCategoryId 
		, intManufacturingLeafTypeId 
		, intSeasonId 
		, intGardenMarkId 
		, dtmManufacturingDate   
		, intTotalNumberOfPackageBreakups 
		, intNetWtPerPackagesUOMId
		, intNoOfPackages 
		, intNetWtSecondPackageBreakUOMId 
		, intNoOfPackagesSecondPackageBreak 
		, intNetWtThirdPackageBreakUOMId 
		, intNoOfPackagesThirdPackageBreak 
		, intProductLineId 
		, ysnOrganic 
		, dblSupplierValuationPrice
		, intProducerId 
		, intPurchaseGroupId 
		, strERPRefNo 
		, dblGrossWeight
		, dblTareWeight 
		, dblNetWeight
		, strBatchNo 
		, str3PLStatus 
		, strAdditionalSupplierReference 
		, intAWBSampleReceived 
		, strAWBSampleReference 
		, dblBasePrice
		, ysnBoughtAsReserve
		, intCurrencyId 
		, ysnEuropeanCompliantFlag 
		, intEvaluatorsCodeAtTBOId 
		, intFromLocationCodeId
		, strSampleBoxNumber 
		, intBrandId 
		, intValuationGroupId 
		, strMusterLot  
		, strMissingLot 
		, intMarketZoneId 
		, intDestinationStorageLocationId 
		, strComments2 
		, strComments3  
		, strBuyingOrderNo
		, intTINClearanceId
		, intBuyer1Id
		, dblB1QtyBought
		, intB1QtyUOMId
		, dblB1Price
		, intB1PriceUOMId
		, intBuyer2Id
		, dblB2QtyBought
		, intB2QtyUOMId
		, dblB2Price
		, intB2PriceUOMId
		, intBuyer3Id
		, dblB3QtyBought
		, intB3QtyUOMId
		, dblB3Price
		, intB3PriceUOMId
		, intBuyer4Id
		, dblB4QtyBought
		, intB4QtyUOMId
		, dblB4Price
		, intB4PriceUOMId
		, intBuyer5Id
		, dblB5QtyBought
		, intB5QtyUOMId
		, dblB5Price
		, intB5PriceUOMId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSampleTypeId INT
			,intParentSampleId INT
			,intRelatedSampleId INT
			,strSampleRefNo NVARCHAR(30)
			,intProductTypeId INT
			,intProductValueId INT
			,intSampleStatusId INT
			,intItemId INT
			,intItemContractId INT
			,intContractHeaderId INT
			,intContractDetailId INT
			--,intShipmentBLContainerId INT
			--,intShipmentBLContainerContractId INT
			--,intShipmentId INT
			--,intShipmentContractQtyId INT
			,intLoadContainerId INT
			,intLoadDetailContainerLinkId INT
			,intLoadId INT
			,intLoadDetailId INT
			,intCountryID INT
			,ysnIsContractCompleted BIT
			,intStorageLocationId INT
			,ysnAdjustInventoryQtyBySampleQty BIT
			,intEntityId INT
			,intBookId INT
			,intSubBookId INT
			,strShipmentNumber NVARCHAR(30)
			,strLotNumber NVARCHAR(50)
			,strSampleNote NVARCHAR(512)
			,dtmSampleReceivedDate DATETIME
			--,dtmTestedOn DATETIME
			--,intTestedById INT
			,dblSampleQty NUMERIC(18, 6)
			,intSampleUOMId INT
			,dblRepresentingQty NUMERIC(18, 6)
			,intRepresentingUOMId INT
			,strRefNo NVARCHAR(100)
			,dtmTestingStartDate DATETIME
			,dtmTestingEndDate DATETIME
			,dtmSamplingEndDate DATETIME
			,dtmRequestedDate DATETIME
			,dtmSampleSentDate DATETIME
			,strSamplingMethod NVARCHAR(50)
			,strContainerNumber NVARCHAR(100)
			,strMarks NVARCHAR(100)
			,intCompanyLocationSubLocationId INT
			,strCountry NVARCHAR(100)
			,strComment NVARCHAR(MAX)
			,intItemBundleId INT
			,intLocationId INT
			,strChildLotNumber NVARCHAR(50)
			,strCourier NVARCHAR(50)
			,strCourierRef NVARCHAR(50)
			,intForwardingAgentId INT
			,strForwardingAgentRef NVARCHAR(50)
			,strSentBy NVARCHAR(50)
			,intSentById INT
			,ysnImpactPricing BIT
			,intSamplingCriteriaId INT
			,strSendSampleTo NVARCHAR(50)
			,strRepresentLotNumber NVARCHAR(50)
			, intSaleYearId INT
  		    , strSaleNumber NVARCHAR(50)
		    , strChopNumber NVARCHAR(50)
		    , dtmSaleDate DATETIME  
		    , intCatalogueTypeId INT
		    , dtmPromptDate DATETIME  
		    , intBrokerId INT
		    , intGradeId INT
		    , intLeafCategoryId INT
		    , intManufacturingLeafTypeId INT
		    , intSeasonId INT
		    , intGardenMarkId INT
		    , dtmManufacturingDate DATETIME  
		    , intTotalNumberOfPackageBreakups INT
		    , intNetWtPerPackagesUOMId INT
		    , intNoOfPackages INT
		    , intNetWtSecondPackageBreakUOMId INT
		    , intNoOfPackagesSecondPackageBreak INT
		    , intNetWtThirdPackageBreakUOMId INT
		    , intNoOfPackagesThirdPackageBreak INT
		    , intProductLineId INT
		    , ysnOrganic BIT
		    , dblSupplierValuationPrice NUMERIC(18, 6)
		    , intProducerId INT
		    , intPurchaseGroupId INT
		    , strERPRefNo NVARCHAR(50) 
		    , dblGrossWeight NUMERIC(18, 6)
		    , dblTareWeight NUMERIC(18, 6)
		    , dblNetWeight NUMERIC(18, 6)
		    , strBatchNo NVARCHAR(50) 
		    , str3PLStatus NVARCHAR(50) 
		    , strAdditionalSupplierReference NVARCHAR(50) 
		    , intAWBSampleReceived INT
		    , strAWBSampleReference NVARCHAR(50) 
		    , dblBasePrice NUMERIC(18, 6)
		    , ysnBoughtAsReserve BIT
		    , intCurrencyId INT
		    , ysnEuropeanCompliantFlag BIT
		    , intEvaluatorsCodeAtTBOId INT
		    , intFromLocationCodeId INT
		    , strSampleBoxNumber NVARCHAR(50) 
		    , intBrandId INT
		    , intValuationGroupId INT
		    , strMusterLot NVARCHAR(50) 
		    , strMissingLot NVARCHAR(50) 
		    , intMarketZoneId INT
		    , intDestinationStorageLocationId INT
		    , strComments2 NVARCHAR(MAX) 
		    , strComments3 NVARCHAR(MAX)   
			, strBuyingOrderNo NVARCHAR(50) 
			, intTINClearanceId INT
			, intBuyer1Id INT
			, dblB1QtyBought NUMERIC(18, 6)
			, intB1QtyUOMId INT
			, dblB1Price NUMERIC(18, 6)
			, intB1PriceUOMId INT
			, intBuyer2Id INT
			, dblB2QtyBought NUMERIC(18, 6)
			, intB2QtyUOMId INT
			, dblB2Price NUMERIC(18, 6)
			, intB2PriceUOMId INT
			, intBuyer3Id INT
			, dblB3QtyBought NUMERIC(18, 6)
			, intB3QtyUOMId INT
			, dblB3Price NUMERIC(18, 6)
			, intB3PriceUOMId INT
			, intBuyer4Id INT
			, dblB4QtyBought NUMERIC(18, 6)
			, intB4QtyUOMId INT
			, dblB4Price NUMERIC(18, 6)
			, intB4PriceUOMId INT
			, intBuyer5Id INT
			, dblB5QtyBought NUMERIC(18, 6)
			, intB5QtyUOMId INT
			, dblB5Price NUMERIC(18, 6)
			, intB5PriceUOMId INT
			,intCreatedUserId INT
			,dtmCreated DATETIME
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	SELECT @intSampleId = SCOPE_IDENTITY()

	INSERT INTO dbo.tblQMSampleDetail (
		intConcurrencyId
		,intSampleId
		,intAttributeId
		,strAttributeValue
		,ysnIsMandatory
		,intListItemId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,@intSampleId
		,intAttributeId
		,strAttributeValue
		,ysnIsMandatory
		,intListItemId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM OPENXML(@idoc, 'root/SampleDetail', 2) WITH (
			intAttributeId INT
			,strAttributeValue NVARCHAR(50)
			,ysnIsMandatory BIT
			,intListItemId INT
			,intCreatedUserId INT
			,dtmCreated DATETIME
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	INSERT INTO dbo.tblQMSampleContractSequence (
		intConcurrencyId
		,intSampleId
		,intContractDetailId
		,dblQuantity
		,intUnitMeasureId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,@intSampleId
		,intContractDetailId
		,dblQuantity
		,intUnitMeasureId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM OPENXML(@idoc, 'root/SampleContractSequence', 2) WITH (
			intContractDetailId INT
			,dblQuantity NUMERIC(18, 6)
			,intUnitMeasureId INT
			,intCreatedUserId INT
			,dtmCreated DATETIME
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	INSERT INTO dbo.tblQMTestResult (
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
		,intPropertyItemId
		,dtmPropertyValueCreated
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,@intSampleId
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
		,intPropertyItemId
		,CASE 
			WHEN strPropertyValue <> ''
				THEN GETDATE()
			ELSE NULL
			END AS dtmPropertyValueCreated
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM OPENXML(@idoc, 'root/TestResult', 2) WITH (
			intProductId INT
			,intProductTypeId INT
			,intProductValueId INT
			,intTestId INT
			,intPropertyId INT
			,strPanelList NVARCHAR(50)
			,strPropertyValue NVARCHAR(MAX)
			,dtmCreateDate DATETIME
			,strResult NVARCHAR(20)
			,ysnFinal BIT
			,strComment NVARCHAR(MAX)
			,intSequenceNo INT
			,dtmValidFrom DATETIME
			,dtmValidTo DATETIME
			,strPropertyRangeText NVARCHAR(MAX)
			,dblMinValue NUMERIC(18, 6)
			,dblPinpointValue NUMERIC(18, 6)
			,dblMaxValue NUMERIC(18, 6)
			,dblLowValue NUMERIC(18, 6)
			,dblHighValue NUMERIC(18, 6)
			,intUnitMeasureId INT
			,strFormulaParser NVARCHAR(MAX)
			,dblCrdrPrice NUMERIC(18, 6)
			,dblCrdrQty NUMERIC(18, 6)
			,intProductPropertyValidityPeriodId INT
			,intPropertyValidityPeriodId INT
			,intControlPointId INT
			,intParentPropertyId INT
			,intRepNo INT
			,strFormula NVARCHAR(MAX)
			,intListItemId INT
			,strIsMandatory NVARCHAR(20)
			,intPropertyItemId INT
			,intCreatedUserId INT
			,dtmCreated DATETIME
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	SELECT @strSampleNumber AS strSampleNumber

	IF EXISTS (
			SELECT 1
			FROM tblQMSampleType
			WHERE intSampleTypeId = @intSampleTypeId
				AND ysnAdjustInventoryQtyBySampleQty = 1
			)
		AND ISNULL(@dblSampleQty, 0) > 0
		AND @ysnEnableParentLot = 0
		AND ISNULL(@strLotNumber, '') <> '' -- Lot
	BEGIN
		IF @intStorageLocationId IS NULL
		BEGIN
			RAISERROR (
					'Storage Unit cannot be empty. '
					,16
					,1
					)
		END

		SELECT @intLotId = intLotId
			,@dblQty = dblQty
			,@intItemUOMId = intItemUOMId
		FROM tblICLot
		WHERE strLotNumber = @strLotNumber
			AND intStorageLocationId = @intStorageLocationId

		SELECT @intSampleItemUOMId = intItemUOMId
		FROM tblICItemUOM
		WHERE intItemId = @intItemId
			AND intUnitMeasureId = @intSampleUOMId

		IF @intSampleItemUOMId IS NULL
		BEGIN
			RAISERROR (
					'Sample quantity UOM is not configured for the selected item. '
					,16
					,1
					)
		END

		SELECT @dblSampleQty = dbo.fnMFConvertQuantityToTargetItemUOM(@intSampleItemUOMId, @intItemUOMId, @dblSampleQty)

		IF @dblSampleQty > @dblQty
		BEGIN
			RAISERROR (
					'Sample quantity cannot be greater than lot / pallet quantity. '
					,16
					,1
					)
		END

		SELECT @dblQty = @dblQty - @dblSampleQty

		SELECT @strReasonCode = 'Sample Quantity - ' + @strSampleNumber

		EXEC [uspMFLotAdjustQty] @intLotId = @intLotId
			,@dblNewLotQty = @dblQty
			,@intAdjustItemUOMId = @intItemUOMId
			,@intUserId = @intCreatedUserId
			,@strReasonCode = @strReasonCode
			,@blnValidateLotReservation = 0
			,@strNotes = NULL
			,@dtmDate = @dtmBusinessDate
			,@ysnBulkChange = 0
	END

	EXEC uspQMInterCompanyPreStageSample @intSampleId

	EXEC uspQMPreStageSample @intSampleId
		,'Added'
		,@strSampleNumber
		,@intOrgSampleTypeId
		,@intOrgItemId
		,@intOrgCountryID
		,@intOrgCompanyLocationSubLocationId

	EXEC sp_xml_removedocument @idoc


	-- UPDATES THE RELATED SAMPLE ID
	IF ISNULL(@intRelatedSampleId, 0) <> 0
		UPDATE tblQMSample SET intRelatedSampleId = @intSampleId WHERE intSampleId = @intRelatedSampleId

	DECLARE @strRowState NVARCHAR(50)
	SELECT @strRowState = CASE WHEN intConcurrencyId > 1 THEN 'Modified' ELSE 'Added' END
	FROM tblQMSample
	WHERE intSampleId = @intSampleId

	EXEC uspIPProcessPriceToFeed
		@intCreatedUserId
		,@intSampleId
		,'Sample'
		,@strRowState

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH