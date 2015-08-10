CREATE PROCEDURE [dbo].[uspQMGetSampleNumber]
	@intProductTypeId INT
	,@intProductValueId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intSampleId INT

SELECT TOP 1 @intSampleId = intSampleId
FROM dbo.tblQMSample
WHERE intProductTypeId = @intProductTypeId
	AND intProductValueId = @intProductValueId
ORDER BY intSampleId DESC

IF @intSampleId IS NULL
	SELECT 0 AS intSampleId
ELSE
	SELECT @intSampleId AS intSampleId
