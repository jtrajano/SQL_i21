CREATE TABLE [dbo].[tblSMEvents] (
	[intEventId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NULL,
	[strEventTitle] [nvarchar](max) NULL,
	[strJsonData] [nvarchar](max) NULL,
	[strScreen] [nvarchar](50) NULL,
	[strRecordNo] [nvarchar](50) NULL,
	[dtmCreated] [datetime] NULL,
	[dtmModified] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL,
	[dtmStart] [datetime2](7) NULL,
	[dtmEnd] [datetime2](7) NULL,
    CONSTRAINT [PK_tblSMEvents] PRIMARY KEY CLUSTERED ([intEventId] ASC)
);