GO
PRINT 'START TF tblTFReportingComponentConfiguration'
GO

DECLARE @intReportingComponentConfigurationId INT

SELECT TOP 1 @intReportingComponentConfigurationId = intReportingComponentConfigurationId FROM tblTFReportingComponentConfiguration

IF (@intReportingComponentConfigurationId IS NULL)
BEGIN
		SET IDENTITY_INSERT [dbo].[tblTFReportingComponentConfiguration] ON 
		INSERT [dbo].[tblTFReportingComponentConfiguration] ([intReportingComponentConfigurationId], [intReportingComponentDetailId], [strConfigurationName], [intReportingComponentConfigurationValueId], [strValue], [strCondition], [strType], [intConcurrencyId]) VALUES (15, 1, N' Licensed gasoline distributor deduction - Multiply Line 4 by', 1, N'0.01', N'', N'', 0)
		INSERT [dbo].[tblTFReportingComponentConfiguration] ([intReportingComponentConfigurationId], [intReportingComponentDetailId], [strConfigurationName], [intReportingComponentConfigurationValueId], [strValue], [strCondition], [strType], [intConcurrencyId]) VALUES (19, 1, N'Gasoline tax due - Multiply Line 6 by $', 2, N'0.18', N'', N'', 0)
		INSERT [dbo].[tblTFReportingComponentConfiguration] ([intReportingComponentConfigurationId], [intReportingComponentDetailId], [strConfigurationName], [intReportingComponentConfigurationValueId], [strValue], [strCondition], [strType], [intConcurrencyId]) VALUES (20, 1, N'Oil inspection fees due - Multiply Line 4 by', 3, N'100', N'', N'', 0)
		INSERT [dbo].[tblTFReportingComponentConfiguration] ([intReportingComponentConfigurationId], [intReportingComponentDetailId], [strConfigurationName], [intReportingComponentConfigurationValueId], [strValue], [strCondition], [strType], [intConcurrencyId]) VALUES (28, 1, N'LIcence Number', 0, N'0', N'', N'', 0)
		SET IDENTITY_INSERT [dbo].[tblTFReportingComponentConfiguration] OFF
END

GO
PRINT 'END TF tblTFReportingComponentConfiguration'
GO