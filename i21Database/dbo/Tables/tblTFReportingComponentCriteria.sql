CREATE TABLE [dbo].[tblTFReportingComponentCriteria]
(
	[intReportingComponentCriteriaId] INT IDENTITY (1,1) NOT NULL,
    [intTaxCategoryId] INT NOT NULL, 
    [intReportingComponentId] INT NOT NULL, 
    [strCriteria] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT DEFAULT ((1)) NULL, 
    CONSTRAINT [PK_tblTFReportingComponentCriteria] PRIMARY KEY ([intReportingComponentCriteriaId] ASC),
	CONSTRAINT [FK_tblTFReportingComponentCriteria_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE
)