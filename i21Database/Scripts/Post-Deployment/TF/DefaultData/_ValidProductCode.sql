GO
PRINT 'START TF tblTFValidProductCode'
GO

DECLARE @intValidProductCodeId INT
DELETE FROM tblTFValidProductCode
SELECT TOP 1 @intValidProductCodeId = intValidProductCodeId FROM tblTFValidProductCode

IF (@intValidProductCodeId IS NULL)
BEGIN
SET IDENTITY_INSERT [dbo].[tblTFValidProductCode] ON 

INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1326, 1, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1327, 2, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1328, 3, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1329, 4, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1330, 5, NULL, N'072', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1331, 6, NULL, N'228', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1332, 7, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1333, 8, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1334, 9, NULL, N'E11', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1335, 10, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1336, 11, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1337, 12, NULL, N'D00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1338, 13, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1339, 14, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1340, 15, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1341, 16, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1342, 17, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1343, 18, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1344, 19, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1345, 20, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1346, 21, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1347, 22, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1348, 23, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1349, 24, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1350, 25, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1351, 26, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1352, 27, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1353, 28, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1354, 29, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1360, 30, NULL, N'E00', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1361, 37, NULL, N'065', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1362, 38, NULL, N'142', N'', 1)
INSERT [dbo].[tblTFValidProductCode] ([intValidProductCodeId], [intReportingComponentDetailId], [intProductCode], [strProductCode], [strFilter], [intConcurrencyId]) VALUES (1363, 39, NULL, N'E00', N'', 1)


SET IDENTITY_INSERT [dbo].[tblTFValidProductCode] OFF
END

GO
PRINT 'END TF tblTFValidProductCode'
GO