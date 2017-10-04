﻿CREATE PROCEDURE uspQMSampleImport
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)

	RETURN

	DECLARE @intTransactionCount INT

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	DECLARE @ImportHeader TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intSampleImportId INT
		,dtmSampleReceivedDate DATETIME
		,strSampleNumber NVARCHAR(30)
		,strItemShortName NVARCHAR(50)
		,strSampleTypeName NVARCHAR(50)
		,strVendorName NVARCHAR(100)
		,strContractNumber NVARCHAR(50)
		,strContainerNumber NVARCHAR(100)
		,strMarks NVARCHAR(100)
		,dblSequenceQuantity NUMERIC(18, 6)
		,strSampleStatus NVARCHAR(30)
		,intCreatedUserId INT
		,dtmCreated DATETIME
		)
	DECLARE @intSampleImportId INT
		,@dtmSampleReceivedDate DATETIME
		,@strItemShortName NVARCHAR(50)
		,@strSampleTypeName NVARCHAR(50)
		,@strVendorName NVARCHAR(100)
		,@strContractNumber NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
		,@strMarks NVARCHAR(100)
		,@dblSequenceQuantity NUMERIC(18, 6)
		,@strSampleStatus NVARCHAR(30)
		,@intCreatedUserId INT
		,@dtmCreated DATETIME
	DECLARE @strSampleRefNo NVARCHAR(30)
		,@intContractHeaderId INT
		,@intItemId INT
		,@intCategoryId INT
		,@intSampleTypeId INT
		,@intProductId INT
		,@intContractDetailId INT
		,@intSampleStatusId INT
		,@intEntityId INT
		,@intLocationId INT
		,@strSampleNumber NVARCHAR(30)
		,@intSampleId INT
		,@intShiftId INT
		,@dtmBusinessDate DATETIME
		,@dtmCurrentDate DATETIME = GETDATE()
		,@intShipperEntityId INT
		,@intProductTypeId INT
		,@intProductValueId INT
		,@intValidDate INT

	SELECT @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	INSERT INTO @ImportHeader
	SELECT MIN(intSampleImportId) AS intSampleImportId
		,CONVERT(DATETIME, dtmSampleReceivedDate, 101) dtmSampleReceivedDate
		,strSampleNumber
		,strItemShortName
		,strSampleTypeName
		,strVendorName
		,strContractNumber
		,strContainerNumber
		,strMarks
		,dblSequenceQuantity
		,strSampleStatus
		,MIN(intCreatedUserId) AS intCreatedUserId
		,MIN(dtmCreated) AS dtmCreated
	FROM tblQMSampleImport
	GROUP BY CONVERT(DATETIME, dtmSampleReceivedDate, 101)
		,strSampleNumber
		,strItemShortName
		,strSampleTypeName
		,strVendorName
		,strContractNumber
		,strContainerNumber
		,strMarks
		,dblSequenceQuantity
		,strSampleStatus
	ORDER BY intSampleImportId

	--SELECT *
	--FROM @ImportHeader
	SELECT @intSampleImportId = MIN(intSampleImportId)
	FROM @ImportHeader

	WHILE (ISNULL(@intSampleImportId, 0) > 0)
	BEGIN
		SELECT @dtmSampleReceivedDate = NULL
			,@strItemShortName = NULL
			,@strSampleTypeName = NULL
			,@strVendorName = NULL
			,@strContractNumber = NULL
			,@strContainerNumber = NULL
			,@strMarks = NULL
			,@dblSequenceQuantity = NULL
			,@strSampleStatus = NULL
			,@intCreatedUserId = NULL
			,@dtmCreated = NULL
			,@strSampleRefNo = NULL
			,@intContractHeaderId = NULL
			,@intItemId = NULL
			,@intCategoryId = NULL
			,@intSampleTypeId = NULL
			,@intProductId = NULL
			,@intContractDetailId = NULL
			,@intSampleStatusId = NULL
			,@intEntityId = NULL
			,@intLocationId = NULL
			,@strSampleNumber = NULL
			,@intSampleId = NULL
			,@intShiftId = NULL
			,@dtmBusinessDate = NULL
			,@intShipperEntityId = NULL
			,@intProductTypeId = NULL
			,@intProductValueId = NULL

		SELECT @dtmSampleReceivedDate = dtmSampleReceivedDate
			,@strSampleRefNo = strSampleNumber
			,@strItemShortName = strItemShortName
			,@strSampleTypeName = strSampleTypeName
			,@strVendorName = strVendorName
			,@strContractNumber = strContractNumber
			,@strContainerNumber = strContainerNumber
			,@strMarks = strMarks
			,@dblSequenceQuantity = dblSequenceQuantity
			,@strSampleStatus = strSampleStatus
			,@intCreatedUserId = intCreatedUserId
			,@dtmCreated = dtmCreated
		FROM @ImportHeader
		WHERE intSampleImportId = @intSampleImportId

		SELECT @intItemId = intItemId
			,@intCategoryId = intCategoryId
		FROM tblICItem
		WHERE strShortName = @strItemShortName

		SELECT @intSampleTypeId = intSampleTypeId
		FROM tblQMSampleType
		WHERE strSampleTypeName = @strSampleTypeName

		SELECT @intSampleStatusId = intSampleStatusId
		FROM tblQMSampleStatus
		WHERE strStatus = @strSampleStatus

		SELECT @intContractHeaderId = CH.intContractHeaderId
			,@intEntityId = CH.intEntityId
		FROM tblCTContractHeader CH
		WHERE CH.strContractNumber = @strContractNumber

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

		-- Retrieving Contract Sequence
		IF ISNULL(@intContractHeaderId, 0) > 0
		BEGIN
			DECLARE @intCRowNo INT
				,@intCContractDetailId INT
				,@intCSampleTypeId INT
				,@intCSampleStatusId INT
			DECLARE @ContractDetail TABLE (
				intRowNo INT IDENTITY(1, 1)
				,intContractDetailId INT
				,dblQuantity NUMERIC(18, 6)
				)

			INSERT INTO @ContractDetail
			SELECT intContractDetailId
				,dblQuantity
			FROM tblCTContractDetail
			WHERE intContractHeaderId = @intContractHeaderId
			ORDER BY intContractSeq

			SELECT @intCRowNo = MIN(intRowNo)
			FROM @ContractDetail

			WHILE (ISNULL(@intCRowNo, 0) > 0)
			BEGIN
				SELECT @intCContractDetailId = NULL
					,@intCSampleTypeId = NULL
					,@intCSampleStatusId = NULL

				SELECT @intCContractDetailId = intContractDetailId
				FROM @ContractDetail
				WHERE intRowNo = @intCRowNo

				SELECT TOP 1 @intCSampleTypeId = S.intSampleTypeId
					,@intCSampleStatusId = S.intSampleStatusId
				FROM tblQMSample S
				JOIN tblQMSampleImportSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
				WHERE S.intContractDetailId = @intCContractDetailId
					AND S.intSampleStatusId = 3 -- Approved
				ORDER BY S.intSampleId DESC

				-- Sequence existing sample
				IF ISNULL(@intCSampleTypeId, 0) > 0
				BEGIN
					SELECT @intContractDetailId = NULL
				END
				ELSE
				BEGIN
					SELECT @intContractDetailId = @intCContractDetailId

					BREAK
				END

				SELECT @intCRowNo = MIN(intRowNo)
				FROM @ContractDetail
				WHERE intRowNo > @intCRowNo
			END
		END

		IF ISNULL(@intContractDetailId, 0) = 0
		BEGIN
			RAISERROR (
					'Contract already contains Sample. '
					,16
					,1
					)
		END

		SELECT @intLocationId = intCompanyLocationId
		FROM tblCTContractDetail
		WHERE intContractDetailId = @intContractDetailId

		-- Business Date and Shift Id
		SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

		SELECT @intShiftId = intShiftId
		FROM tblMFShift
		WHERE intLocationId = @intLocationId
			AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
				AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

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

		--New Sample Creation
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

		SELECT @intProductTypeId = 8 -- Need to check.
			,@intProductValueId = @intContractDetailId -- Need to check.

		INSERT INTO tblQMSample (
			intConcurrencyId
			,intSampleTypeId
			,strSampleNumber
			,strSampleRefNo
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
		SELECT 1
			,@intSampleTypeId
			,@strSampleNumber
			,@strSampleRefNo
			,@intProductTypeId
			,@intProductValueId
			,@intSampleStatusId
			,@intItemId -- Need to check. whether we need the validation with Contract Seq item and import excel item
			,NULL
			,@intContractHeaderId
			,@intContractDetailId
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL -- intCountryID -- Need to check to take from contract
			,0
			,NULL
			,@intEntityId
			,@intShipperEntityId
			,NULL
			,NULL
			,NULL
			,@dtmSampleReceivedDate
			,@dtmCurrentDate
			,@intCreatedUserId
			,1 -- dblSampleQty -- Need to check
			,NULL --intSampleUOMId -- Need to check
			,@dblSequenceQuantity -- dblRepresentingQty -- Need to check
			,NULL --intRepresentingUOMId -- Need to check to take from seq uom
			,NULL
			,@dtmSampleReceivedDate
			,@dtmSampleReceivedDate
			,@dtmSampleReceivedDate
			,NULL
			,@strContainerNumber
			,@strMarks
			,NULL
			,NULL -- strCountry -- If intCountryID fills, fill this value -- Need to check
			,NULL
			,NULL -- intLoadContainerId -- Need to check
			,NULL -- intLoadDetailContainerLinkId -- Need to check
			,NULL -- intLoadId -- Need to check
			,NULL -- intLoadDetailId -- Need to check
			,@dtmBusinessDate
			,@intShiftId
			,@intLocationId
			,NULL
			,NULL
			,NULL
			,@intCreatedUserId
			,@dtmCurrentDate
			,@intCreatedUserId
			,@dtmCurrentDate

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
		SELECT 1
			,@intSampleId
			,A.intAttributeId
			,ISNULL(A.strAttributeValue, '') AS strAttributeValue
			,A.intListItemId
			,ST.ysnIsMandatory
			,@intCreatedUserId
			,@dtmCurrentDate
			,@intCreatedUserId
			,@dtmCurrentDate
		FROM tblQMSampleTypeDetail ST
		JOIN tblQMAttribute A ON A.intAttributeId = ST.intAttributeId
		WHERE ST.intSampleTypeId = @intSampleTypeId

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
		SELECT DISTINCT 1
			,@intSampleId
			,@intProductId
			,@intProductTypeId
			,@intProductValueId
			,PP.intTestId
			,PP.intPropertyId
			,''
			,''
			,@dtmCurrentDate
			,''
			,0
			,''
			,PP.intSequenceNo
			,PPV.dtmValidFrom
			,PPV.dtmValidTo
			,PPV.strPropertyRangeText
			,PPV.dblMinValue
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
			,@intCreatedUserId
			,@dtmCurrentDate
			,@intCreatedUserId
			,@dtmCurrentDate
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

		-- Update Properties Value, Comment, Result for the available properties
		UPDATE tblQMTestResult
		SET strPropertyValue = SI.strPropertyValue
			,strComment = SI.strComment
			,strResult = SI.strResult
			,dtmPropertyValueCreated = (
				CASE 
					WHEN SI.strPropertyValue <> ''
						THEN GETDATE()
					ELSE NULL
					END
				)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			AND TR.intSampleId = @intSampleId
		JOIN tblQMSampleImport SI ON SI.strPropertyName = P.strPropertyName
			AND SI.strSampleNumber = @strSampleRefNo

		SELECT @intSampleImportId = MIN(intSampleImportId)
		FROM @ImportHeader
		WHERE intSampleImportId > @intSampleImportId
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
