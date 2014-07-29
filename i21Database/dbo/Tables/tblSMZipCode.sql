CREATE TABLE [dbo].[tblSMZipCode] (
    [intZipCodeID]     INT             IDENTITY (1, 1) NOT NULL,
    [strZipCode]       NVARCHAR (12)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strState]         NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strCity]          NVARCHAR (50)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [strCountry]       NVARCHAR (25)   COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL,
    [dblLatitude]      NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [dblLongitude]     NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [intSort]          INT             DEFAULT ((1)) NOT NULL,
    [intConcurrencyId] INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblSMZipCode] PRIMARY KEY CLUSTERED ([strZipCode] ASC, [strCity] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMZipCode',
    @level2type = N'COLUMN',
    @level2name = N'intZipCodeID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zip/Postal Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMZipCode',
    @level2type = N'COLUMN',
    @level2name = N'strZipCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMZipCode',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMZipCode',
    @level2type = N'COLUMN',
    @level2name = N'strCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMZipCode',
    @level2type = N'COLUMN',
    @level2name = N'strCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Latitude',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMZipCode',
    @level2type = N'COLUMN',
    @level2name = N'dblLatitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Longitude',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMZipCode',
    @level2type = N'COLUMN',
    @level2name = N'dblLongitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMZipCode',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMZipCode',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'