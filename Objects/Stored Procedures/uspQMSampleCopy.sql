--EXEC uspQMSampleCopy 3195,3566,1,1
CREATE PROCEDURE uspQMSampleCopy
	@intOldLotId INT
	,@intNewLotId INT
	,@intLocationId INT
	,@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @strSampleNumber NVARCHAR(30)
		,@strNewLotNumber NVARCHAR(50)
		,@strOldLotNumber NVARCHAR(50)
	DECLARE @intOldSampleId INT
		,@intSampleId INT
	DECLARE @ysnEnableParentLot BIT

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblQMCompanyPreference

	IF @ysnEnableParentLot = 1
		RETURN;

	SELECT @strOldLotNumber = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intOldLotId

	SELECT @strNewLotNumber = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intNewLotId

	SELECT TOP 1 @intOldSampleId = ISNULL(intSampleId, 0)
	FROM tblQMSample
	WHERE intProductTypeId = 6
		AND strLotNumber = @strOldLotNumber
	ORDER BY intSampleId DESC

	IF (@strOldLotNumber = @strNewLotNumber)
		RETURN;

	IF (@intOldSampleId <= 0)
		RETURN;

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
		,intContractDetailId
		,intLoadContainerId
		,intLoadDetailContainerLinkId
		,intLoadId
		,intLoadDetailId
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
		,dtmBusinessDate
		,intShiftId
		,intLocationId
		,intInventoryReceiptId
		,intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT intConcurrencyId
		,intSampleTypeId
		,@strSampleNumber
		,intProductTypeId
		,@intNewLotId
		,intSampleStatusId
		,intItemId
		,intItemContractId
		,intContractDetailId
		,intLoadContainerId
		,intLoadDetailContainerLinkId
		,intLoadId
		,intLoadDetailId
		,intCountryID
		,ysnIsContractCompleted
		,intLotStatusId
		,intEntityId
		,intShipperEntityId
		,strShipmentNumber
		,@strNewLotNumber
		,CASE 
			WHEN ISNULL(strSampleNote, '') = ''
				THEN 'Auto populated by the system due to Lot Split from ''' + @strOldLotNumber + ''''
			ELSE ISNULL(strSampleNote, '') + ' - Auto populated by the system due to Lot Split from ''' + @strOldLotNumber + ''''
			END
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
		,dtmBusinessDate
		,intShiftId
		,intLocationId
		,intInventoryReceiptId
		,intWorkOrderId
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
		,ysnIsMandatory
		,intListItemId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT intConcurrencyId
		,@intSampleId
		,intAttributeId
		,strAttributeValue
		,ysnIsMandatory
		,intListItemId
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
		,@intNewLotId
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
		DECLARE @StrDescription AS NVARCHAR(MAX) = 'Lot Split to Quality'

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
