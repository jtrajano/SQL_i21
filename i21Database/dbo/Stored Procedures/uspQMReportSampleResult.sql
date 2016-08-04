CREATE PROCEDURE uspQMReportSampleResult @intSampleId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intNumberofDecimalPlaces INT

	SELECT TOP 1 @intNumberofDecimalPlaces = intNumberofDecimalPlaces
	FROM tblQMCompanyPreference

	SELECT P.strPropertyName
		,TR.dblMinValue
		,TR.dblMaxValue
		,CASE 
			WHEN P.intDataTypeId IN (
					1
					,2
					,6
					)
				THEN CONVERT(NVARCHAR, ROUND(ISNULL(TR.strPropertyValue, 0), @intNumberofDecimalPlaces))
			ELSE TR.strPropertyValue
			END AS strPropertyValue
		,TR.strResult
	FROM tblQMTestResult TR
	JOIN tblQMProduct PRD ON PRD.intProductId = TR.intProductId
		AND TR.intSampleId = @intSampleId
	JOIN tblQMProductProperty PP ON PP.intProductId = PRD.intProductId
		AND PP.intTestId = TR.intTestId
		AND PP.intPropertyId = TR.intPropertyId
		AND PP.ysnPrintInLabel = 1
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	ORDER BY TR.intSequenceNo
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportSampleResult - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
