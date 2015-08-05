CREATE PROCEDURE [dbo].[uspQMSampleUpdate]
	@strXml NVARCHAR(Max)
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

	SELECT @intSampleId = intSampleId
	FROM OPENXML(@idoc, 'root', 2) WITH (intSampleId INT)

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

	BEGIN TRAN

	-- Sample Header Update
	UPDATE dbo.tblQMSample
	SET intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
		,intSampleTypeId = x.intSampleTypeId
		,intProductTypeId = x.intProductTypeId
		,intProductValueId = x.intProductValueId
		,intSampleStatusId = x.intSampleStatusId
		,intItemId = x.intItemId
		,intItemContractId = x.intItemContractId
		,intContractHeaderId = x.intContractHeaderId
		,intContractDetailId = x.intContractDetailId
		,intShipmentBLContainerContractId = x.intShipmentBLContainerContractId
		,intShipmentId = x.intShipmentId
		,intShipmentContractQtyId = x.intShipmentContractQtyId
		,intShipmentBLContainerId = x.intShipmentBLContainerId
		,intCountryID = x.intCountryID
		,ysnIsContractCompleted = x.ysnIsContractCompleted
		,intLotStatusId = x.intLotStatusId
		,intEntityId = x.intEntityId
		,strShipmentNumber = x.strShipmentNumber
		,strLotNumber = x.strLotNumber
		,strSampleNote = x.strSampleNote
		,dtmSampleReceivedDate = x.dtmSampleReceivedDate
		,dtmTestedOn = x.dtmTestedOn
		,intTestedById = x.intTestedById
		,dblSampleQty = x.dblSampleQty
		,intSampleUOMId = x.intSampleUOMId
		,dblRepresentingQty = x.dblRepresentingQty
		,intRepresentingUOMId = x.intRepresentingUOMId
		,strRefNo = x.strRefNo
		,dtmTestingStartDate = x.dtmTestingStartDate
		,dtmTestingEndDate = x.dtmTestingEndDate
		,dtmSamplingEndDate = x.dtmSamplingEndDate
		,strSamplingMethod = x.strSamplingMethod
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
			,intShipmentBLContainerId INT
			,intShipmentBLContainerContractId INT
			,intShipmentId INT
			,intShipmentContractQtyId INT
			,intCountryID INT
			,ysnIsContractCompleted BIT
			,intLotStatusId INT
			,intEntityId INT
			,strShipmentNumber NVARCHAR(30)
			,strLotNumber NVARCHAR(30)
			,strSampleNote NVARCHAR(512)
			,dtmSampleReceivedDate DATETIME
			,dtmTestedOn DATETIME
			,intTestedById INT
			,dblSampleQty NUMERIC(18, 6)
			,intSampleUOMId INT
			,dblRepresentingQty NUMERIC(18, 6)
			,intRepresentingUOMId INT
			,strRefNo NVARCHAR(100)
			,dtmTestingStartDate DATETIME
			,dtmTestingEndDate DATETIME
			,dtmSamplingEndDate DATETIME
			,strSamplingMethod NVARCHAR(50)
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			,strRowState NVARCHAR(50)
			) x
	WHERE dbo.tblQMSample.intSampleId = @intSampleId
		AND x.strRowState = 'MODIFIED'

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
		,intListItemId = x.intListItemId
		,intConcurrencyId = Isnull(intConcurrencyId, 0) + 1
		,intLastModifiedUserId = x.intLastModifiedUserId
		,dtmLastModified = x.dtmLastModified
	FROM OPENXML(@idoc, 'root/TestResult', 2) WITH (
			intTestResultId INT
			,intProductTypeId INT
			,intProductValueId INT
			,strPropertyValue NVARCHAR(MAX)
			,strResult NVARCHAR(20)
			,strComment NVARCHAR(MAX)
			,intSequenceNo INT
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
