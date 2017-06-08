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
		,@intItemOwnerId INT
		,@ysnPickByLotCode BIT
		,@intLotCodeStartingPosition INT
		,@intLotCodeNoOfDigits INT

	SELECT @ysnPickByLotCode = ysnPickByLotCode
		,@intLotCodeStartingPosition = intLotCodeStartingPosition
		,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
	FROM tblMFCompanyPreference

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
		IF @ysnPickByLotCode = 1
			AND ISNUMERIC(Substring(@strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)) = 0
		BEGIN
			RAISERROR (
					'Invalid Lot Code'
					,11
					,1
					)
		END

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
		DECLARE @strLotNumber NVARCHAR(50)
			,@intBondStatusId INT
			,@strContainerNo NVARCHAR(50)
			,@intInventoryReceiptItemId INT
			,@intInventoryReceiptId INT
			,@strVendorRefNo NVARCHAR(50)
			,@strWarehouseRefNo NVARCHAR(50)
			,@strReceiptNumber NVARCHAR(50)
			,@strTransactionId NVARCHAR(50)
			,@dtmReceiptDate DATETIME

		SELECT @strLotNumber = strLotNumber
		FROM tblICLot
		WHERE intLotId = @intLotId

		SELECT @intBondStatusId = NULL

		SELECT @intBondStatusId = LI.intBondStatusId
			,@intItemOwnerId = LI.intItemOwnerId
			,@strVendorRefNo = LI.strVendorRefNo
			,@strWarehouseRefNo = LI.strWarehouseRefNo
			,@strReceiptNumber = LI.strReceiptNumber
			,@dtmReceiptDate = dtmReceiptDate
		FROM tblMFLotInventory LI
		JOIN tblICLot L ON L.intLotId = LI.intLotId
		WHERE L.strLotNumber = @strLotNumber

		if @intBondStatusId is null and not exists(Select *from tblICLot L WHERE L.strLotNumber = @strLotNumber)
		Begin
			Select @intBondStatusId=
					CASE 
						WHEN @ysnRequireCustomerApproval = 1
							THEN (
									SELECT intBondStatusId
									FROM tblMFCompanyPreference
									)
						ELSE NULL
						END
					
		End

		SELECT @ysnRequireCustomerApproval = ysnRequireCustomerApproval
		FROM tblICItem
		WHERE intItemId = @intItemId

		IF @intItemOwnerId IS NULL
		BEGIN
			SELECT @intItemOwnerId = intItemOwnerId
			FROM tblICItemOwner
			WHERE intItemId = @intItemId
				AND ysnDefault = 1
		END

		IF @strReceiptNumber IS NULL
		BEGIN
			SELECT @strTransactionId = strTransactionId
			FROM tblICLot
			WHERE intLotId = @intLotId

			SELECT @strVendorRefNo = strVendorRefNo
				,@strWarehouseRefNo = strWarehouseRefNo
				,@strReceiptNumber = strReceiptNumber
				,@dtmReceiptDate = dtmReceiptDate
			FROM tblICInventoryReceipt
			WHERE strReceiptNumber = @strTransactionId
		END

		INSERT INTO tblMFLotInventory (
			intLotId
			,intBondStatusId
			,intItemOwnerId
			,strVendorRefNo
			,strWarehouseRefNo
			,strReceiptNumber
			,dtmReceiptDate
			)
		SELECT @intLotId
			,@intBondStatusId
			,@intItemOwnerId
			,@strVendorRefNo
			,@strWarehouseRefNo
			,@strReceiptNumber
			,@dtmReceiptDate
	END
	ELSE
	BEGIN
		UPDATE tblMFLotInventory
		SET strVendorRefNo = @strVendorRefNo
			,strWarehouseRefNo = @strWarehouseRefNo
			,strReceiptNumber = @strReceiptNumber
			,dtmReceiptDate = @dtmReceiptDate
		WHERE intLotId = @intLotId
	END
END
