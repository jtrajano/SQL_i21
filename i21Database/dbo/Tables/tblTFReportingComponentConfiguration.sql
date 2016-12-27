CREATE TABLE [dbo].[tblTFReportingComponentConfiguration](
	[intReportingComponentConfigurationId] INT IDENTITY(1,1) NOT NULL,
	[intReportingComponentDetailId] INT NULL,
	[strConfigurationName] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intReportingComponentConfigurationValueId] INT NULL,
	[strValue] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strCondition] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strType] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL,
 CONSTRAINT [PK_tblTFReportingComponentConfiguration] PRIMARY KEY CLUSTERED 
(
	[intReportingComponentConfigurationId] ASC
)
)