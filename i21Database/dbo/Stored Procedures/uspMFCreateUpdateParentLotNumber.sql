CREATE PROCEDURE [dbo].[uspMFCreateUpdateParentLotNumber] @strParentLotNumber NVARCHAR(50) = NULL
	,@strParentLotAlias NVARCHAR(50)
	,@intItemId INT
	,@dtmExpiryDate DATETIME
	,@intLotStatusId INT
	,@intUserId INT
	,@dtmDate DATETIME
	,@intLotId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(Max)
		,@intParentLotId INT

	IF @strParentLotNumber Is NULL
	BEGIN
		EXEC dbo.uspSMGetStartingNumber 78
			,@strParentLotNumber OUTPUT
	END

	SELECT @intParentLotId = intParentLotId
	FROM tblICParentLot
	WHERE strParentLotNumber = @strParentLotNumber

	IF @dtmDate IS NULL
		SET @dtmDate = GETDATE()

	IF NOT EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE intLotId = @intLotId
			)
		RAISERROR (
				'Lot does not exist for parent lot creation.'
				,16
				,1
				)

	IF ISNULL(@intParentLotId, 0) = 0
	BEGIN
		INSERT INTO tblICParentLot (
			strParentLotNumber
			,strParentLotAlias
			,intItemId
			,dtmExpiryDate
			,intLotStatusId
			,intCreatedUserId
			,dtmDateCreated
			)
		VALUES (
			@strParentLotNumber
			,@strParentLotAlias
			,@intItemId
			,@dtmExpiryDate
			,@intLotStatusId
			,@intUserId
			,@dtmDate
			)

		SELECT @intParentLotId = SCOPE_IDENTITY()

		UPDATE tblICLot
		SET intParentLotId = @intParentLotId
		WHERE intLotId = @intLotId
	END
	ELSE
	BEGIN
		IF (
				SELECT intItemId
				FROM tblICParentLot
				WHERE intParentLotId = @intParentLotId
				) <> @intItemId
			RAISERROR (
					'Lot and Parent Lot cannot have different item.'
					,16
					,1
					)

		UPDATE tblICLot
		SET intParentLotId = @intParentLotId
		WHERE intLotId = @intLotId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
