﻿CREATE TABLE [dbo].[tblSMActivity]
(
	[intActivityId]				INT NOT NULL PRIMARY KEY IDENTITY,
	[intTransactionId]			[int] NULL,
	[strType]					[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSubject]				[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityContactId]		[int] NULL, 
	[intEntityId]				[int] NULL, 
	[intCompanyLocationId]		[int] NULL, 
	[dtmStartDate]				[datetime] NULL, 
	[dtmEndDate]				[datetime] NULL, 
	[dtmStartTime]				[datetime] NULL, 
	[dtmEndTime]				[datetime] NULL, 
	[ysnAllDayEvent]			[bit] NULL,
	[ysnRemind]					[bit] NULL,
	[strReminder]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strStatus]					[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strPriority]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCategory]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intAssignedTo]				[int] NULL,
	[strActivityNo]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strRelatedTo]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNo]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strLocation]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strDetails]				[nvarchar](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strShowTimeAs]				[nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[ysnPrivate]				[bit] NULL,
	[ysnPublic]					[bit] NULL,
	[dtmCreated]				[datetime] NULL, 
	[dtmModified]				[datetime] NULL, 
	[intCreatedBy]				[int] NULL,
	[strImageId]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strMessageType]			NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strFilter]					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[ysnDismiss]				[bit] NULL,
	[intActivitySourceId]		[int] NULL,
	[strInterCompanyCreatedBy]	NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strInterCompanyAssignedTo]	NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[ysnForTheWeekOf]			[bit] NULL,
	[dblNumberOfHours]			NUMERIC (10, 2) NULL,
	[ysnBillable]				[bit] NULL,
	[strAddress]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCity]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCountry]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strState]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[dblLongitude]					NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [dblLatitude]					NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
	[strO365EventId]				NVARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
	[strO365EventTitle]				NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
	[ysnO365OnlineMeeting]			[bit] NULL,
	[strO365MeetingUrl]				NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]				[int] NOT NULL DEFAULT ((1)), 

    CONSTRAINT [FK_tblSMActivity_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblSMTransaction]([intTransactionId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMActivity_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [UC_tblSMActivity] UNIQUE (strActivityNo)
)
GO

CREATE INDEX [IX_tblSMActivity_intTransactionId] ON [dbo].[tblSMActivity] ([intTransactionId])
GO
CREATE NONCLUSTERED INDEX [IDX_tblSMActivity_strType_strStatus]
ON [dbo].[tblSMActivity] ([strType],[strStatus])
INCLUDE ([intTransactionId])
GO
