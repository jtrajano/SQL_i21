CREATE TABLE [dbo].[tblTMLeaseMinimumUse] (
    [intLeaseMinimumUseID] INT             IDENTITY (1, 1) NOT NULL,
    [dblSiteCapacity]      NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [dblMinimumUsage]      NUMERIC (18, 6) DEFAULT 0 NOT NULL,
    [intConcurrencyId]     INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblTMLeaseMinimumUse] PRIMARY KEY CLUSTERED ([intLeaseMinimumUseID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseMinimumUse',
    @level2type = N'COLUMN',
    @level2name = N'intLeaseMinimumUseID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Site Capacity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseMinimumUse',
    @level2type = N'COLUMN',
    @level2name = N'dblSiteCapacity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Minimum Usage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseMinimumUse',
    @level2type = N'COLUMN',
    @level2name = N'dblMinimumUsage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMLeaseMinimumUse',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'