GO
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblTFCompanyPreference] where intCompanyPreferenceId = 1)

BEGIN
SET IDENTITY_INSERT [dbo].[tblTFCompanyPreference] ON 
INSERT [dbo].[tblTFCompanyPreference] ([intCompanyPreferenceId], [strCompanyName], [strTaxAddress], [strCity], [strState], [strZipCode], [strContactName], [strContactPhone], [strContactEmail], [strFilingFolder], [intConcurrencyId]) VALUES (2, N'iRely Grain and Ag Co                             ', N'', N'Edison', N'OH', N'43320', N'', N'', N'', N'C:\', 10)
SET IDENTITY_INSERT [dbo].[tblTFCompanyPreference] OFF
END