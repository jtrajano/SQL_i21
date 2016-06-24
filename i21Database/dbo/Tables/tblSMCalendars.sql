CREATE TABLE [dbo].[tblSMCalendars] (
	[intCalendarId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[strCalendarName] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCalendarType] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[ysnReadOnly] [bit] DEFAULT ((0)) NOT NULL,
	[dtmCreated] [datetime] NULL,
	[dtmModified] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL,
    CONSTRAINT [PK_tblSMCalendars] PRIMARY KEY CLUSTERED ([intCalendarId] ASC)
);