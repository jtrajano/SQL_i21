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

IF @intProductTypeId = 6 -- Take all samples from the multiple Lot ID
BEGIN
	DECLARE @strLotNumber NVARCHAR(50)

	SELECT @strLotNumber = strLotNumber
	FROM dbo.tblICLot
	WHERE intLotId = @intProductValueId

	SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, intSampleId)
	FROM dbo.tblQMSample
	WHERE intProductTypeId = @intProductTypeId
		AND strLotNumber = @strLotNumber
	ORDER BY intSampleId DESC
END
ELSE
BEGIN
	SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, intSampleId)
	FROM dbo.tblQMSample
	WHERE intProductTypeId = @intProductTypeId
		AND intProductValueId = @intProductValueId
	ORDER BY intSampleId DESC
END

IF @strSampleId IS NULL
	SELECT '0' AS strSampleId
ELSE
	SELECT @strSampleId AS strSampleId
