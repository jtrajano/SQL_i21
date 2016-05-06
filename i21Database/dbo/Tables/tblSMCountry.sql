CREATE TABLE [dbo].[tblSMCountry] (
    [intCountryID]				INT				IDENTITY (1, 1) NOT NULL,
    [strCountry]				NVARCHAR (100)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strCountryCode]			NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[strCountryFormat]			NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[strAreaCityFormat]			NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[strLocalNumberFormat]		NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
    [intSort]					INT				NULL,
    [intConcurrencyId]			INT				DEFAULT 1 NOT NULL,
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
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'strCountryCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'strCountryFormat'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'strAreaCityFormat'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'strLocalNumberFormat'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
