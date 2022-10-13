CREATE TABLE [dbo].[tblMBILApplicationLog]
(
	[intLogId] [int] IDENTITY NOT NULL,
	[strEmailAddress] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL, 	
	[strAppVersion] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL, 	
	[strServerConnection] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL, 
	[strCompany] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,	
	[dtmCreated] [datetime] NULL,	
	[intConcurrencyId] [int] NULL,
	CONSTRAINT [PK_tblMBILApplicationLog] PRIMARY KEY ([intLogId])
)