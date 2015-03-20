CREATE TABLE [dbo].[tblTMEventAutomation] (
    [intConcurrencyId]     INT           DEFAULT 1 NOT NULL,
    [intEventAutomationID] INT           IDENTITY (1, 1) NOT NULL,
    [intEventTypeID]       INT           DEFAULT 0 NULL,
    [strProduct]           NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMEventAutomation] PRIMARY KEY CLUSTERED ([intEventAutomationID] ASC),
    CONSTRAINT [FK_tblTMEventAutomation_tblTMEventType] FOREIGN KEY ([intEventTypeID]) REFERENCES [dbo].[tblTMEventType] ([intEventTypeID]) ON DELETE SET NULL
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEventAutomation',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEventAutomation',
    @level2type = N'COLUMN',
    @level2name = N'intEventAutomationID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Event Type ID',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEventAutomation',
    @level2type = N'COLUMN',
    @level2name = N'intEventTypeID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEventAutomation',
    @level2type = N'COLUMN',
    @level2name = N'strProduct'