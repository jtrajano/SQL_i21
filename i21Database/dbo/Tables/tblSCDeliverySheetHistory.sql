CREATE TABLE [dbo].[tblSCDeliverySheetHistory]
(
	[intDeliverySheetHistoryId] INT NOT NULL IDENTITY, 
    [intDeliverySheetId] INT NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [intDeliverySheetSplitId] INT NOT NULL, 
    [dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
    [dblQuantity] DECIMAL(38, 20) NOT NULL, 
	[intStorageScheduleTypeId] INT NULL,
	[dtmDeliverySheetHistoryDate] DATE NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSCDeliverySheetHistory_intDeliverySheetHistoryId] PRIMARY KEY ([intDeliverySheetHistoryId]) ,
	CONSTRAINT [FK_tblSCDeliverySheetHistory_tblSCDeliverySheet_intDeliverySheetId] FOREIGN KEY ([intDeliverySheetId]) REFERENCES [tblSCDeliverySheet]([intDeliverySheetId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSCDeliverySheetHistory_tblGRStorageType_intStorageScheduleTypeId] FOREIGN KEY ([intStorageScheduleTypeId]) REFERENCES [tblGRStorageType]([intStorageScheduleTypeId]),
	CONSTRAINT [FK_tblSCDeliverySheetHistory_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetHistory',
    @level2type = N'COLUMN',
    @level2name = N'intDeliverySheetHistoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Sheet Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetHistory',
    @level2type = N'COLUMN',
    @level2name = N'intDeliverySheetId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Sheet Split Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetHistory',
    @level2type = N'COLUMN',
    @level2name = N'intDeliverySheetSplitId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetHistory',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblSplitPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCDeliverySheetHistory',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'