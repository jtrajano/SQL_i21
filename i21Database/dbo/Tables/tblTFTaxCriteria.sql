CREATE TABLE [dbo].[tblTFTaxCriteria]
(
	[intTaxCriteriaId] INT IDENTITY (1,1) NOT NULL,
    [intTaxCategoryId] INT NOT NULL, 
    [intReportingComponentDetailId] INT NOT NULL, 
    [strState] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strTaxCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCriteria] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblTFTaxCriteria] PRIMARY KEY ([intTaxCriteriaId]),
	CONSTRAINT [FK_tblTFTaxCriteria_tblTFReportingComponentDetail] FOREIGN KEY ([intReportingComponentDetailId]) REFERENCES [dbo].[tblTFReportingComponentDetail] ([intReportingComponentDetailId]) ON DELETE CASCADE
)
