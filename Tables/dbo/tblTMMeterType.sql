CREATE TABLE [dbo].[tblTMMeterType] (
    [intConcurrencyId]    INT             DEFAULT ((1)) NOT NULL,
    [intMeterTypeId]      INT             IDENTITY (1, 1) NOT NULL,
    [strMeterType]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [dblConversionFactor] NUMERIC (18, 8) DEFAULT ((0)) NULL,
    [ysnDefault]          BIT             DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblTMMeterType] PRIMARY KEY CLUSTERED ([intMeterTypeId] ASC),
    CONSTRAINT [IX_tblTMMeterType] UNIQUE NONCLUSTERED ([strMeterType] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMMeterType',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMMeterType',
    @level2type = N'COLUMN',
    @level2name = N'intMeterTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Meter Typed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMMeterType',
    @level2type = N'COLUMN',
    @level2name = N'strMeterType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Conversion Factor',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMMeterType',
    @level2type = N'COLUMN',
    @level2name = N'dblConversionFactor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indicates if default data',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblTMMeterType',
    @level2type = N'COLUMN',
    @level2name = N'ysnDefault'