print('/*******************  BEGIN - INSERT CUSTOM CONTROLS FOR QUALITY SAMPLE ENTRY SCREEN *******************/')
GO
    DECLARE @intSampleScreenId INT
	SELECT @intSampleScreenId = intScreenId FROM tblSMScreen WHERE strNamespace = 'Quality.view.QualitySample'

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
print('/*******************  END - INSERT CUSTOM CONTROLS FOR QUALITY SAMPLE ENTRY SCREEN *******************/')