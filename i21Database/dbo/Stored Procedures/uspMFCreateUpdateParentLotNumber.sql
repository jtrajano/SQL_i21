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
		,@strLotTracking NVARCHAR(50)
		,@intDamagedStatusId INT
		,@strLotCode NVARCHAR(50)
		,@dtmManufacturedDate DATETIME
		,@strLifeTimeType NVARCHAR(50)
		,@intLifeTime INT
		,@intLotDueDays INT
		,@dtmDueDate DATETIME
		,@ysnLifeTimeByEndOfMonth BIT
		,@strLotNumber NVARCHAR(50)
		,@intBondStatusId INT
		,@strContainerNo NVARCHAR(50)
		,@intInventoryReceiptItemId INT
		,@intInventoryReceiptId INT
		,@strVendorRefNo NVARCHAR(50)
		,@strWarehouseRefNo NVARCHAR(50)
		,@strReceiptNumber NVARCHAR(50)
		,@strTransactionId NVARCHAR(50)
		,@dtmReceiptDate DATETIME
		,@strCondition NVARCHAR(50)
		,@intSplitFromLotId INT
		,@ysnBonded BIT
		,@strLotReceiptNumber NVARCHAR(50)
		,@dblTareWeight NUMERIC(38, 20)
		,@ysnPickAllowed BIT
		,@ysnSendEDIOnRepost BIT

	SELECT @ysnPickByLotCode = ysnPickByLotCode
		,@intLotCodeStartingPosition = intLotCodeStartingPosition
		,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
		,@intDamagedStatusId = intDamagedStatusId
		,@intLotDueDays = intLotDueDays
		,@ysnLifeTimeByEndOfMonth = ysnLifeTimeByEndOfMonth
		,@ysnSendEDIOnRepost=ysnSendEDIOnRepost
	FROM tblMFCompanyPreference

	SELECT @strLotNumber = strLotNumber
		,@strCondition = strCondition
		,@intSplitFromLotId = intSplitFromLotId
		,@strLotReceiptNumber = strReceiptNumber
	FROM tblICLot
	WHERE intLotId = @intLotId

	If @intSplitFromLotId is null and @ysnLifeTimeByEndOfMonth=1
	Begin
		SELECT @strLifeTimeType = strLifeTimeType
			,@intLifeTime = intLifeTime
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		If @strLifeTimeType = 'Months'
		Begin
			SET @dtmExpiryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DateAdd(mm, @intLifeTime, GetDate())) + 1, 0))
		End

	End

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

	SELECT @strLotNumber=strLotNumber
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE strLotNumber=@strLotNumber and intItemId<>@intItemId
			and dblQty>0
			and intLocationId=@intLocationId
			)
	BEGIN
		RAISERROR (
				'Lot number already exists. Note: Same lot number cannot be used by more than one item.'
				,16
				,1
				)

		RETURN - 1;
	END

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

	IF @ysnPickByLotCode = 1
	BEGIN
		SELECT @strLotCode = Substring(@strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)

		IF ISNUMERIC(@strLotCode) = 0
		BEGIN
			RAISERROR (
					'Invalid Lot Code'
					,11
					,1
					)
		END

		IF Len(@strLotCode) = 5
		BEGIN
			SELECT @dtmManufacturedDate = DATEADD(day, CAST(RIGHT(@strLotCode, 3) AS INT) - 1, CONVERT(DATETIME, LEFT(@strLotCode, 2) + '0101', 112))

			SELECT @strLifeTimeType = strLifeTimeType
				,@intLifeTime = intLifeTime
			FROM dbo.tblICItem
			WHERE intItemId = @intItemId

			IF @strLifeTimeType = 'Years'
				SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, @dtmManufacturedDate)
			ELSE IF @strLifeTimeType = 'Months'
				AND @ysnLifeTimeByEndOfMonth = 0
				SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, @dtmManufacturedDate)
			ELSE IF @strLifeTimeType = 'Months'
				AND @ysnLifeTimeByEndOfMonth = 1
				SET @dtmExpiryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DateAdd(mm, @intLifeTime, @dtmManufacturedDate)) + 1, 0))
			ELSE IF @strLifeTimeType = 'Days'
				SET @dtmExpiryDate = DateAdd(dd, @intLifeTime, @dtmManufacturedDate)
			ELSE IF @strLifeTimeType = 'Hours'
				SET @dtmExpiryDate = DateAdd(hh, @intLifeTime, @dtmManufacturedDate)
			ELSE IF @strLifeTimeType = 'Minutes'
				SET @dtmExpiryDate = DateAdd(mi, @intLifeTime, @dtmManufacturedDate)
			ELSE
				SET @dtmExpiryDate = DateAdd(yy, 1, @dtmManufacturedDate)
		END
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
			,dtmManufacturedDate = CASE 
				WHEN @ysnPickByLotCode = 1
					AND Len(@strLotCode) = 5
					THEN @dtmManufacturedDate
				ELSE dtmManufacturedDate
				END
			,dtmExpiryDate = CASE 
				WHEN (@ysnPickByLotCode = 1
					AND Len(@strLotCode) = 5) or (@strLifeTimeType = 'Months' and @intSplitFromLotId is null and @ysnLifeTimeByEndOfMonth=1)
					THEN @dtmExpiryDate
				ELSE dtmExpiryDate
				END
		WHERE intLotId = @intLotId
	END
	ELSE
	BEGIN
		UPDATE tblICLot
		SET intParentLotId = @intParentLotId
			,dtmManufacturedDate = CASE 
				WHEN @ysnPickByLotCode = 1
					AND Len(@strLotCode) = 5
					THEN @dtmManufacturedDate
				ELSE dtmManufacturedDate
				END
			,dtmExpiryDate = CASE 
				WHEN (@ysnPickByLotCode = 1
					AND Len(@strLotCode) = 5) or (@strLifeTimeType = 'Months' and @intSplitFromLotId is null and @ysnLifeTimeByEndOfMonth=1)
					THEN @dtmExpiryDate
				ELSE dtmExpiryDate
				END
		WHERE intLotId = @intLotId
	END




	IF @intSplitFromLotId IS NULL
		AND @strCondition = 'Damaged'
	BEGIN
		SELECT @strLotTracking = strLotTracking
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		IF @intDamagedStatusId IS NOT NULL
			AND NOT EXISTS (
				SELECT *
				FROM dbo.tblICLot
				WHERE intLotId = @intLotId
					AND intLotStatusId = @intDamagedStatusId
				)
			AND @strLotTracking <> 'No'
		BEGIN
			EXEC uspMFSetLotStatus @intLotId
				,@intDamagedStatusId
				,@intEntityUserSecurityId
		END
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblMFLotInventory
			WHERE intLotId = @intLotId
			)
	BEGIN
		SELECT @intBondStatusId = NULL

		SELECT @intBondStatusId = LI.intBondStatusId
			,@strVendorRefNo = LI.strVendorRefNo
			,@strWarehouseRefNo = LI.strWarehouseRefNo
			,@strReceiptNumber = LI.strReceiptNumber
			,@dtmReceiptDate = dtmReceiptDate
			,@dblTareWeight = dblTareWeight
			,@dtmDueDate = dtmDueDate
			,@ysnPickAllowed=ysnPickAllowed
		FROM tblMFLotInventory LI
		WHERE LI.intLotId = @intSplitFromLotId

		IF @dtmDueDate IS NULL
		BEGIN
			SELECT @dtmDueDate = DateAdd(dd, @intLotDueDays, @dtmCurrentDateTime)
		END

		SELECT @ysnRequireCustomerApproval = ysnRequireCustomerApproval
		FROM tblICItem
		WHERE intItemId = @intItemId

		SELECT @intInventoryReceiptId = intInventoryReceiptId
		FROM tblICInventoryReceipt
		WHERE strReceiptNumber = @strLotReceiptNumber

		SELECT TOP 1 @ysnBonded = FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'Bonded'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryReceipt'
		WHERE T.intRecordId = @intInventoryReceiptId

		IF @ysnBonded IS NULL
			SELECT @ysnBonded = 0

		IF @intBondStatusId IS NULL
			AND @intSplitFromLotId IS NULL
		BEGIN
			SELECT @intBondStatusId = CASE 
					WHEN (
							@ysnRequireCustomerApproval = 1
							OR @ysnBonded = 1
							)
						THEN (
								SELECT intBondStatusId
								FROM tblMFCompanyPreference
								)
					ELSE NULL
					END
		END

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
			,strVendorRefNo
			,strWarehouseRefNo
			,strReceiptNumber
			,dtmReceiptDate
			,dtmLastMoveDate
			,dblTareWeight
			,dtmDueDate
			,ysnPickAllowed
			)
		SELECT @intLotId
			,@intBondStatusId
			,@strVendorRefNo
			,@strWarehouseRefNo
			,@strReceiptNumber
			,@dtmReceiptDate
			,@dtmCurrentDateTime
			,@dblTareWeight
			,@dtmDueDate
			,IsNULL(@ysnPickAllowed,1)
	END
	ELSE
	BEGIN
		SELECT TOP 1 @strVendorRefNo = Case When LI.strReceiptNumber=R.strReceiptNumber Then LI.strVendorRefNo else R.strVendorRefNo End
			,@strWarehouseRefNo = Case When LI.strReceiptNumber=R.strReceiptNumber Then LI.strWarehouseRefNo else R.strWarehouseRefNo End
			,@strReceiptNumber = Case When LI.strReceiptNumber=R.strReceiptNumber Then LI.strReceiptNumber else R.strReceiptNumber End
			,@dtmReceiptDate = Case When LI.strReceiptNumber=R.strReceiptNumber Then LI.dtmReceiptDate else R.dtmReceiptDate End
		FROM tblMFLotInventory LI
		JOIN tblICLot L ON L.intLotId = LI.intLotId
		JOIN tblICInventoryReceiptItemLot RL on RL.intLotId=L.intLotId
		JOIN tblICInventoryReceiptItem RI on RI.intInventoryReceiptItemId=RL.intInventoryReceiptItemId
		JOIN tblICInventoryReceipt R on R.intInventoryReceiptId=RI.intInventoryReceiptId
		WHERE L.strLotNumber = @strLotNumber
		ORDER BY R.intInventoryReceiptId DESC

		SELECT @strTransactionId = strTransactionId
		FROM tblICLot
		WHERE intLotId = @intLotId

		IF @strReceiptNumber IS NULL
		BEGIN
			SELECT @strVendorRefNo = strVendorRefNo
				,@strWarehouseRefNo = strWarehouseRefNo
				,@strReceiptNumber = strReceiptNumber
				,@dtmReceiptDate = dtmReceiptDate
			FROM tblICInventoryReceipt
			WHERE strReceiptNumber = @strTransactionId
		END

		SELECT @intInventoryReceiptId = intInventoryReceiptId
		FROM tblICInventoryReceipt
		WHERE strReceiptNumber = @strReceiptNumber

		SELECT TOP 1 @ysnBonded = FV.strValue
		FROM tblSMTabRow TR
		JOIN tblSMFieldValue FV ON TR.intTabRowId = FV.intTabRowId
		JOIN tblSMCustomTabDetail TD ON TD.intCustomTabDetailId = FV.intCustomTabDetailId
			AND LOWER(TD.strControlName) = 'Bonded'
		JOIN tblSMTransaction T ON T.intTransactionId = TR.intTransactionId
		JOIN tblSMScreen S ON S.intScreenId = T.intScreenId
			AND S.strNamespace = 'Inventory.view.InventoryReceipt'
		WHERE T.intRecordId = @intInventoryReceiptId

		IF @ysnBonded IS NULL
			SELECT @ysnBonded = 0

		SELECT @intBondStatusId = CASE 
				WHEN (
						@ysnRequireCustomerApproval = 1
						OR @ysnBonded = 1
						)
					THEN (
							SELECT intBondStatusId
							FROM tblMFCompanyPreference
							)
				ELSE NULL
				END

		UPDATE tblMFLotInventory
		SET strVendorRefNo = @strVendorRefNo
			,strWarehouseRefNo = @strWarehouseRefNo
			,strReceiptNumber = @strReceiptNumber
			,dtmReceiptDate = @dtmReceiptDate
			,intBondStatusId = CASE 
				WHEN @strTransactionId LIKE 'IR-%'
					THEN (
							CASE 
								WHEN @ysnBonded = 1
									THEN @intBondStatusId
								ELSE NULL
								END
							)
				ELSE intBondStatusId
				END
			,dtmLastMoveDate = @dtmCurrentDateTime
		WHERE intLotId = @intLotId
	END

	DELETE
	FROM tblMFLotTareWeight
	WHERE intInventoryReceiptId = @intInventoryReceiptId

	IF @ysnSendEDIOnRepost=1
	BEGIN
		Update tblMFEDI944
		Set ysnStatus=0
		WHERE intInventoryReceiptId = @intInventoryReceiptId
	END
END
