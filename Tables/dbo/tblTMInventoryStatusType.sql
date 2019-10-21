CREATE TABLE [dbo].[tblTMInventoryStatusType] (
    [intConcurrencyId]         INT           DEFAULT ((1)) NOT NULL,
    [intInventoryStatusTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [strInventoryStatusType]   NVARCHAR (70) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]               BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMInventoryStatusType] PRIMARY KEY CLUSTERED ([intInventoryStatusTypeId] ASC),
    CONSTRAINT [IX_tblTMInventoryStatusType] UNIQUE NONCLUSTERED ([strInventoryStatusType] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMInventoryStatusType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMInventoryStatusType',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryStatusTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Status Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMInventoryStatusType',
    @level2type = N'COLUMN',
    @level2name = N'strInventoryStatusType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMInventoryStatusType',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'