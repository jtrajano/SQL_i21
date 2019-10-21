CREATE TABLE [dbo].[tblTMManufacturer] (
    [intConcurrencyId]   INT           DEFAULT 1 NOT NULL,
    [intManufacturerId] INT           IDENTITY (1, 1) NOT NULL,
    [strManufacturerId]   NVARCHAR (50) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
	[strManufacturerName]   NVARCHAR (100) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [ysnDefault]         BIT           DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMManufacturer] PRIMARY KEY CLUSTERED ([intManufacturerId] ASC),
    CONSTRAINT [UQ_tblTMManufacturer_strManufacturerId] UNIQUE NONCLUSTERED ([strManufacturerId] ASC)
);


GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'intManufacturerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manufacturer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMManufacturer',
    @level2type = N'COLUMN',
    @level2name = 'strManufacturerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default flag',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manufacturer Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strManufacturerName'