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
	DECLARE @intTestResultId INT

	SET @intTestResultId = 0

	DECLARE @intValidDate INT

	SET @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	IF @intProductTypeId = 3 -- Receipt
		OR @intProductTypeId = 4 -- Shipment
		OR @intProductTypeId = 5 -- Transfer
	BEGIN
		SET @intProductId = (
				SELECT TOP 1 P.intProductId
				FROM dbo.tblQMProduct P
				JOIN dbo.tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				WHERE P.intProductTypeId = @intProductTypeId
					AND P.intProductValueId IS NULL
					AND PC.intControlPointId = @intControlPointId
					AND P.ysnActive = 1
				ORDER BY P.intProductId DESC
				)

		SELECT @intTestResultId = ISNULL(TR.intTestResultId, 0)
		FROM dbo.tblQMTestResult TR
		WHERE TR.intProductTypeId = @intProductTypeId
			AND TR.intProductValueId = @intProductValueId
			AND TR.intControlPointId = @intControlPointId
	END

	BEGIN TRAN

	IF @intTestResultId = 0
	BEGIN
		INSERT INTO dbo.tblQMTestResult (
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
			,NULL
			,@intProductId
			,@intProductTypeId
			,@intProductValueId
			,PP.intTestId
			,PP.intPropertyId
			--,(
			--	CASE 
			--		WHEN LOWER(PPV.strPropertyRangeText) = 'true'
			--			THEN 'true'
			--		ELSE CASE 
			--				WHEN (PR.intDataTypeId = 4)
			--					THEN 'false'
			--				ELSE ''
			--				END
			--		END
			--	) AS strPropertyValue
			,CASE 
				WHEN (PR.intDataTypeId = 4)
					THEN 'false'
				ELSE ''
				END
			,GETDATE()
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
			,GETDATE()
			,@intUserId
			,GETDATE()
		FROM dbo.tblQMProductProperty PP
		JOIN dbo.tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
		JOIN dbo.tblQMProperty PR ON PR.intPropertyId = PP.intPropertyId
		WHERE PP.intProductId = @intProductId
			AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
				AND DATEPART(dy, PPV.dtmValidTo)
		ORDER BY PP.intSequenceNo
	END

	SELECT TOP 1 @intTestResultId = TR.intTestResultId
	FROM dbo.tblQMTestResult TR
	WHERE TR.intProductTypeId = @intProductTypeId
		AND TR.intProductValueId = @intProductValueId
		AND TR.intControlPointId = @intControlPointId

	IF @intTestResultId <> 0
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
		WHERE intProductTypeId = @intProductTypeId
			AND intProductValueId = @intProductValueId
			AND P.intDataTypeId = 4 -- Bit
			AND intControlPointId = @intControlPointId
			AND (
				TR.strPropertyValue <> QIT.strPropertyValue
				OR TR.strComment <> QIT.strComment
				)

		-- Setting result for the properties
		UPDATE tblQMTestResult
		SET strResult = dbo.fnQMGetPropertyTestResult(TR.intTestResultId)
		FROM tblQMTestResult TR
		WHERE intProductTypeId = @intProductTypeId
			AND intProductValueId = @intProductValueId
			AND intControlPointId = @intControlPointId
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
