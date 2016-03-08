GO
PRINT 'START TF tblTFValidProductCode'
GO

DECLARE @intValidProductCodeId INT

SELECT TOP 1 @intValidProductCodeId = intValidProductCodeId FROM tblTFValidProductCode

IF (@intValidProductCodeId IS NULL)
BEGIN
SET IDENTITY_INSERT [dbo].[tblTFValidProductCode] ON 
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1275, 3, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1276, 4, NULL, N'124', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1277, 5, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1278, 5, NULL, N'124', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1279, 6, NULL, N'124', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1280, 6, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1281, 7, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1282, 8, NULL, N'091', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1283, 12, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1284, 13, NULL, N'125', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1285, 14, NULL, N'130', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1286, 3, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1288, 2, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1292, 16, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1294, 20, NULL, N'073', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1295, 17, NULL, N'124', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1296, 19, NULL, N'D00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1297, 21, NULL, N'D11', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1298, 18, NULL, N'D00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1299, 22, NULL, N'073', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1300, 23, NULL, N'D11', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1301, 24, NULL, N'054', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1302, 25, NULL, N'130', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1303, 26, NULL, N'224', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1304, 27, NULL, N'130', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1305, 28, NULL, N'125', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1306, 29, NULL, N'130', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1307, 10, NULL, N'D00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1308, 9, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1322, 1, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1323, 1, NULL, N'D11', N'', 1)
SET IDENTITY_INSERT [dbo].[tblTFValidProductCode] OFF
END

GO
PRINT 'END TF tblTFValidProductCode'
GO