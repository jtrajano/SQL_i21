CREATE TABLE [dbo].[tblHDTimeEntryDailySummary]
(
	[intTimeEntryDailySummaryId] [int] IDENTITY(1,1) NOT NULL,
	[intTimeEntryId] [int] NOT NULL,
	[intEntityId] [int] NOT NULL,
	[dtmDate] [datetime] NOT NULL,
	[intJiraId] [int] NULL,
	[strJiraKey] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strJiraStatus] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strJiraStatusIconUrl] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[strTicketId] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strTicketNumber] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strTicketNumbersDisplay] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateStarted] [datetime] NULL,
	[dtmDateEnded] [datetime] NULL,
	[dblTimeSpent] [numeric](18,6) NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strComments] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[dblBillableHours] [numeric](18,6) NULL,
	[ysnSent] [bit] NULL,
	[strJIRAUserName] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDTimeEntryDailySummary_intTimeEntryDailySummaryId] PRIMARY KEY CLUSTERED ([intTimeEntryDailySummaryId] ASC)
)
