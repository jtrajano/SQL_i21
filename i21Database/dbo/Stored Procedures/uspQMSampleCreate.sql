﻿CREATE PROCEDURE uspQMSampleCreate @strXml NVARCHAR(Max)
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

		IF @dblConvertedSampleQty > @dblRepresentingQty
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

	INSERT INTO dbo.tblQMSample (
		intConcurrencyId
		,intSampleTypeId
		,strSampleNumber
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
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,intSampleTypeId
		,@strSampleNumber
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
		,dtmRequestedDate
		,dtmSampleSentDate
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
