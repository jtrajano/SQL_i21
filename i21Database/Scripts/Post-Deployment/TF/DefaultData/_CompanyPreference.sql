GO
DECLARE @intCompanyPreferenceId INT
SELECT TOP 1 @intCompanyPreferenceId = intCompanyPreferenceId FROM tblTFCompanyPreference

IF(@intCompanyPreferenceId IS NULL)
BEGIN
SET IDENTITY_INSERT [dbo].[tblTFCompanyPreference] ON 
INSERT [dbo].[tblTFCompanyPreference] ([intCompanyPreferenceId], [strCompanyName], [strTaxAddress], [strCity], [strState], [strZipCode], [strContactName], [strContactPhone], [strContactEmail], [strFilingFolder], [intConcurrencyId]) VALUES (1, N'iRely Grain and Ag Co                             ', N'', N'Edison', N'OH', N'43320', N'', N'', N'', N'C:\', 10)
SET IDENTITY_INSERT [dbo].[tblTFCompanyPreference] OFF
END