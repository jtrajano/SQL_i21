CREATE PROCEDURE uspQMGetCOAApprovedSample
     @intLotId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
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

	SELECT TOP 1 @intSampleId = S.intSampleId
	FROM dbo.tblQMSample S
	JOIN dbo.tblQMTestResult TR ON TR.intSampleId = S.intSampleId
		AND S.intSampleStatusId = 3
		AND S.intProductTypeId = @intProductTypeId
		AND S.intProductValueId = @intProductValueId

	IF @intSampleId IS NULL
		SELECT 0 AS intSampleId
	ELSE
		SELECT @intSampleId AS intSampleId
END
