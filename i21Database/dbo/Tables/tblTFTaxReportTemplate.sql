CREATE TABLE [dbo].[tblTFTaxReportTemplate](
	[intTaxReportSummaryItems] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentDetailId] [int] NULL,
	[intTaxReportSummaryItemId] [nvarchar](20) COLLATE Latin1_General_CI_AS NULL,
	[strSummaryFormCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSummaryTaxAuthorityId] [int] NULL,
	[strSummaryTaxAuthority] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSummarySection] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSummaryItemSequenceNumber] [int] NULL,
	[intSummaryItemNumber] [int] NOT NULL,
	[strSummaryItemDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSummaryScheduleCode] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strConfiguration] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSummaryPart] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strSummaryOperation] [nvarchar](120) COLLATE Latin1_General_CI_AS NULL,
	[strTaxType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConfigurationSequence] [int] NULL,
	[intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblTFTaxReportSummaryItems] PRIMARY KEY CLUSTERED 
(
	[intTaxReportSummaryItems] ASC
)
)