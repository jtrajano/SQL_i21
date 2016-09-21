CREATE TABLE [dbo].[tblTFScheduleFields](
	[intScheduleColumnId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NULL,
	[strColumn] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCaption] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFormat] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFooter] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intWidth] [int] NULL,
	[intScheduleFieldTemplateId] [int] NULL,
	[intConcurrencyId] [int] NULL,
CONSTRAINT [PK_tblTFScheduleFields] PRIMARY KEY CLUSTERED 
(
	[intScheduleColumnId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFScheduleFields] ADD  CONSTRAINT [DF_tblTFScheduleFields_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblTFScheduleFields]  WITH CHECK ADD  CONSTRAINT [FK_tblTFScheduleFields_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId])
REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblTFScheduleFields] CHECK CONSTRAINT [FK_tblTFScheduleFields_tblTFReportingComponent]
GO
