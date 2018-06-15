GO
	PRINT N'BEGIN INSERT DEFAULT CONTROL'
GO
	DECLARE @entityCustomerId INT
	SELECT @entityCustomerId = intScreenId FROM tblSMScreen WHERE strNamespace = 'AccountsReceivable.view.EntityCustomer' AND strScreenName = 'My Company (Portal)'

	IF @entityCustomerId IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMControl WHERE intScreenId = @entityCustomerId AND strControlId = 'btnDeleteLoc') 
		BEGIN
			INSERT [dbo].[tblSMControl] ([intScreenId],[strControlId],[strControlName],[strContainer],[strControlType])
			VALUES (@entityCustomerId, N'btnDeleteLoc', N'Remove', N'', 'Button')
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
GO
	PRINT N'END INSERT DEFAULT CONTROL'
GO