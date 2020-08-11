CREATE TABLE [dbo].[tblARInvoiceGrossMarginSummary](
	[intSummaryId] [int] IDENTITY(1,1) NOT NULL,
	[strType] [varchar](7) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblAmount] [decimal](18, 6) NULL,
	[dtmDate] [datetime] NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblARInvoiceGrossMarginSummary] PRIMARY KEY CLUSTERED 
(
	[intSummaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO