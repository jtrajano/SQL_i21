CREATE TABLE [dbo].[tblSMCountry] (
    [intCountryID]     INT            IDENTITY (1, 1) NOT NULL,
    [strCountry]       NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPhoneNumber]   NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [strCountryCode]   NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
    [intSort]          INT            NULL,
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_SMCountry_CoutryID] PRIMARY KEY CLUSTERED ([intCountryID] ASC), 
    CONSTRAINT [AK_tblSMCountry_Country] UNIQUE (strCountry)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'intCountryID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'strCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phone Number default format',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'strPhoneNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'strCountryCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'