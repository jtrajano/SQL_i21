CREATE TABLE [dbo].[tblTFTaxReportTemplate](
	[intReportTemplateId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NULL,
	[strTemplateItemId] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[strFormCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTaxAuthorityId] [int] NULL,
	[strTaxAuthority] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strReportSection] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intReportItemSequence] [int] NULL,
	[intTemplateItemNumber] [int] NOT NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strScheduleCode] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strConfiguration] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnConfiguration] BIT NULL,
	[ysnDynamicConfiguration] BIT NOT NULL,
	[strLastIndexOf] [nvarchar](10) COLLATE Latin1_General_CI_AS NULL,
	[strSegment] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConfigurationSequence] [int] NULL,
	[intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblTFTaxReportSummaryItems] PRIMARY KEY CLUSTERED 
(
	[intReportTemplateId] ASC
)
)