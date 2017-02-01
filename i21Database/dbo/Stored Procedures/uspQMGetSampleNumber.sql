CREATE PROCEDURE uspQMGetSampleNumber @intProductTypeId INT
	,@intProductValueId INT
	,@intUserRoleID INT = 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strSampleId NVARCHAR(MAX)
DECLARE @ysnEnableSampleTypeByUserRole BIT

SELECT TOP 1 @ysnEnableSampleTypeByUserRole = ISNULL(ysnEnableSampleTypeByUserRole, 0)
FROM tblQMCompanyPreference

IF @intProductTypeId = 6 -- Take all samples from the multiple Lot ID
BEGIN
	DECLARE @strLotNumber NVARCHAR(50)

	SELECT @strLotNumber = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intProductValueId

	IF @ysnEnableSampleTypeByUserRole = 1
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
			AND SU.intUserRoleID = @intUserRoleID
		WHERE S.intProductTypeId = @intProductTypeId
			AND S.strLotNumber = @strLotNumber
		ORDER BY S.intSampleId DESC
	END
	ELSE
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		WHERE S.intProductTypeId = @intProductTypeId
			AND S.strLotNumber = @strLotNumber
		ORDER BY S.intSampleId DESC
	END
END
ELSE
BEGIN
	IF @ysnEnableSampleTypeByUserRole = 1
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
			AND SU.intUserRoleID = @intUserRoleID
		WHERE S.intProductTypeId = @intProductTypeId
			AND S.intProductValueId = @intProductValueId
		ORDER BY S.intSampleId DESC
	END
	ELSE
	BEGIN
		SELECT @strSampleId = COALESCE(@strSampleId + '|^|', '') + CONVERT(NVARCHAR, S.intSampleId)
		FROM tblQMSample S
		WHERE S.intProductTypeId = @intProductTypeId
			AND S.intProductValueId = @intProductValueId
		ORDER BY S.intSampleId DESC
	END
END

IF @strSampleId IS NULL
	SELECT '0' AS strSampleId
ELSE
	SELECT @strSampleId AS strSampleId
