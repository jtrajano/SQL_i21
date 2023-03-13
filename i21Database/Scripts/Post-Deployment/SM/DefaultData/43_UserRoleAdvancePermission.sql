GO
	PRINT N'BEGIN---> INSERT USER ROLE ADVANCE PERMISSION FOR DEFAULT RECORDS'
GO
	DECLARE @ContractModuleId INT
	DECLARE @EditOnUnconfirmed NVARCHAR(1000) = N'Allow a Contract Sequence to be edited when the Status is Unconfirmed.'
	DECLARE @ContractAdvanceId INT

	SELECT @ContractModuleId = intModuleId FROM tblSMModule WHERE strModule = 'Contract Management' AND strApplicationName = 'i21'
	
	SELECT @ContractAdvanceId = intAdvancePermissionId FROM tblSMAdvancePermission WHERE intModuleId = @ContractModuleId AND strDescription = @EditOnUnconfirmed
	IF NOT ISNULL(@ContractAdvanceId, 0) <> 0
	BEGIN
		INSERT INTO tblSMAdvancePermission(
			intModuleId
			, strDescription
			, intConcurrencyId
		)
		VALUES(
		@ContractModuleId
		, @EditOnUnconfirmed
		, 1)
	END
	ELSE
	BEGIN
		UPDATE tblSMAdvancePermission SET strDescription = @EditOnUnconfirmed
		WHERE intAdvancePermissionId = @ContractAdvanceId
	END

GO

	DECLARE @InventoryModuleId INT
	DECLARE @OverrideItemNo NVARCHAR(1000) = N'Allow user to override item no. in item screen when Item No. Generation is Active'
	DECLARE @InventoryAdvanceId INT

	SELECT @InventoryModuleId = intModuleId FROM tblSMModule WHERE strModule = 'Inventory' AND strApplicationName = 'i21'
	
	SELECT @InventoryAdvanceId = intAdvancePermissionId FROM tblSMAdvancePermission WHERE intModuleId = @InventoryModuleId AND strDescription = @OverrideItemNo
	IF NOT ISNULL(@InventoryAdvanceId, 0) <> 0
	BEGIN
		INSERT INTO tblSMAdvancePermission(
			intModuleId
			, strDescription
			, intConcurrencyId
		)
		VALUES(
		@InventoryModuleId
		, @OverrideItemNo
		, 1)
	END
	ELSE
	BEGIN
		UPDATE tblSMAdvancePermission SET strDescription = @OverrideItemNo
		WHERE intAdvancePermissionId = @InventoryAdvanceId
	END
	
	--INSERT NEW HERE WITH THE ABOVE FORMAT--
GO
	PRINT N'END---> INSERT USER ROLE ADVANCE PERMISSION FOR DEFAULT RECORDS'
GO