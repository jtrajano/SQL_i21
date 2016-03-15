CREATE PROCEDURE [dbo].[uspQMGetSampleNumber]
	@intProductTypeId INT
	,@intProductValueId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strSampleId NVARCHAR(MAX)

SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, intSampleId)
FROM dbo.tblQMSample
WHERE intProductTypeId = @intProductTypeId
	AND intProductValueId = @intProductValueId
ORDER BY intSampleId DESC

IF @strSampleId IS NULL
	SELECT '0' AS strSampleId
ELSE
	SELECT @strSampleId AS strSampleId
