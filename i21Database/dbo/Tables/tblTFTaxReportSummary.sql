CREATE TABLE [dbo].[tblTFTaxReportSummary](
	[intReportSummaryId] [int] IDENTITY(1,1) NOT NULL,
	[strSummaryGuid] [uniqueidentifier] NOT NULL,
	[intTaxAuthorityId] [int] NOT NULL,
	[strTaxAuthority] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFormCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intItemNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intItemSequenceNumber] [int] NULL,
	[strSection] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strScheduleCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strColumn] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strColumnValue] [numeric](18, 2) NULL,
	[strSegment] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strProductCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxClass] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateRun] [datetime] NOT NULL,
	[dtmReportingPeriodBegin] [datetime] NULL,
	[dtmReportingPeriodEnd] [datetime] NULL,
	[strTaxPayerName] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerAddress] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerIdentificationNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerFEIN] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTaxPayerDBA] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strMotorCarrier] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strLicenseNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strEmail] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strFEINSSN] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCity] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strState] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strZipCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strTelephoneNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strContactName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFTaxReportSummary] PRIMARY KEY CLUSTERED 
(
	[intReportSummaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFTaxReportSummary] ADD  CONSTRAINT [DF_tblTFTaxReportSummary_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO