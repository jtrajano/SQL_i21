CREATE TABLE [dbo].[tblTMEventType] (
    [intConcurrencyId] INT            DEFAULT ((1)) NOT NULL,
    [intEventTypeID]   INT            IDENTITY (1, 1) NOT NULL,
    [strEventType]     NVARCHAR (50)  COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]       BIT            DEFAULT ((0)) NOT NULL,
    [strDescription]   NVARCHAR (200) COLLATE Latin1_General_CI_AS CONSTRAINT [DEF_tblTMEventType_strDescription] DEFAULT ('') NULL,
    CONSTRAINT [PK_tblTMEventType] PRIMARY KEY CLUSTERED ([intEventTypeID] ASC),
    CONSTRAINT [IX_tblTMEventType] UNIQUE NONCLUSTERED ([strEventType] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEventType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEventType',
    @level2type = N'COLUMN',
    @level2name = N'intEventTypeID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Event Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEventType',
    @level2type = N'COLUMN',
    @level2name = N'strEventType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEventType',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMEventType',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'