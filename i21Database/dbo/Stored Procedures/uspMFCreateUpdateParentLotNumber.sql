CREATE PROCEDURE [dbo].[uspMFCreateUpdateParentLotNumber] 
	@strParentLotNumber NVARCHAR(50) = NULL
	,@strParentLotAlias NVARCHAR(50)
	,@intItemId INT
	,@dtmExpiryDate DATETIME
	,@intLotStatusId INT
	,@intEntityUserSecurityId INT
	,@intLotId INT
	,@intParentLotId INT = NULL OUTPUT 
	,@intSubLocationId INT = NULL
	,@intLocationId INT = NULL 
AS

	DECLARE @ErrMsg NVARCHAR(Max)
			,@intCategoryId int

	IF @strParentLotNumber IS NULL OR @strParentLotNumber = ''
	BEGIN
		--EXEC dbo.uspSMGetStartingNumber 
		--	78
		--	,@strParentLotNumber OUTPUT
		Select @intCategoryId=intCategoryId from tblICItem Where intItemId=@intItemId

		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intItemId
			,@intManufacturingId = NULL
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 78
			,@ysnProposed = 0
			,@strPatternString = @strParentLotNumber OUTPUT
	END

	SELECT @intParentLotId = intParentLotId
	FROM tblICParentLot
	WHERE strParentLotNumber = @strParentLotNumber

	--IF @dtmDate IS NULL
	--	SET @dtmDate = GETDATE()

	IF NOT EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE intLotId = @intLotId
	)
	BEGIN 
		RAISERROR (
		'Lot does not exist for parent lot creation.'
		,16
		,1
		)

		RETURN -1;
	END 

	IF ISNULL(@intParentLotId, 0) = 0
	BEGIN
		INSERT INTO tblICParentLot (
			strParentLotNumber
			,strParentLotAlias
			,intItemId
			,dtmExpiryDate
			,intLotStatusId
			,intCreatedEntityId
			,dtmDateCreated
			)
		VALUES (
			@strParentLotNumber
			,@strParentLotAlias
			,@intItemId
			,@dtmExpiryDate
			,@intLotStatusId
			,@intEntityUserSecurityId
			,GETDATE()
			)

		SELECT @intParentLotId = SCOPE_IDENTITY()

		UPDATE tblICLot
		SET intParentLotId = @intParentLotId
		WHERE intLotId = @intLotId
	END
	ELSE
	BEGIN
		--IF (
		--		SELECT intItemId
		--		FROM tblICParentLot
		--		WHERE intParentLotId = @intParentLotId
		--) <> @intItemId
		--BEGIN 
		--	RAISERROR (
		--		'Lot and Parent Lot cannot have different item.'
		--		,16
		--		,1
		--	)
		--	RETURN -1;
		--END 
			

		UPDATE tblICLot
		SET intParentLotId = @intParentLotId
		WHERE intLotId = @intLotId
	END
