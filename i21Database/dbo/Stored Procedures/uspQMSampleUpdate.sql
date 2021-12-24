CREATE PROCEDURE uspQMSampleUpdate @strXml NVARCHAR(Max)
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

	DECLARE @intSampleId INT
	DECLARE @strMarks NVARCHAR(100)
	DECLARE @intPreviousSampleStatusId INT
	DECLARE @intShipperEntityId INT
	DECLARE @ysnEnableParentLot BIT
			,@intSampleTypeId INT
		,@dblSampleQty NUMERIC(18, 6)
		,@intLotId INT
		,@dblQty NUMERIC(18, 6)
		,@intItemUOMId INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intSampleUOMId INT
		,@intItemId INT
		,@intSampleItemUOMId INT
		,@strReasonCode NVARCHAR(50)
		,@strSampleNumber NVARCHAR(50)
		,@dtmBusinessDate DATETIME
		,@ysnAdjustInventoryQtyBySampleQty Bit
		,@intLastModifiedUserId int
		,@dblOldSampleQty NUMERIC(18, 6)
		,@intConcurrencyId INT
		,@intCurrentConcurrencyId INT
	DECLARE @intRepresentingUOMId INT
		,@dblRepresentingQty NUMERIC(18, 6)
		,@dblConvertedSampleQty NUMERIC(18, 6)
		,@intContractHeaderId INT
		,@ysnMultipleContractSeq BIT
	DECLARE @intOrgSampleTypeId INT
		,@intOrgItemId INT
		,@intOrgCountryID INT
		,@intOrgCompanyLocationSubLocationId INT

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblQMCompanyPreference

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
	
	SELECT @intSampleId = intSampleId
		,@strMarks = strMarks
		,@intPreviousSampleStatusId = intSampleStatusId
		,@dblSampleQty = dblSampleQty
		,@intSampleUOMId = intSampleUOMId
		,@dblRepresentingQty = dblRepresentingQty
		,@intRepresentingUOMId = intRepresentingUOMId
		,@intItemId = intItemId
		,@intSampleTypeId = intSampleTypeId
		,@intContractHeaderId = intContractHeaderId
		,@intConcurrencyId = intConcurrencyId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSampleId INT
			,strMarks NVARCHAR(100)
			,intSampleStatusId INT
			,dblSampleQty NUMERIC(18, 6)
			,intSampleUOMId INT
			,dblRepresentingQty NUMERIC(18, 6)
			,intRepresentingUOMId INT
			,intItemId INT
			,intSampleTypeId INT
			,intContractHeaderId INT
			,intConcurrencyId INT
			)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblQMSample
			WHERE intSampleId = @intSampleId
			)
	BEGIN
		RAISERROR (
				'Sample is already deleted by another user. '
				,16
				,1
				)
	END

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

	SELECT @ysnMultipleContractSeq = ysnMultipleContractSeq
	FROM tblQMSampleType
	WHERE intSampleTypeId = @intSampleTypeId

	-- Contract Sequences check for Assign Contract to Multiple Sequences scenario
	IF @ysnMultipleContractSeq = 1
		AND ISNULL(@intContractHeaderId, 0) > 0
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM OPENXML(@idoc, 'root/SampleContractSequence', 2) WITH (
						intContractDetailId INT
						,strRowState NVARCHAR(50)
						) x
				JOIN dbo.tblCTContractDetail CD ON CD.intContractDetailId = x.intContractDetailId
					AND x.strRowState <> 'DELETE'
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

	SELECT @dblOldSampleQty = dblSampleQty
		,@intCurrentConcurrencyId = intConcurrencyId
	FROM tblQMSample
	WHERE intSampleId = @intSampleId

	IF ISNULL(@intConcurrencyId, 0) < ISNULL(@intCurrentConcurrencyId, 0)
	BEGIN
		RAISERROR (
				'Sample is already modified by other user. Please refresh.'
				,16
				,1
				)
	END

	-- If it is not Inter Company then update SampleRefNo
	IF NOT EXISTS (
			SELECT TOP 1 1
			FROM dbo.tblIPMultiCompany
			)
	BEGIN
		UPDATE tblQMSample
		SET strSampleRefNo = x.strSampleRefNo
		FROM OPENXML(@idoc, 'root', 2) WITH (
				strSampleRefNo NVARCHAR(30)
				,strRowState NVARCHAR(50)
				) x
		WHERE dbo.tblQMSample.intSampleId = @intSampleId
			AND x.strRowState = 'MODIFIED'
	END

	-- Sample Header Update
	UPDATE tblQMSample
	SET intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
		,intSampleTypeId = x.intSampleTypeId
		,intProductTypeId = x.intProductTypeId
		,intProductValueId = x.intProductValueId
		,intSampleStatusId = x.intSampleStatusId
		,intItemId = x.intItemId
		,intItemContractId = x.intItemContractId
		,intContractHeaderId = x.intContractHeaderId
		,intContractDetailId = x.intContractDetailId
		--,intShipmentBLContainerContractId = x.intShipmentBLContainerContractId
		--,intShipmentId = x.intShipmentId
		--,intShipmentContractQtyId = x.intShipmentContractQtyId
		--,intShipmentBLContainerId = x.intShipmentBLContainerId
		,intLoadContainerId = x.intLoadContainerId
		,intLoadDetailContainerLinkId = x.intLoadDetailContainerLinkId
		,intLoadId = x.intLoadId
		,intLoadDetailId = x.intLoadDetailId
		,intCountryID = x.intCountryID
		,ysnIsContractCompleted = x.ysnIsContractCompleted
		,intLotStatusId = x.intLotStatusId
		,intStorageLocationId = x.intStorageLocationId
		,ysnAdjustInventoryQtyBySampleQty = x.ysnAdjustInventoryQtyBySampleQty
		,intEntityId = x.intEntityId
		,intBookId = x.intBookId
		,intSubBookId = x.intSubBookId
		,intShipperEntityId = @intShipperEntityId
		,strShipmentNumber = x.strShipmentNumber
		,strLotNumber = x.strLotNumber
		,strSampleNote = x.strSampleNote
		,dtmSampleReceivedDate = x.dtmSampleReceivedDate
		--,dtmTestedOn = x.dtmTestedOn
		--,intTestedById = x.intTestedById
		,dblSampleQty = x.dblSampleQty
		,intSampleUOMId = x.intSampleUOMId
		,dblRepresentingQty = x.dblRepresentingQty
		,intRepresentingUOMId = x.intRepresentingUOMId
		,strRefNo = x.strRefNo
		,dtmTestingStartDate = x.dtmTestingStartDate
		,dtmTestingEndDate = x.dtmTestingEndDate
		,dtmSamplingEndDate = x.dtmSamplingEndDate
		,strSamplingMethod = x.strSamplingMethod
		,strContainerNumber = x.strContainerNumber
		,strMarks = x.strMarks
		,intCompanyLocationSubLocationId = x.intCompanyLocationSubLocationId
		,strCountry = x.strCountry
		,strComment = x.strComment
		,intItemBundleId = x.intItemBundleId
		,intWorkOrderId = x.intWorkOrderId
		,intInventoryReceiptId = x.intInventoryReceiptId
		,intInventoryShipmentId = x.intInventoryShipmentId
		,strChildLotNumber = x.strChildLotNumber
		,strCourier = x.strCourier
		,strCourierRef = x.strCourierRef
		,intForwardingAgentId = x.intForwardingAgentId
		,strForwardingAgentRef = x.strForwardingAgentRef
		,strSentBy = x.strSentBy
		,intSentById = x.intSentById
		,intLastModifiedUserId = x.intLastModifiedUserId
		,dtmLastModified = x.dtmLastModified
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSampleTypeId INT
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
			,intLotStatusId INT
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
			,strSamplingMethod NVARCHAR(50)
			,strContainerNumber NVARCHAR(100)
			,strMarks NVARCHAR(100)
			,intCompanyLocationSubLocationId INT
			,strCountry NVARCHAR(100)
			,strComment NVARCHAR(MAX)
			,intItemBundleId INT
			,intWorkOrderId INT
			,intInventoryReceiptId INT
			,intInventoryShipmentId INT
			,strChildLotNumber NVARCHAR(50)
			,strCourier NVARCHAR(50)
			,strCourierRef NVARCHAR(50)
			,intForwardingAgentId INT
			,strForwardingAgentRef NVARCHAR(50)
			,strSentBy NVARCHAR(50)
			,intSentById INT
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			,strRowState NVARCHAR(50)
			) x
	WHERE dbo.tblQMSample.intSampleId = @intSampleId
		AND x.strRowState = 'MODIFIED'

	-- If sample status is not in Approved and Rejected, then set the previous sample status
	IF @intPreviousSampleStatusId <> 3 AND @intPreviousSampleStatusId <> 4
	BEGIN
		UPDATE tblQMSample
		SET intPreviousSampleStatusId = @intPreviousSampleStatusId
		WHERE intSampleId = @intSampleId

		UPDATE tblQMSample
		SET dtmTestedOn = NULL
			,intTestedById = NULL
		WHERE intSampleId = @intSampleId
	END

	-- Sample Detail Create, Update, Delete
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
			,strRowState NVARCHAR(50)
			) x
	WHERE x.strRowState = 'ADDED'

	UPDATE dbo.tblQMSampleDetail
	SET strAttributeValue = x.strAttributeValue
		,intListItemId = x.intListItemId
		,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
		,intLastModifiedUserId = x.intLastModifiedUserId
		,dtmLastModified = x.dtmLastModified
	FROM OPENXML(@idoc, 'root/SampleDetail', 2) WITH (
			intSampleDetailId INT
			,strAttributeValue NVARCHAR(50)
			,intListItemId INT
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intSampleDetailId = dbo.tblQMSampleDetail.intSampleDetailId
		AND x.strRowState = 'MODIFIED'

	DELETE
	FROM dbo.tblQMSampleDetail
	WHERE intSampleId = @intSampleId
		AND EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/SampleDetail', 2) WITH (
					intSampleDetailId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intSampleDetailId = dbo.tblQMSampleDetail.intSampleDetailId
				AND x.strRowState = 'DELETE'
			)

	-- Sample Contract Sequences Create, Update, Delete
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
			,strRowState NVARCHAR(50)
			) x
	WHERE x.strRowState = 'ADDED'

	UPDATE dbo.tblQMSampleContractSequence
	SET intContractDetailId = x.intContractDetailId
		,dblQuantity = x.dblQuantity
		,intUnitMeasureId = x.intUnitMeasureId
		,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
		,intLastModifiedUserId = x.intLastModifiedUserId
		,dtmLastModified = x.dtmLastModified
	FROM OPENXML(@idoc, 'root/SampleContractSequence', 2) WITH (
			intSampleContractSequenceId INT
			,intContractDetailId INT
			,dblQuantity NUMERIC(18, 6)
			,intUnitMeasureId INT
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intSampleContractSequenceId = dbo.tblQMSampleContractSequence.intSampleContractSequenceId
		AND x.strRowState = 'MODIFIED'

	DELETE
	FROM dbo.tblQMSampleContractSequence
	WHERE intSampleId = @intSampleId
		AND EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/SampleContractSequence', 2) WITH (
					intSampleContractSequenceId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intSampleContractSequenceId = dbo.tblQMSampleContractSequence.intSampleContractSequenceId
				AND x.strRowState = 'DELETE'
			)

	-- Test Result Create, Update, Delete
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
			,strRowState NVARCHAR(50)
			) x
	WHERE x.strRowState = 'ADDED'

	UPDATE dbo.tblQMTestResult
	SET intProductTypeId = x.intProductTypeId
		,intProductValueId = x.intProductValueId
		,strPropertyValue = x.strPropertyValue
		,strResult = x.strResult
		,strComment = x.strComment
		,intSequenceNo = x.intSequenceNo
		,intControlPointId = x.intControlPointId
		,intListItemId = x.intListItemId
		,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
		,intLastModifiedUserId = x.intLastModifiedUserId
		,dtmLastModified = x.dtmLastModified
		,dtmPropertyValueCreated = (
			CASE 
				WHEN (
						dtmPropertyValueCreated IS NULL
						AND x.strPropertyValue <> ''
						)
					THEN GETDATE()
				ELSE dtmPropertyValueCreated
				END
			)
	FROM OPENXML(@idoc, 'root/TestResult', 2) WITH (
			intTestResultId INT
			,intProductTypeId INT
			,intProductValueId INT
			,strPropertyValue NVARCHAR(MAX)
			,strResult NVARCHAR(20)
			,strComment NVARCHAR(MAX)
			,intSequenceNo INT
			,intControlPointId INT
			,intListItemId INT
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			,strRowState NVARCHAR(50)
			) x
	WHERE x.intTestResultId = dbo.tblQMTestResult.intTestResultId
		AND x.strRowState = 'MODIFIED'

	DELETE
	FROM dbo.tblQMTestResult
	WHERE intSampleId = @intSampleId
		AND EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/TestResult', 2) WITH (
					intTestResultId INT
					,strRowState NVARCHAR(50)
					) x
			WHERE x.intTestResultId = dbo.tblQMTestResult.intTestResultId
				AND x.strRowState = 'DELETE'
			)

	EXEC sp_xml_removedocument @idoc

	SELECT @intSampleTypeId = intSampleTypeId
		,@dblSampleQty = dblSampleQty
		,@strLotNumber = strLotNumber
		,@intStorageLocationId = intStorageLocationId
		,@intItemId = intItemId
		,@intSampleUOMId = intSampleUOMId
		,@strSampleNumber = strSampleNumber
		,@ysnAdjustInventoryQtyBySampleQty=IsNULL(ysnAdjustInventoryQtyBySampleQty,0)
		,@intLastModifiedUserId=intLastModifiedUserId
	FROM tblQMSample
	WHERE intSampleId = @intSampleId


	IF @ysnAdjustInventoryQtyBySampleQty=1
		AND ISNULL(@dblSampleQty, 0) > 0
		AND @ysnEnableParentLot = 0 AND ISNULL(@strLotNumber, '') <> '' -- Lot
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

		SELECT @dblQty = @dblQty - (@dblSampleQty-@dblOldSampleQty)

		SELECT @strReasonCode = 'Sample Quantity - ' + @strSampleNumber

		EXEC [uspMFLotAdjustQty] @intLotId = @intLotId
			,@dblNewLotQty = @dblQty
			,@intAdjustItemUOMId = @intItemUOMId
			,@intUserId = @intLastModifiedUserId
			,@strReasonCode = @strReasonCode
			,@blnValidateLotReservation = 0
			,@strNotes = NULL
			,@dtmDate = @dtmBusinessDate
			,@ysnBulkChange = 0
	END

	EXEC uspQMInterCompanyPreStageSample @intSampleId

	EXEC uspQMPreStageSample @intSampleId
		,'Modified'
		,@strSampleNumber
		,@intOrgSampleTypeId
		,@intOrgItemId
		,@intOrgCountryID
		,@intOrgCompanyLocationSubLocationId

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
