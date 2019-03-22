CREATE TABLE [dbo].[tblSCTicketHistory]
(
	[intTicketHistoryId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [intTicketSplitId] INT NULL, 
    [dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
    [dblQuantity] DECIMAL(38, 20) NOT NULL, 
	[intStorageScheduleTypeId] INT NULL,
	[dtmTicketHistoryDate] DATE NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSCTicketHistory_intTicketIdd] PRIMARY KEY ([intTicketHistoryId]) ,
	CONSTRAINT [FK_tblSCTicketHistory_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSCTicketHistory_tblGRStorageType_intStorageScheduleTypeId] FOREIGN KEY ([intStorageScheduleTypeId]) REFERENCES [tblGRStorageType]([intStorageScheduleTypeId]),
	CONSTRAINT [FK_tblSCTicketHistory_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Column',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketHistory',
    @level2type = N'COLUMN',
    @level2name = N'intTicketHistoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Ticket Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketHistory',
    @level2type = N'COLUMN',
    @level2name = N'intTicketId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scale Ticket Split Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketHistory',
    @level2type = N'COLUMN',
    @level2name = N'intTicketSplitId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketHistory',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Split Percent',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketHistory',
    @level2type = N'COLUMN',
    @level2name = N'dblSplitPercent'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSCTicketHistory',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'