CREATE PROCEDURE [dbo].[uspMFCreateUpdateParentLotNumber] @strParentLotNumber NVARCHAR(50) = NULL
	,@strParentLotAlias NVARCHAR(50)
	,@intItemId INT
	,@dtmExpiryDate DATETIME
	,@intLotStatusId INT
	,@intEntityUserSecurityId INT
	,@intLotId INT
	,@intParentLotId INT = NULL OUTPUT
	,@intSubLocationId INT = NULL
	,@intLocationId INT = NULL
	,@dtmDate DATETIME = NULL
	,@intShiftId INT = NULL
AS
BEGIN
	DECLARE @ErrMsg NVARCHAR(Max)
		,@intCategoryId INT
		,@dtmBusinessDate DATETIME
		,@intBusinessShiftId INT
		,@dtmCurrentDateTime DATETIME
		,@ysnRequireCustomerApproval BIT

	SELECT @dtmCurrentDateTime = GETDATE()

	IF @dtmDate IS NULL
	BEGIN
		SELECT @dtmDate = @dtmCurrentDateTime
	END

	IF @strParentLotNumber IS NULL
		OR @strParentLotNumber = ''
	BEGIN
		SELECT @intCategoryId = intCategoryId
		FROM tblICItem
		WHERE intItemId = @intItemId

		IF @intShiftId IS NULL
		BEGIN
			SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

			SELECT @intShiftId = intShiftId
			FROM dbo.tblMFShift
			WHERE intLocationId = @intLocationId
				AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
					AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset
		END

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
			,@intShiftId = @intShiftId
			,@dtmDate = @dtmDate
	END

	SELECT @intParentLotId = intParentLotId
	FROM tblICParentLot
	WHERE strParentLotNumber = @strParentLotNumber

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

		RETURN - 1;
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
		UPDATE tblICLot
		SET intParentLotId = @intParentLotId
		WHERE intLotId = @intLotId
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblMFLotInventory
			WHERE intLotId = @intLotId
			)
	BEGIN
		Declare @strLotNumber nvarchar(50),@intBondStatusId int
		Select @strLotNumber=strLotNumber from tblICLot Where intLotId=@intLotId

		Select @intBondStatusId=NULL

		Select @intBondStatusId=LI.intBondStatusId from tblMFLotInventory LI JOIN tblICLot L on L.intLotId=LI.intLotId Where L.strLotNumber=@strLotNumber

		SELECT @ysnRequireCustomerApproval = ysnRequireCustomerApproval
		FROM tblICItem
		WHERE intItemId = @intItemId

		INSERT INTO tblMFLotInventory (
			intLotId
			,intBondStatusId
			)
		SELECT @intLotId
			,IsNULL(@intBondStatusId,(CASE 
				WHEN @ysnRequireCustomerApproval = 1
					THEN (
							SELECT intBondStatusId
							FROM tblMFCompanyPreference
							)
				ELSE NULL
				END))
	END
END
