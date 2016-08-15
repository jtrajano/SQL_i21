﻿CREATE TABLE [dbo].[tblSMActivity]
(
	[intActivityId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intTransactionId] [int] NOT NULL,
	[strType] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSubject] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityContactId] [int] NULL, 
	[intEntityId] [int] NULL, 
	[dtmStartDate] [datetime] NULL, 
	[dtmEndDate] [datetime] NULL, 
	[dtmStartTime] [datetime] NULL, 
	[dtmEndTime] [datetime] NULL, 
	[ysnAllDayEvent] [bit] NULL,
	[ysnRemind] [bit] NULL,
	[strReminder] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strStatus] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strPriority] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCategory] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intAssignedTo] [int] NULL,
	[strActivityNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strRelatedTo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strLocation] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDetails] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnPrivate] [bit] NULL,
	[ysnShowTime] [bit] NULL,
	[dtmCreated] [datetime] NULL, 
	[intCreatedBy] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((1)), 
    CONSTRAINT [FK_tblSMActivity_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]),
	CONSTRAINT [UC_tblSMActivity] UNIQUE (strActivityNo)
)
