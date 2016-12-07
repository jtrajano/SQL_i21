
GO
PRINT 'START TF tblTFCompanyPreference'
GO
DECLARE @intCompanyPreferenceId INT
SELECT TOP 1 @intCompanyPreferenceId = intCompanyPreferenceId FROM tblTFCompanyPreference

IF(@intCompanyPreferenceId IS NULL)
	BEGIN
		INSERT [dbo].[tblTFCompanyPreference] ([strCompanyName], [strTaxAddress], [strCity], [strState], [strZipCode], [strContactName], [strContactPhone], [strContactEmail], [strFilingFolder], [intConcurrencyId]) 
		VALUES (N'iRely Test Company', N'', N'Edison', N'OH', N'43320', N'', N'', N'', N'C:\', 10)
	END
GO
PRINT 'END TF tblTFCompanyPreference'
GO