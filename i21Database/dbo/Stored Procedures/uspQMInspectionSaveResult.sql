CREATE PROCEDURE [dbo].[uspQMInspectionSaveResult]
	@intControlPointId INT -- 3 / 8 (Inspection / Shipping)
	,@intProductTypeId INT -- 3 (Receipt)
	,@intProductValueId INT -- intInventoryReceiptId
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
				SELECT P.intProductId
				FROM dbo.tblQMProduct P
				JOIN dbo.tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				WHERE P.intProductTypeId = @intProductTypeId
					AND P.intProductValueId IS NULL
					AND PC.intControlPointId = @intControlPointId
					AND P.ysnActive = 1
				)

		SELECT @intTestResultId = ISNULL(TR.intTestResultId, 0)
		FROM dbo.tblQMTestResult TR
		WHERE TR.intProductTypeId = @intProductTypeId
			AND TR.intProductValueId = @intProductValueId
			AND TR.intControlPointId = @intControlPointId
	END

	BEGIN TRAN

	IF @intTestResultId = 0
		INSERT INTO dbo.tblQMTestResult (
			intConcurrencyId
			,intProductTypeId
			,intProductValueId
			,intTestId
			,intPropertyId
			,strPropertyValue
			,dtmCreateDate
			,ysnFinal
			,intSequenceNo
			,dtmValidFrom
			,dtmValidTo
			,intControlPointId
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			)
		SELECT 1
			,@intProductTypeId
			,@intProductValueId
			,PP.intTestId
			,PP.intPropertyId
			,CASE 
				WHEN LOWER(PPV.strPropertyRangeText) = 'true'
					THEN 'true'
				ELSE 'false'
				END AS strPropertyValue
			,GETDATE()
			,0
			,PP.intSequenceNo
			,PPV.dtmValidFrom
			,PPV.dtmValidTo
			,@intControlPointId
			,@intUserId
			,GETDATE()
			,@intUserId
			,GETDATE()
		FROM dbo.tblQMProductProperty PP
		JOIN dbo.tblQMProductPropertyValidityPeriod PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
		WHERE PP.intProductId = @intProductId
			AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
				AND DATEPART(dy, PPV.dtmValidTo)
		ORDER BY PP.intSequenceNo

	SELECT TOP 1 @intTestResultId = TR.intTestResultId
	FROM dbo.tblQMTestResult TR
	WHERE TR.intProductTypeId = @intProductTypeId
		AND TR.intProductValueId = @intProductValueId
		AND TR.intControlPointId = @intControlPointId

	IF @intTestResultId <> 0
	BEGIN
		UPDATE TR
		SET strPropertyValue = QIT.strPropertyValue
			,intConcurrencyId = TR.intConcurrencyId + 1
			,intLastModifiedUserId = @intUserId
			,dtmLastModified = GETDATE()
		FROM tblQMTestResult TR
		JOIN @strQualityInspectionTable QIT ON QIT.intPropertyId = TR.intPropertyId
		JOIN tblQMProperty P ON P.intPropertyId = QIT.intPropertyId
		WHERE intProductTypeId = @intProductTypeId
			AND intProductValueId = @intProductValueId
			AND intControlPointId = @intControlPointId
			AND TR.strPropertyValue <> QIT.strPropertyValue
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
