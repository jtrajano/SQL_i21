CREATE TABLE [dbo].[tblSMEvents] (
	[intEventId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NULL,
	[intCalendarId] [int] NULL,
	[strEventTitle] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strEventDetail] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strJsonData] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strScreen] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtmStart] [datetime2] NULL,
	[dtmEnd] [datetime2] NULL,
	[dtmCreated] [datetime] NULL,
	[dtmModified] [datetime] NULL,
	[ysnActive] [bit] DEFAULT ((1)) NULL,
	[intConcurrencyId] [int] NOT NULL,
    CONSTRAINT [PK_tblSMEvents] PRIMARY KEY CLUSTERED ([intEventId] ASC)
);