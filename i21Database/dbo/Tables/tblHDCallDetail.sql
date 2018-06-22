CREATE TABLE [dbo].[tblHDCallDetail]
(
	[intCallDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] not null,
	[strName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strFirstName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intClosedCalls] [int] not null default 0,
	[intOpenCalls] [int] not null default 0,
	[intTotalCalls] [int] not null default 0,
	[intReopenCalls] [int] not null default 0,
	[intStartDate] [int] not NULL,
	[intEndDate] [int] not NULL,
	[strFilterKey] [nvarchar](36) COLLATE Latin1_General_CI_AS NULL,
	[intRequestedByEntityId] [int] null,
	[intCreatedDate] [int] not null,
	[intTotalBilledHours] [numeric](18,6) null,
	[dblTotalBillableAmount] [numeric](18,6) null,
	[intCallsRated] [int] null,
	[dblAverageRating] [numeric](18,6) null,
	[intDaysOutstanding] [int] null,
	[intConcurrencyId] [int] not null default 1,
	CONSTRAINT [PK_tblHDCallDetail_intCallDetailId] PRIMARY KEY CLUSTERED ([intCallDetailId] ASC)
)
