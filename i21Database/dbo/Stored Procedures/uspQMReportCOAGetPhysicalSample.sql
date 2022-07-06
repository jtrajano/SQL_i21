﻿--EXEC uspQMReportCOAGetPhysicalSample @intLotId=2588;
CREATE PROCEDURE uspQMReportCOAGetPhysicalSample
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
	DECLARE @intSampleId INT

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

	SELECT TOP 1 @intSampleId = MAX(S.intSampleId)
	FROM dbo.tblQMSample S
	JOIN dbo.tblQMTestResult TR ON TR.intSampleId = S.intSampleId
		AND S.intSampleStatusId = 3
		AND S.intTypeId = 1
		AND S.intProductTypeId = @intProductTypeId
		AND S.intProductValueId = @intProductValueId

	SELECT P.strPropertyName
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
		,CM.strCommentCOA
		,CM.strDisclaimer
	FROM dbo.tblQMTestResult TR
	JOIN dbo.tblQMSample S ON S.intSampleId = TR.intSampleId
		AND S.intSampleId = @intSampleId
		AND S.intSampleStatusId = 3
		AND S.intTypeId = 1
		AND TR.intProductValueId = @intProductValueId
		AND TR.intProductTypeId = @intProductTypeId
	JOIN dbo.tblQMProduct PRD ON PRD.intProductId = TR.intProductId
	JOIN dbo.tblQMTest T ON T.intTestId = TR.intTestId
	JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	JOIN dbo.tblQMCOAMapping CM ON CM.intItemId = S.intItemId
	JOIN dbo.tblQMCOAMappingDetail CMD ON CMD.intCOAMappingId = CM.intCOAMappingId
		AND CMD.intPropertyId = TR.intPropertyId
		AND CMD.strTestType = 'Physical'
		AND CMD.intProductId = TR.intProductId
		AND CMD.ysnIsRequired = 1
	JOIN dbo.tblQMTestMethod TM ON TM.intTestMethodId = CMD.intTestMethodId
	LEFT JOIN dbo.tblICUnitMeasure UC ON UC.intUnitMeasureId = TR.intUnitMeasureId
	GROUP BY P.strPropertyName
		,TR.strPropertyValue
		,TM.strTestMethodName
		,UC.strUnitMeasure
		,CMD.strSpecification
		,TR.strComment
		,CM.strCommentCOA
		,CM.strDisclaimer
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportCOAGetPhysicalSample - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
