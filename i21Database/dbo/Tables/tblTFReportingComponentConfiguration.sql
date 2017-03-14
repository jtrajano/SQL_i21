CREATE TABLE [dbo].[tblTFReportingComponentConfiguration](
	[intReportingComponentConfigurationId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NULL,
	[strTemplateItemId] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strReportSection] [nvarchar](max) COLLATE Latin1_General_CI_AS NOT NULL,
	[intReportItemSequence] [int] NULL,
	[intTemplateItemNumber] [int] NOT NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strScheduleCode] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strConfiguration] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnConfiguration] [bit] NULL,
	[ysnDynamicConfiguration] [bit] NOT NULL,
	[strLastIndexOf] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[strSegment] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConfigurationSequence] [int] NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFReportingComponentConfiguration] PRIMARY KEY CLUSTERED 
(
	[intReportingComponentConfigurationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFReportingComponentConfiguration] ADD  CONSTRAINT [DF_tblTFReportingComponentConfiguration_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblTFReportingComponentConfiguration]  WITH CHECK ADD  CONSTRAINT [FK_tblTFReportingComponent_tblTFReportingComponentConfiguration] FOREIGN KEY([intReportingComponentId])
REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblTFReportingComponentConfiguration] CHECK CONSTRAINT [FK_tblTFReportingComponent_tblTFReportingComponentConfiguration]
GO

