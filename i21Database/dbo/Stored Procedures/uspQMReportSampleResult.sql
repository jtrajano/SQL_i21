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

	BEGIN
		IF EXISTS (
				SELECT intPropertyId
				FROM tblQMReportProperty
				WHERE strReportName = 'Quality Label'
				)
		BEGIN
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
			JOIN tblQMProperty P ON TR.intPropertyId = P.intPropertyId
				AND P.intPropertyId IN (
					SELECT intPropertyId
					FROM tblQMReportProperty
					WHERE strReportName = 'Quality Label'
					)
			WHERE TR.intSampleId = @intSampleId
		END
		ELSE
		BEGIN
			SELECT P.strPropertyName
				,TR.dblMinValue
				,TR.dblMaxValue
				,ROUND(ISNULL(TR.strPropertyValue, 0), @intNumberofDecimalPlaces) AS strPropertyValue
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
			JOIN tblQMProperty P ON TR.intPropertyId = P.intPropertyId
			WHERE TR.intSampleId = @intSampleId
		END
	END
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
