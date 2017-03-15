CREATE TABLE [dbo].[tblTFReportingComponentField](
	[intReportingComponentFieldId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NULL,
	[strColumn] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCaption] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFormat] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFooter] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intWidth] [int] NULL,
	[intScheduleFieldTemplateId] [int] NULL,
	[intConcurrencyId] [int] DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblTFReportingComponentField] PRIMARY KEY ([intReportingComponentFieldId] ASC),
	CONSTRAINT [FK_tblTFReportingComponentField_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE
)