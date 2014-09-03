CREATE TABLE [dbo].[tblPRTaxAgency](
	[intTaxAgencyId] [int] NOT NULL IDENTITY,
	[strTaxAgency] [nvarchar](50) NOT NULL,
	[strTaxRemitAddr] [nvarchar](255) NULL,
	[strZip] [nvarchar](50) NULL,
	[strCountry] [nvarchar](50) NULL,
	[strState] [nvarchar](50) NULL,
	[strCounty] [nvarchar](50) NULL,
	[strCity] [nvarchar](50) NULL,
	[intTaxAccountId] INT NULL,
	[strPhone] [nvarchar](50) NULL,
	[strFax] [nvarchar](50) NULL,
	[strComments] [nvarchar](MAX) NULL,
	[intConcurrencyId] [int] NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPRTaxAgency] PRIMARY KEY ([intTaxAgencyId]), 
    CONSTRAINT [AK_tblPRTaxAgency_strTaxAgencyName] UNIQUE ([strTaxAgency]) 
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'intTaxAgencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Agency Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = 'strTaxAgency'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Remittance Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'strTaxRemitAddr'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zip Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'strZip'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'strCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'County',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'strCounty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'strCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phone',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'strPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tax Account Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'intTaxAccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'strFax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comments',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'strComments'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblPRTaxAgency',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'