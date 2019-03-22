CREATE TABLE [dbo].[tblTMPossessionType] (
    [intConcurrencyId]    INT           DEFAULT 1 NOT NULL,
    [intPossessionTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [strPossessionType]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblTMPossessionType] PRIMARY KEY CLUSTERED ([intPossessionTypeID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPossessionType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPossessionType',
    @level2type = N'COLUMN',
    @level2name = N'intPossessionTypeID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Possesion Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMPossessionType',
    @level2type = N'COLUMN',
    @level2name = N'strPossessionType'