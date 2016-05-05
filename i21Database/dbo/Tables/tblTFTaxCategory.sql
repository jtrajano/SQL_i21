CREATE TABLE [dbo].[tblTFTaxCategory]
(
	[intTaxCategoryId] INT IDENTITY (1,1) NOT NULL,
    [intTaxAuthorityId] INT NOT NULL, 
    [strState] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strTaxCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblTFTaxCategory] PRIMARY KEY ([intTaxCategoryId])
)
