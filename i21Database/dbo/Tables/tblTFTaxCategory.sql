CREATE TABLE [dbo].[tblTFTaxCategory]
(
	[intTaxCategoryId] INT IDENTITY (1,1) NOT NULL,
    [intTaxAuthorityId] INT NOT NULL, 
    [strState] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strTaxCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intMasterId] INT NULL,
    [intConcurrencyId] INT NULL, 
 CONSTRAINT [PK_tblTFTaxCategory] PRIMARY KEY CLUSTERED 
(
	[intTaxCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFTaxCategory] ADD  CONSTRAINT [DF_tblTFTaxCategory_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO



