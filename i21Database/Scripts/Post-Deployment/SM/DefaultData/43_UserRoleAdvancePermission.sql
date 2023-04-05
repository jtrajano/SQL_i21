PRINT N'BEGIN---> INSERT USER ROLE ADVANCE PERMISSION FOR DEFAULT RECORDS'

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

	DECLARE @SMModuleId INT
	SELECT @SMModuleId = intModuleId FROM tblSMModule WHERE strModule = 'System Manager' AND strApplicationName = 'i21'
	IF ISNULL(@SMModuleId, 0) <> 0 AND NOT EXISTS(SELECT TOP 1 1 FROM tblSMAdvancePermission WHERE intModuleId = @SMModuleId AND strDescription = N'Allow Power BI reports to be edited.')
		INSERT INTO tblSMAdvancePermission(intModuleId,strDescription, intConcurrencyId)
		VALUES(@SMModuleId, N'Allow Power BI reports to be edited.', 1)


	--INSERT NEW HERE USING THE ABOVE FORMAT--

PRINT N'END---> INSERT USER ROLE ADVANCE PERMISSION FOR DEFAULT RECORDS'
