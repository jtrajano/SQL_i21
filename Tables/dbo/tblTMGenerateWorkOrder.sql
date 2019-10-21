CREATE TABLE [dbo].[tblTMGenerateWorkOrder] (
   [intGenerateWorkOrderId] [int] IDENTITY(1,1) NOT NULL,
	[intUserId] [int] NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblTMGenerateWorkOrder_intConcurrencyId]  DEFAULT ((1)),
    [dtmScheduledDate] DATETIME NULL, 
    [intCategoryId] INT NULL, 
    [strToDoItemIds] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS  NULL, 
    [strFilterMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT (N'Last Event') , 
    [intDeviceTypeId] INT NULL, 
    [intEventTypeId] INT NULL, 
    [dtmBeforeLastDate] DATETIME NULL, 
    [strDeviceOwnership] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [strRouteIds] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strLocationIds] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblTMGenerateWorkOrder] PRIMARY KEY CLUSTERED ([intGenerateWorkOrderId] ASC),
	CONSTRAINT [FK_tblTMGenerateWorkOrder_tblSMUserSecurity] FOREIGN KEY([intUserId]) REFERENCES [dbo].[tblSMUserSecurity] ([intEntityId])
);


GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intGenerateWorkOrderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scheduled Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'dtmScheduledDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Category',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = 'intCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Work To do Items',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'strToDoItemIds'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Filter Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'strFilterMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intDeviceTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Event Type Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'intEventTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Before Last Event Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'dtmBeforeLastDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Device Ownership',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = N'strDeviceOwnership'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Route',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMGenerateWorkOrder',
    @level2type = N'COLUMN',
    @level2name = 'strRouteIds'