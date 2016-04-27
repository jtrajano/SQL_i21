CREATE TABLE [dbo].[tblSMCountry] (
    [intCountryID]				INT				IDENTITY (1, 1) NOT NULL,
    [strCountry]				NVARCHAR (100)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strCountryCode]			NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[intCityAreaDigit]			INT				NULL,
	[strCityAreaMask]			NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[intLocalDigit]				INT				NULL,
	[strLocalMask]				NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
	[ysnDisplayCountryCode]		NVARCHAR (40)	COLLATE Latin1_General_CI_AS NULL,
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
    @level2name = N'intCityAreaDigit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'strCityAreaMask'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'intLocalDigit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'strLocalMask'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMCountry',
    @level2type = N'COLUMN',
    @level2name = N'ysnDisplayCountryCode'
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
