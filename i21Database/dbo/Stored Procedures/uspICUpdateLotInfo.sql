CREATE PROCEDURE [dbo].[uspICUpdateLotInfo]
	@strField NVARCHAR(50),
	@strValue NVARCHAR(MAX),
	@intSecurityUserId INT,
	@intLotId INT = NULL, -- This will be looked up first, if null, it will fallback to @strLotNumber
	@strLotNumber NVARCHAR(100) = NULL, -- Used when @intLotId is null
	@intItemId INT = NULL, -- required if @intLotId is null and @strLotNumber IS NOT NULL OR EMPTY
	@intLocationId INT = NULL, -- required if @intLotId is null and @strLotNumber IS NOT NULL OR EMPTY
	@intSubLocationId INT = NULL, -- required if @intLotId is null and @strLotNumber IS NOT NULL OR EMPTY
	@intStorageLocationId INT = NULL -- required if @intLotId is null and @strLotNumber IS NOT NULL OR EMPTY
AS

DECLARE @LotId INT

IF @strField IS NULL
BEGIN
	RAISERROR('Specify the field to update.', 11, 1)
	GOTO _Terminate;
END

IF @intLotId IS NOT NULL
	SELECT @LotId = intLotId FROM tblICLot WHERE intLotId = @intLotId
ELSE
BEGIN
	IF NULLIF(@strLotNumber, '') IS NULL OR @intItemId IS NULL OR @intLocationId IS NULL OR @intSubLocationId IS NULL OR @intStorageLocationId IS NULL
	BEGIN
		RAISERROR('Parameters are not valid to be able to find the correct lot.', 11, 1)
		GOTO _Terminate;
	END

	SELECT @LotId = intLotId
	FROM tblICLot 
	WHERE strLotNumber = @strLotNumber
		AND intItemId = @intItemId
		AND intLocationId = @intLocationId
		AND intSubLocationId = @intSubLocationId
		AND intStorageLocationId = @intStorageLocationId
END

IF @LotId IS NULL
BEGIN
	RAISERROR('Cannot find the specified lot number.', 11, 1)
	GOTO _Terminate;	
END

DECLARE @DateModified DATETIME = GETDATE()

IF(@strField = 'strNotes')
	UPDATE tblICLot 
	SET 
		 strNotes = @strValue COLLATE Latin1_General_CI_AS
		,dtmDateModified = @DateModified
		,intModifiedByUserId = @intSecurityUserId 
	WHERE intLotId = @LotId
ELSE IF (@strField = 'strContainerNo')
	UPDATE tblICLot 
	SET
		 strContainerNo = LEFT(@strValue, 100) COLLATE Latin1_General_CI_AS
		,dtmDateModified = @DateModified
		,intModifiedByUserId = @intSecurityUserId 
	WHERE intLotId = @LotId
ELSE
BEGIN
	RAISERROR('Invalid field.', 11, 1)
END

_Terminate:
