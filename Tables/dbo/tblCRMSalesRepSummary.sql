CREATE TABLE [dbo].[tblCRMSalesRepSummary]
(
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[strIdentifier] [nvarchar](36) COLLATE Latin1_General_CI_AS NOT NULL,
	[RepId] [int] NOT NULL,
	[RepName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[Calls] [int] NOT NULL default 0,
	[Tasks] [int] NOT NULL default 0,
	[Events] [int] NOT NULL default 0,
	[Emails] [int] NOT NULL default 0,
	[Quotes] [int] NOT NULL default 0,
	[Orders] [int] NOT NULL default 0,
	[DollarValueOfQuotes] [numeric](18, 6) NOT NULL DEFAULT 0.00,
	[DollarValueOfOrders] [numeric](18, 6) NOT NULL DEFAULT 0.00,
	[Date] datetime null,
	CONSTRAINT [PK_tblCRMSalesRepSummary_intId] PRIMARY KEY CLUSTERED ([intId] ASC)
)
