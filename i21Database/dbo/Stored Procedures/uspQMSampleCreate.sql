CREATE PROCEDURE [dbo].[uspQMSampleCreate]
	@strXml NVARCHAR(Max)
	,@strSampleNumber NVARCHAR(30) OUTPUT
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
	DECLARE @strLotNumber NVARCHAR(30)

	SELECT @strSampleNumber = strSampleNumber
		,@strLotNumber = strLotNumber
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strSampleNumber NVARCHAR(30)
			,strLotNumber NVARCHAR(30)
			)

	IF (
			@strSampleNumber = ''
			OR @strSampleNumber IS NULL
			)
	BEGIN
		EXEC dbo.uspSMGetStartingNumber 62
			,@strSampleNumber OUTPUT
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

	BEGIN TRAN

	INSERT INTO dbo.tblQMSample (
		intConcurrencyId
		,intSampleTypeId
		,strSampleNumber
		,intProductTypeId
		,intSampleStatusId
		,intItemId
		,intItemContractId
		,intContractHeaderId
		,intContractDetailId
		,intShipmentBLContainerContractId
		,intShipmentId
		,intShipmentContractQtyId
		,intShipmentBLContainerId
		,intCountryID
		,ysnIsContractCompleted
		,intLotStatusId
		,intEntityId
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
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,intSampleTypeId
		,@strSampleNumber
		,intProductTypeId
		,intSampleStatusId
		,intItemId
		,intItemContractId
		,intContractHeaderId
		,intContractDetailId
		,intShipmentBLContainerContractId
		,intShipmentId
		,intShipmentContractQtyId
		,intShipmentBLContainerId
		,intCountryID
		,ysnIsContractCompleted
		,intLotStatusId
		,intEntityId
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
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSampleTypeId INT
			,intProductTypeId INT
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
		,intDocumentFileId
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
		,intDocumentFileId
		,intListItemId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
	FROM OPENXML(@idoc, 'root/SampleDetail', 2) WITH (
			intAttributeId INT
			,strAttributeValue NVARCHAR(50)
			,intDocumentFileId INT
			,intListItemId INT
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
			,intCreatedUserId INT
			,dtmCreated DATETIME
			,intLastModifiedUserId INT
			,dtmLastModified DATETIME
			)

	SELECT @strSampleNumber AS strSampleNumber
	
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
