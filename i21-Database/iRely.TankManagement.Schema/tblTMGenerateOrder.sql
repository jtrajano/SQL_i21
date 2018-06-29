CREATE TABLE [dbo].[tblTMGenerateOrder] (
   [intGenerateOrderId] [int] IDENTITY(1,1) NOT NULL,
	[intUserId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblTMGenerateOrder_intConcurrencyId]  DEFAULT ((1)),
	[strPendingOption] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL CONSTRAINT [DF_tblTMGenerateOrder_strPendingOption]  DEFAULT (N'Include'),
	[strFillMethods] [nvarchar](max) COLLATE Latin1_General_CI_AS   NULL,
	[strItems] [nvarchar](max) COLLATE Latin1_General_CI_AS   NULL,
	[strLocations] [nvarchar](max) COLLATE Latin1_General_CI_AS   NULL,
	[strRoutes] [nvarchar](max) COLLATE Latin1_General_CI_AS   NULL,
	[strDrivers] [nvarchar](max) COLLATE Latin1_General_CI_AS   NULL,
	[strClocks] [nvarchar](max) COLLATE Latin1_General_CI_AS   NULL,
	[dblPercentFull] [numeric](18, 6) NULL,
	[intNextDegreeDay] [int] NULL,
	[dtmNextJulianDate] [datetime] NULL,
	[strOnHold] [nvarchar](10) COLLATE Latin1_General_CI_AS   NOT NULL CONSTRAINT [DF_tblTMGenerateOrder_strOnHold]  DEFAULT (N'Exclude'),
	[strPastDue] [nvarchar](10) COLLATE Latin1_General_CI_AS   NOT NULL CONSTRAINT [DF_tblTMGenerateOrder_strPastDue]  DEFAULT (N'Exclude'),
	[strOverCreditLimit] [nvarchar](10) COLLATE Latin1_General_CI_AS   NOT NULL CONSTRAINT [DF_tblTMGenerateOrder_strOverCreditLimit]  DEFAULT (N'Include'),
	[strBudgetCustomers] [nvarchar](10) COLLATE Latin1_General_CI_AS   NOT NULL CONSTRAINT [DF_tblTMGenerateOrder_strBudgetCustomers]  DEFAULT (N'Include'),
    CONSTRAINT [PK_tblTMGenerateOrder] PRIMARY KEY CLUSTERED ([intGenerateOrderId] ASC),
	CONSTRAINT [FK_tblTMGenerateOrder_tblSMUserSecurity] FOREIGN KEY([intUserId]) REFERENCES [dbo].[tblSMUserSecurity] ([intEntityId])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'intGenerateOrderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'intUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pending Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strPendingOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fill Methods',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strFillMethods'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Items',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strItems'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Locations',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strLocations'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Routes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strRoutes'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Drivers',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strDrivers'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Clocks',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strClocks'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percent Full',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'dblPercentFull'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Next Degree Day',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'intNextDegreeDay'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Next Julian Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'dtmNextJulianDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'On Hold',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strOnHold'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Past Due',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strPastDue'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Over Credit Limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strOverCreditLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Budget Customers',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateOrder',
    @level2type = N'COLUMN',
    @level2name = N'strBudgetCustomers'