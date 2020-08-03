CREATE TABLE [dbo].[tblTFReportingComponentConfiguration](
	[intReportingComponentConfigurationId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NOT NULL,
	[strTemplateItemId] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strReportSection] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intReportItemSequence] [int] NULL,
	[intTemplateItemNumber] [int] NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strScheduleCode] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strConfiguration] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnConfiguration] BIT NULL,
	[ysnUserDefinedValue] BIT NOT NULL,
	[ysnOutputDesigner] BIT NULL DEFAULT((0)),
	[strLastIndexOf] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[strSegment] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConfigurationSequence] [int] NULL,
	[strInputType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intMasterId] INT NULL,
	[intConcurrencyId] INT DEFAULT((1)) NULL, 
    CONSTRAINT [PK_tblTFReportingComponentConfiguration] PRIMARY KEY ([intReportingComponentConfigurationId] ASC),
	CONSTRAINT [FK_tblTFReportingComponentConfiguration_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE, 
    CONSTRAINT [UK_tblTFReportingComponentConfiguration_1] UNIQUE ([intReportingComponentId], [strTemplateItemId]) 
)

GO

CREATE INDEX [IX_tblTFReportingComponentConfiguration_strTemplateItemId] ON [dbo].[tblTFReportingComponentConfiguration] ([strTemplateItemId])
GO

CREATE INDEX [IX_tblTFReportingComponentConfiguration_intMasterId] ON [dbo].[tblTFReportingComponentConfiguration] ([intMasterId])
GO