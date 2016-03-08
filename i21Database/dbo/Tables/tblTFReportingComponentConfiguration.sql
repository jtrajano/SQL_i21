CREATE TABLE [dbo].[tblTFReportingComponentConfiguration](
	[intReportingComponentConfigurationId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentDetailId] [int] NULL,
	[strConfigurationName] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intReportingComponentConfigurationValueId] [int] NULL,
	[strValue] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCondition] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFReportingComponentConfiguration] PRIMARY KEY CLUSTERED 
(
	[intReportingComponentConfigurationId] ASC
)
)