--EXEC uspQMReportCOAGetMicrobiologicalSample @intLotId=2588;
CREATE PROCEDURE uspQMReportCOAGetMicrobiologicalSample
     @intLotId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @ysnEnableParentLot BIT
	DECLARE @intProductTypeId INT
	DECLARE @intProductValueId INT
	DECLARE @intNoOfSample INT
	DECLARE @SampleNo TABLE (intSampleId INT)
	DECLARE @SQL NVARCHAR(MAX)

	SET @intProductTypeId = 6
	SET @intProductValueId = @intLotId

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM dbo.tblQMCompanyPreference

	IF @ysnEnableParentLot = 1
	BEGIN
		SET @intProductTypeId = 11

		SELECT @intProductValueId = intParentLotId
		FROM dbo.tblICLot
		WHERE intLotId = @intLotId
	END

	SELECT @intNoOfSample = CM.intNoOfSample
	FROM dbo.tblQMCOAMapping CM
	JOIN dbo.tblICLot L ON L.intItemId = CM.intItemId
	WHERE L.intLotId = @intLotId

	SET @SQL = 'SELECT DISTINCT TOP ' + CONVERT(NVARCHAR, @intNoOfSample) + ' S.intSampleId
			  FROM dbo.tblQMSample S
			  JOIN dbo.tblQMTestResult TR ON TR.intSampleId = S.intSampleId
				  AND S.intSampleStatusId = 3
				  AND S.intProductTypeId = ' + CONVERT(NVARCHAR, @intProductTypeId) + '
				  AND S.intProductValueId = ' + CONVERT(NVARCHAR, @intProductValueId) + '
			  ORDER BY S.intSampleId DESC'

	INSERT INTO @SampleNo
	EXEC sp_executesql @SQL

	SELECT DISTINCT 'Composite Sample - ' + LTRIM(DENSE_RANK() OVER (
				ORDER BY S.intSampleId DESC
				)) AS strCompositeSample
		,S.intSampleId
		,P.strPropertyName
		,CASE 
			WHEN ISNULL(TR.strComment, '') <> ''
				THEN TR.strComment
			ELSE CASE 
					WHEN ISNULL(TR.strPropertyValue, '') = ''
						THEN 'Nil'
					ELSE TR.strPropertyValue
					END
			END AS strPropertyValue
		,TM.strTestMethodName
		,CASE 
			WHEN ISNULL(UC.strUnitMeasure, '') = ''
				THEN 'Nil'
			ELSE UC.strUnitMeasure
			END AS strUnitMeasure
		,CMD.strSpecification
	FROM dbo.tblQMTestResult TR
	JOIN dbo.tblQMSample S ON S.intSampleId = TR.intSampleId
		AND S.intSampleId IN (
			SELECT intSampleId
			FROM @SampleNo
			)
		AND S.intSampleStatusId = 3
		AND TR.intProductValueId = @intProductValueId
		AND TR.intProductTypeId = @intProductTypeId
		AND TR.strPropertyValue <> ''
	JOIN dbo.tblQMProduct PRD ON PRD.intProductId = TR.intProductId
	JOIN dbo.tblQMTest T ON T.intTestId = TR.intTestId
	JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	JOIN dbo.tblQMCOAMapping CM ON CM.intItemId = S.intItemId
	JOIN dbo.tblQMCOAMappingDetail CMD ON CMD.intCOAMappingId = CM.intCOAMappingId
		AND CMD.intPropertyId = TR.intPropertyId
		AND CMD.strTestType = 'Microbiological'
		AND CMD.intProductId = TR.intProductId
		AND CMD.ysnIsRequired = 1
	JOIN dbo.tblQMTestMethod TM ON TM.intTestMethodId = CMD.intTestMethodId
	LEFT JOIN dbo.tblICUnitMeasure UC ON UC.intUnitMeasureId = TR.intUnitMeasureId
	GROUP BY P.strPropertyName
		,TM.strTestMethodName
		,UC.strUnitMeasure
		,CMD.strSpecification
		,TR.strComment
		,TR.strPropertyValue
		,S.intSampleId
	ORDER BY S.intSampleId DESC
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportCOAGetMicrobiologicalSample - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
