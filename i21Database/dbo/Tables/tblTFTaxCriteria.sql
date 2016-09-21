CREATE TABLE [dbo].[tblTFTaxCriteria]
(
	[intTaxCriteriaId] INT IDENTITY (1,1) NOT NULL,
    [intTaxCategoryId] INT NOT NULL, 
    [intReportingComponentId] INT NOT NULL, 
    [strState] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strTaxCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCriteria] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblTFTaxCriteria] PRIMARY KEY CLUSTERED 
(
	[intTaxCriteriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFTaxCriteria]  WITH CHECK ADD  CONSTRAINT [FK_tblTFTaxCriteria_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId])
REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblTFTaxCriteria] CHECK CONSTRAINT [FK_tblTFTaxCriteria_tblTFReportingComponent]
GO
