--EXEC uspQMSampleContractCopy 177,5,500,1
CREATE PROCEDURE uspQMSampleContractCopy @intOldSampleId INT
	,@intNewContractDetailId INT
	,@dblNewRepresentingQuantity NUMERIC(18, 6)
	,@intNewRepresentingUOMId INT
	,@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strSampleNumber NVARCHAR(30)
		,@intSampleId INT
		,@intLocationId INT

	SELECT @intOldSampleId = ISNULL(intSampleId, 0)
		,@intLocationId = intLocationId
	FROM tblQMSample
	WHERE intSampleId = @intOldSampleId

	IF (@intOldSampleId <= 0)
		RETURN;

	SELECT @intNewContractDetailId = ISNULL(intContractDetailId, 0)
	FROM tblCTContractDetail
	WHERE intContractDetailId = @intNewContractDetailId

	IF (@intNewContractDetailId <= 0)
		RETURN;

	IF NOT EXISTS (
			SELECT 1
			FROM tblCTContractDetail CD
			JOIN tblICItemUOM IUOM ON IUOM.intItemId = CD.intItemId
			WHERE CD.intContractDetailId = @intNewContractDetailId
				AND IUOM.intUnitMeasureId = @intNewRepresentingUOMId
			)
	BEGIN
		DECLARE @strItemNo NVARCHAR(50)
		DECLARE @strUnitMeasure NVARCHAR(50)

		SELECT @strItemNo = I.strItemNo
		FROM tblCTContractDetail CD
		JOIN tblICItem I ON I.intItemId = CD.intItemId
		WHERE CD.intContractDetailId = @intNewContractDetailId

		SELECT @strUnitMeasure = strUnitMeasure
		FROM tblICUnitMeasure
		WHERE intUnitMeasureId = @intNewRepresentingUOMId

		SET @ErrMsg = '''' + @strUnitMeasure + ''' unit of measure is not configured for the item ''' + @strItemNo + '''.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	-- New Sample
	EXEC uspMFGeneratePatternId @intCategoryId = NULL
		,@intItemId = NULL
		,@intManufacturingId = NULL
		,@intSubLocationId = NULL
		,@intLocationId = @intLocationId
		,@intOrderTypeId = NULL
		,@intBlendRequirementId = NULL
		,@intPatternCode = 62
		,@ysnProposed = 0
		,@strPatternString = @strSampleNumber OUTPUT

	IF EXISTS (
			SELECT 1
			FROM tblQMSample
			WHERE strSampleNumber = @strSampleNumber
			)
	BEGIN
		RAISERROR (
				'Sample number already exists. '
				,16
				,1
				)
	END

	INSERT INTO tblQMSample (
		intConcurrencyId
		,intSampleTypeId
		,strSampleNumber
		,intProductTypeId
		,intProductValueId
		,intSampleStatusId
		,intItemId
		,intItemContractId
		,intContractHeaderId
		,intContractDetailId
		,intShipmentBLContainerId
		,intShipmentBLContainerContractId
		,intShipmentId
		,intShipmentContractQtyId
		,intCountryID
		,ysnIsContractCompleted
		,intLotStatusId
		,intEntityId
		,intShipperEntityId
		,strShipmentNumber
		,strLotNumber
		,strSampleNote
		,dtmSampleReceivedDate
		,dtmTestedOn
		,intTestedById
		,dblSampleQty
		,intSampleUOMId
		,dblRepresentingQty
		,intRepresentingUOMId
		,strRefNo
		,dtmTestingStartDate
		,dtmTestingEndDate
		,dtmSamplingEndDate
		,strSamplingMethod
		,strContainerNumber
		,strMarks
		,intCompanyLocationSubLocationId
		,strCountry
		,intItemBundleId
		,intLoadContainerId
		,intLoadDetailContainerLinkId
		,intLoadId
		,intLoadDetailId
		,dtmBusinessDate
		,intShiftId
		,intLocationId
		,intInventoryReceiptId
		,intWorkOrderId
		,strComment
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT intConcurrencyId
		,intSampleTypeId
		,@strSampleNumber
		,intProductTypeId
		,@intNewContractDetailId
		,intSampleStatusId
		,intItemId
		,intItemContractId
		,intContractHeaderId
		,@intNewContractDetailId
		,intShipmentBLContainerId
		,intShipmentBLContainerContractId
		,intShipmentId
		,intShipmentContractQtyId
		,intCountryID
		,ysnIsContractCompleted
		,intLotStatusId
		,intEntityId
		,intShipperEntityId
		,strShipmentNumber
		,strLotNumber
		,strSampleNote
		,dtmSampleReceivedDate
		,dtmTestedOn
		,intTestedById
		,dblSampleQty
		,intSampleUOMId
		,@dblNewRepresentingQuantity
		,@intNewRepresentingUOMId
		,strRefNo
		,dtmTestingStartDate
		,dtmTestingEndDate
		,dtmSamplingEndDate
		,strSamplingMethod
		,strContainerNumber
		,strMarks
		,intCompanyLocationSubLocationId
		,strCountry
		,intItemBundleId
		,intLoadContainerId
		,intLoadDetailContainerLinkId
		,intLoadId
		,intLoadDetailId
		,dtmBusinessDate
		,intShiftId
		,intLocationId
		,intInventoryReceiptId
		,intWorkOrderId
		,strComment
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM tblQMSample
	WHERE intSampleId = @intOldSampleId

	SELECT @intSampleId = SCOPE_IDENTITY()

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
	SELECT intConcurrencyId
		,@intSampleId
		,intAttributeId
		,strAttributeValue
		,intListItemId
		,ysnIsMandatory
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM tblQMSampleDetail
	WHERE intSampleId = @intOldSampleId

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
	SELECT intConcurrencyId
		,@intSampleId
		,intProductId
		,intProductTypeId
		,@intNewContractDetailId
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
		,dtmPropertyValueCreated
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM tblQMTestResult
	WHERE intSampleId = @intOldSampleId

	IF (@intSampleId > 0)
	BEGIN
		DECLARE @StrDescription AS NVARCHAR(MAX) = 'Contract Slice to Quality'

		EXEC uspSMAuditLog @keyValue = @intSampleId
			,@screenName = 'Quality.view.QualitySample'
			,@entityId = @intUserId
			,@actionType = 'Created'
			,@actionIcon = 'small-new-plus'
			,@changeDescription = @StrDescription
			,@fromValue = ''
			,@toValue = @strSampleNumber
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
