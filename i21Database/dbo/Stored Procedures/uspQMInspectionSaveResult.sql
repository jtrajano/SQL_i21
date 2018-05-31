CREATE PROCEDURE [dbo].[uspQMInspectionSaveResult] @intControlPointId INT -- 3 (Inspection)
	,@intProductTypeId INT -- 3 / 4 (Receipt / Shipment)
	,@intProductValueId INT -- intInventoryReceiptId / intInventoryShipmentId
	,@intUserId INT
	,@strQualityInspectionTable QualityInspectionTable READONLY
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intProductId INT
	DECLARE @dtmCurrentDate DATETIME = GETDATE()
		,@intSampleId INT = 0
		,@intSampleTypeId INT
		,@intLocationId INT
		,@dtmBusinessDate DATETIME
		,@intShiftId INT
		,@strSampleNumber NVARCHAR(30)
		,@intInventoryReceiptId INT
		,@intInventoryShipmentId INT
	DECLARE @intValidDate INT

	SET @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	IF @intProductTypeId = 3 -- Receipt
		OR @intProductTypeId = 4 -- Shipment
		OR @intProductTypeId = 5 -- Transfer
	BEGIN
		SELECT TOP 1 @intProductId = P.intProductId
			,@intSampleTypeId = PC.intSampleTypeId
		FROM tblQMProduct P
		JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
		WHERE P.intProductTypeId = @intProductTypeId
			AND P.intProductValueId IS NULL
			AND PC.intControlPointId = @intControlPointId
			AND P.ysnActive = 1
		ORDER BY P.intProductId DESC
	END

	-- Template check
	IF @intProductId IS NULL
		RETURN;

	SELECT @intSampleId = ISNULL(MIN(S.intSampleId), 0)
	FROM tblQMTestResult TR
	JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
	WHERE S.intProductTypeId = @intProductTypeId
		AND S.intProductValueId = @intProductValueId
		AND TR.intControlPointId = @intControlPointId

	BEGIN TRAN

	IF @intSampleId = 0
	BEGIN
		IF @intProductTypeId = 3 -- Receipt
		BEGIN
			SELECT @intLocationId = IR.intLocationId
				,@intInventoryReceiptId = IR.intInventoryReceiptId
				,@intInventoryShipmentId = NULL
			FROM tblICInventoryReceipt IR
			WHERE IR.intInventoryReceiptId = @intProductValueId
		END
		ELSE IF @intProductTypeId = 4 -- Shipment
		BEGIN
			SELECT @intLocationId = INVS.intShipFromLocationId
				,@intInventoryReceiptId = NULL
				,@intInventoryShipmentId = INVS.intInventoryShipmentId
			FROM tblICInventoryShipment INVS
			WHERE INVS.intInventoryShipmentId = @intProductValueId
		END

		-- Business Date and Shift Id
		SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

		SELECT @intShiftId = intShiftId
		FROM tblMFShift
		WHERE intLocationId = @intLocationId
			AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
				AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

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

		INSERT INTO tblQMSample (
			intConcurrencyId
			,intSampleTypeId
			,strSampleNumber
			,intProductTypeId
			,intProductValueId
			,intSampleStatusId
			,dtmSampleReceivedDate
			,dtmTestedOn
			,dtmTestingStartDate
			,dtmTestingEndDate
			,dtmSamplingEndDate
			,dtmBusinessDate
			,intShiftId
			,intLocationId
			,intInventoryReceiptId
			,intInventoryShipmentId
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			)
		SELECT 1
			,@intSampleTypeId
			,@strSampleNumber
			,@intProductTypeId
			,@intProductValueId
			,1 -- Received
			,@dtmCurrentDate
			,@dtmCurrentDate
			,@dtmCurrentDate
			,@dtmCurrentDate
			,@dtmCurrentDate
			,@dtmBusinessDate
			,@intShiftId
			,@intLocationId
			,@intInventoryReceiptId
			,@intInventoryShipmentId
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
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
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
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
			,intProductPropertyValidityPeriodId
			,intControlPointId
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			)
		SELECT 1
			,@intSampleId
			,@intProductId
			,@intProductTypeId
			,@intProductValueId
			,PP.intTestId
			,PP.intPropertyId
			,CASE 
				WHEN (PR.intDataTypeId = 4)
					THEN 'false'
				ELSE ''
				END
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
			,PPV.intProductPropertyValidityPeriodId
			,@intControlPointId
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
		FROM tblQMProductProperty PP
		JOIN tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
		JOIN tblQMProperty PR ON PR.intPropertyId = PP.intPropertyId
		WHERE PP.intProductId = @intProductId
			AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
				AND DATEPART(dy, PPV.dtmValidTo)
		ORDER BY PP.intSequenceNo
	END

	IF @intSampleId <> 0
	BEGIN
		UPDATE TR
		SET strPropertyValue = LOWER(QIT.strPropertyValue)
			,intConcurrencyId = TR.intConcurrencyId + 1
			,intLastModifiedUserId = @intUserId
			,dtmLastModified = GETDATE()
			,strComment = ISNULL(QIT.strComment, '')
		FROM tblQMTestResult TR
		JOIN @strQualityInspectionTable QIT ON QIT.intPropertyId = TR.intPropertyId
		JOIN tblQMProperty P ON P.intPropertyId = QIT.intPropertyId
		WHERE TR.intSampleId = @intSampleId
			AND P.intDataTypeId = 4 -- Bit
			AND (
				TR.strPropertyValue <> QIT.strPropertyValue
				OR TR.strComment <> QIT.strComment
				)

		-- Setting result for the properties
		UPDATE tblQMTestResult
		SET strResult = dbo.fnQMGetPropertyTestResult(TR.intTestResultId)
		FROM tblQMTestResult TR
		WHERE TR.intSampleId = @intSampleId
			AND ISNULL(TR.strPropertyValue, '') <> ''
	END

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
