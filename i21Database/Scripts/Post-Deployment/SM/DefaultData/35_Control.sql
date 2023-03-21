GO
	PRINT N'BEGIN INSERT DEFAULT CONTROL'
GO
	DECLARE @entityCustomerId INT
	SELECT @entityCustomerId = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntityCustomer'

	IF @entityCustomerId IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMControl WHERE intScreenId = @entityCustomerId AND strControlId = 'btnDeleteLoc') 
		BEGIN
			INSERT [dbo].[tblSMControl] ([intScreenId],[strControlId],[strControlName],[strContainer],[strControlType])
			VALUES (@entityCustomerId, N'btnDeleteLoc', N'Delete Loc', N'', 'Button')
		END
		ELSE
		BEGIN
			UPDATE [tblSMControl] SET [strControlName] = 'Delete Loc' WHERE intScreenId = @entityCustomerId AND strControlId = 'btnDeleteLoc'
		END
	END

	DECLARE @entityVendorId INT
	SELECT @entityVendorId = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsPayable.view.EntityVendor' AND strScreenName = 'Vendors'

	IF @entityVendorId IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMControl WHERE intScreenId = @entityVendorId AND strControlId = 'txtVendorAccountNo') 
		BEGIN
			INSERT [dbo].[tblSMControl] ([intScreenId],[strControlId],[strControlName],[strContainer],[strControlType])
			VALUES (@entityVendorId, N'txtVendorAccountNo', N'Vendor Account No', N'', 'Text')
		END
	END

	DECLARE @intSampleScreenId INT
	SELECT @intSampleScreenId = intScreenId FROM tblSMScreen WHERE strNamespace = 'Quality.view.QualitySample' AND strScreenName = 'Sample Entry'

	IF @intSampleScreenId IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMControl WHERE strControlId = 'tabcfgAuction') 
		BEGIN
			INSERT [dbo].[tblSMControl] ([intScreenId],[strControlId],[strControlName],[strContainer],[strControlType])
			VALUES (@intSampleScreenId, N'tabcfgAuction', N'Auction', N'', 'Tab')
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMControl WHERE strControlId = 'tabcfgInitialBuy') 
		BEGIN
			INSERT [dbo].[tblSMControl] ([intScreenId],[strControlId],[strControlName],[strContainer],[strControlType])
			VALUES (@intSampleScreenId, N'tabcfgInitialBuy', N'Initial Buy', N'', 'Tab')
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMControl WHERE strControlId = 'tabcfgTestDetails') 
		BEGIN
			INSERT [dbo].[tblSMControl] ([intScreenId],[strControlId],[strControlName],[strContainer],[strControlType])
			VALUES (@intSampleScreenId, N'tabcfgTestDetails', N'Test Details', N'', 'Tab')
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMControl WHERE strControlId = 'tabcfgAllocation') 
		BEGIN
			INSERT [dbo].[tblSMControl] ([intScreenId],[strControlId],[strControlName],[strContainer],[strControlType])
			VALUES (@intSampleScreenId, N'tabcfgAllocation', N'Allocation', N'', 'Tab')
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMControl WHERE strControlId = 'tabcfgAssignContracts') 
		BEGIN
			INSERT [dbo].[tblSMControl] ([intScreenId],[strControlId],[strControlName],[strContainer],[strControlType])
			VALUES (@intSampleScreenId, N'tabcfgAssignContracts', N'Assign Contracts', N'', 'Tab')
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMControl WHERE strControlId = 'tabcfgCuppingSessions') 
		BEGIN
			INSERT [dbo].[tblSMControl] ([intScreenId],[strControlId],[strControlName],[strContainer],[strControlType])
			VALUES (@intSampleScreenId, N'tabcfgCuppingSessions', N'Cupping Session', N'', 'Tab')
		END
	END
GO
	PRINT N'END INSERT DEFAULT CONTROL'
GO