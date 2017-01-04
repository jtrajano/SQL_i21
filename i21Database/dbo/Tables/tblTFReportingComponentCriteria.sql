CREATE TABLE [dbo].[tblTFReportingComponentCriteria](
	[intReportingComponentCriteriaId] [int] IDENTITY(1,1) NOT NULL,
	[intTaxCategoryId] [int] NOT NULL,
	[intReportingComponentId] [int] NOT NULL,
	[strCriteria] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFReportingComponentCriteria] PRIMARY KEY CLUSTERED 
(
	[intReportingComponentCriteriaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFReportingComponentCriteria] ADD  CONSTRAINT [DF_tblTFReportingComponentCriteria_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblTFReportingComponentCriteria]  WITH CHECK ADD  CONSTRAINT [FK_tblTFReportingComponentCriteria_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId])
REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblTFReportingComponentCriteria] CHECK CONSTRAINT [FK_tblTFReportingComponentCriteria_tblTFReportingComponent]
GO