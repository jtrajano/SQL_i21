CREATE TABLE [dbo].[tblCRMSalesRepSummaryResult]
(
		[intSalesRepSummaryFilterId] [int] IDENTITY(1,1) NOT NULL,
	[intSalesRepId] [int] not null,
	[strSalesRepName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intCalls] [int] not null default 0,
	[intTasks] [int] not null default 0,
	[intEvents] [int] not null default 0,
	[intEmails] [int] not null default 0,
	[intQuotes] [int] not null default 0,
	[dblDollarValueOfQuotes] [numeric](18,6) not null default 0,
	[intOrders] [int] not null default 0,
	[dblDollarValueOfOrders] [numeric](18,6) not null default 0,
	[intStartDate] [int] not NULL,
	[intEndDate] [int] not NULL,
	[strFilterKey] [nvarchar](36) COLLATE Latin1_General_CI_AS NULL,
	[intRequestedByEntityId] [int] null,
	[intCreatedDate] [int] not null,
	[strDisplayType] [nvarchar](10) COLLATE Latin1_General_CI_AS not NULL,
	[intConcurrencyId] [int] not null default 1,
	CONSTRAINT [PK_tblCRMSalesRepSummaryFilter_intSalesRepSummaryFilterId] PRIMARY KEY CLUSTERED ([intSalesRepSummaryFilterId] ASC)
)
