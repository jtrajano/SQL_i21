﻿GO
PRINT 'START TF tblTFScheduleFields'
GO

DECLARE @intScheduleColumnId INT

SELECT TOP 1 @intScheduleColumnId = intScheduleColumnId FROM tblTFScheduleFields

IF (@intScheduleColumnId IS NULL)
BEGIN
SET IDENTITY_INSERT [dbo].[tblTFScheduleFields] ON 

INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (1, 1, N'strProductCode', N'Product Code', N'', N'No', 0, 25, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (2, 2, N'strProductCode', N'Product Code', N'', N'No', 0, 52, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (3, 3, N'strProductCode', N'Product Code', N'', N'No', 0, 79, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (4, 4, N'strProductCode', N'Product Code', N'', N'No', 0, 106, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (10, 2, N'strSupplierName', N'Supplier', N'', N'No', 0, 1976, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (11, 3, N'strSupplierName', N'Supplier', N'', N'No', 0, 1979, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (12, 1, N'strSupplierName', N'Supplier', N'', N'No', 0, 1972, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (13, 1, N'pxrpt_cus_name', N'Customer', N'', N'No', 0, 7, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (14, 1, N'pxrpt_sls_trans_gals', N'Total', N'', N'No', 0, 18, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (15, 1, N'dtmDate', N'Date', N'', N'No', 0, 1974, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (17, 1, N'pxrpt_itm_desc', N'Description', N'', N'No', 0, 5, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (18, 1, N'pxrpt_itm_no', N'Item Number', N'', N'No', 0, 3, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (20, 3, N'pxrpt_sls_trans_gals', N'Supplier Total', N'', N'No', 0, 72, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (21, 2, N'pxrpt_sls_trans_gals', N'Supplier Total', N'', N'No', 0, 34, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (22, 2, N'pxrpt_cus_name', N'Customer', N'', N'No', 0, 34, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (23, 3, N'dtmDate', N'Date', N'', N'No', 0, 1981, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (24, 6, N'strProductCode', N'Product Code', N'', N'No', 0, 160, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (25, 6, N'pxrpt_cus_name', N'Customer', N'', N'No', 0, 142, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (26, 5, N'strProductCode', N'Product Code', N'', N'No', 0, 133, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (27, 5, N'pxrpt_cus_name', N'Customer', N'', N'No', 0, 115, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (28, 4, N'pxrpt_cus_name', N'Customer', N'', N'No', 0, 88, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (29, 10, N'strProductCode', N'Product Code', N'', N'No', 0, 268, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (30, 10, N'pxrpt_cus_name', N'Customer Name', N'', N'No', 0, 250, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (31, 11, N'strProductCode', N'Product Code', N'', N'No', 0, 295, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (32, 13, N'strProductCode', N'Product Code', N'', N'No', 0, 322, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (33, 14, N'strProductCode', N'Product Code', N'', N'No', 0, 349, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (34, 2, N'dtmDate', N'Date', N'', N'', 0, 0, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (35, 4, N'pxrpt_sls_trans_gals', N'Total', N'', N'No', 0, 0, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (36, 5, N'pxrpt_sls_trans_gals', N'Total', N'', N'No', 0, 0, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (37, 6, N'pxrpt_sls_trans_gals', N'Total', N'', N'', 0, 0, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (38, 7, N'strProductCode', N'Product Code', N'', N'No', 0, 187, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (39, 7, N'pxrpt_cus_name', N'Customer Name', N'', N'No', 0, 169, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (40, 7, N'pxrpt_sls_trans_gals', N'Total', N'', N'No', 0, 180, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (41, 8, N'strProductCode', N'Product Code', N'', N'No', 0, 214, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (42, 8, N'pxrpt_cus_name', N'Customer Name', N'', N'No', 0, 196, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (43, 8, N'pxrpt_sls_trans_gals', N'Total', N'', N'', 0, 0, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (44, 9, N'strProductCode', N'Product Code', N'', N'No', 0, 241, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (45, 9, N'pxrpt_cus_name', N'Customer Name', N'', N'No', 0, 223, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (46, 9, N'pxrpt_itm_desc', N'Description', N'', N'No', 0, 221, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (47, 9, N'pxrpt_sls_trans_gals', N'Total', N'', N'', 0, 0, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (48, 10, N'pxrpt_cus_state', N'Customer State', N'', N'No', 0, 252, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (49, 10, N'pxrpt_sls_trans_gals', N'Total', N'', N'No', 0, 0, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (50, 11, N'pxrpt_cus_name', N'Customer Name', N'', N'No', 0, 277, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (51, 11, N'pxrpt_cus_state', N'Customer State', N'', N'No', 0, 279, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (52, 11, N'pxrpt_sls_trans_gals', N'Total', N'', N'', 0, 0, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (53, 13, N'pxrpt_cus_name', N'Customer Name', N'', N'No', 0, 304, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (54, 13, N'pxrpt_sls_trans_gals', N'Total', N'', N'No', 0, 315, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (55, 14, N'pxrpt_cus_name', N'Customer Name', N'', N'No', 0, 331, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (56, 14, N'pxrpt_sls_trans_gals', N'Total', N'', N'No', 0, 342, 0)
INSERT [dbo].[tblTFScheduleFields] ([intScheduleColumnId], [intReportingComponentDetailId], [strColumn], [strCaption], [strFormat], [strFooter], [intWidth], [intScheduleFieldTemplateId], [intConcurrencyId]) VALUES (1019, 2, N'pxrpt_vnd_state', N'Vendor State', N'', N'No', 0, 40, 0)
SET IDENTITY_INSERT [dbo].[tblTFScheduleFields] OFF
END

GO
PRINT 'END TF tblTFScheduleFields'
GO