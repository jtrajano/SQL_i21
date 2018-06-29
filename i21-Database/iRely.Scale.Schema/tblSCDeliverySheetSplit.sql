CREATE TABLE [dbo].[tblSCDeliverySheetSplit]
(
	[intDeliverySheetSplitId] INT NOT NULL IDENTITY, 
    [intDeliverySheetId] INT NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
	[intStorageScheduleTypeId] INT NULL,
    [strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[intStorageScheduleRuleId] INT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSCDeliverySheetSplit_intDeliverySheetSplitId] PRIMARY KEY ([intDeliverySheetSplitId]) ,
	CONSTRAINT [FK_tblSCDeliverySheetSplit_tblSCDeliverySheet_intDeliverySheetId] FOREIGN KEY ([intDeliverySheetId]) REFERENCES [tblSCDeliverySheet]([intDeliverySheetId]),
	CONSTRAINT [FK_tblSCDeliverySheetSplit_tblGRStorageType_intStorageScheduleTypeId] FOREIGN KEY ([intStorageScheduleTypeId]) REFERENCES [tblGRStorageType]([intStorageScheduleTypeId]),
	CONSTRAINT [FK_tblSCDeliverySheetSplit_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblSCDeliverySheetSplit_tblGRStorageScheduleRule_intStorageScheduleRuleId] FOREIGN KEY ([intStorageScheduleRuleId]) REFERENCES [dbo].[tblGRStorageScheduleRule] ([intStorageScheduleRuleId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetSplit',
    @level2type = N'COLUMN',
    @level2name = N'intDeliverySheetSplitId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetSplit',
    @level2type = N'COLUMN',
    @level2name = N'intDeliverySheetId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetSplit',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetSplit',
    @level2type = N'COLUMN',
    @level2name = N'dblSplitPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Distribution Option',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetSplit',
    @level2type = N'COLUMN',
    @level2name = 'strDistributionOption'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetSplit',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'