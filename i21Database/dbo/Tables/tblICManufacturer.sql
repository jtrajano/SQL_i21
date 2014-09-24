CREATE TABLE [dbo].[tblICManufacturer]
(
	[intManufacturerId] INT NOT NULL IDENTITY , 
    [strManufacturer] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strContact] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strAddress] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strZipCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strCity] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strCountry] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strPhone] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strFax] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strWebsite] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strEmail] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strNotes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICManufacturer] PRIMARY KEY ([intManufacturerId]), 
    CONSTRAINT [AK_tblICManufacturer_strManufacturer] UNIQUE ([strManufacturer])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'intManufacturerId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Manufacturer Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strManufacturer'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Contact',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strContact'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zip Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strZipCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'City',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strCity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'State',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strState'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Country',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strCountry'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Phone Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fax',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strFax'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Website',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strWebsite'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Email Address',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strEmail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Notes',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'strNotes'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICManufacturer',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'