CREATE TABLE [dbo].[tblSMEvents] (
	[intEventId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NULL,
	[strEventTitle] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strEventDetail] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strJsonData] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strScreen] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreated] [datetime] NULL,
	[dtmModified] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL,
	[dtmStart] [datetime2](7) NULL,
	[dtmEnd] [datetime2](7) NULL,
    CONSTRAINT [PK_tblSMEvents] PRIMARY KEY CLUSTERED ([intEventId] ASC)
);