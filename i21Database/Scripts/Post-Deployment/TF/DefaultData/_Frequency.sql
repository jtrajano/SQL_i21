GO
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblTFFrequency] where intFrequencyId = 1)

BEGIN
SET IDENTITY_INSERT [dbo].[tblTFFrequency] ON 
INSERT [dbo].[tblTFFrequency] ([intFrequencyId], [strFrequency], [intConcurrencyId]) VALUES (1, N'Weekly', 1)
INSERT [dbo].[tblTFFrequency] ([intFrequencyId], [strFrequency], [intConcurrencyId]) VALUES (2, N'Monthly', 1)
INSERT [dbo].[tblTFFrequency] ([intFrequencyId], [strFrequency], [intConcurrencyId]) VALUES (3, N'Daily', 1)
INSERT [dbo].[tblTFFrequency] ([intFrequencyId], [strFrequency], [intConcurrencyId]) VALUES (4, N'Yearly', 1)
SET IDENTITY_INSERT [dbo].[tblTFFrequency] OFF
END