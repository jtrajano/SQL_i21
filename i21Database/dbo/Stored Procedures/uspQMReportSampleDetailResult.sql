-- EXEC uspQMReportSampleDetailResult 37
CREATE PROCEDURE uspQMReportSampleDetailResult
     @intSampleId INT
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

	SELECT T.strTestName
		,P.strPropertyName
		,CASE 
			WHEN (P.intDataTypeId IN (
					1
					,2
					,6
					) AND ISNULL(TR.strPropertyValue, '') <> '')
				THEN CONVERT(NVARCHAR, ROUND(ISNULL(TR.strPropertyValue, 0), @intNumberofDecimalPlaces))
			ELSE TR.strPropertyValue
			END AS strPropertyValue
		,TR.strResult
		,TR.dblMinValue
		,TR.dblMaxValue
		,TR.strComment
		,dbo.fnConvertDateToReportDateFormat(TR.dtmLastModified, 1) AS strLastModified
		,P.intDataTypeId
	FROM tblQMTestResult TR
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		AND TR.intSampleId = @intSampleId
	
	JOIN tblQMTest T ON T.intTestId = TR.intTestId
	JOIN tblQMProductProperty PP ON PP.intProductId = TR.intProductId AND PP.intPropertyId = TR.intPropertyId
	WHERE ISNULL(PP.ysnDocumentPrint,0) = 1
	ORDER BY TR.intSequenceNo
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportSampleDetailResult - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
