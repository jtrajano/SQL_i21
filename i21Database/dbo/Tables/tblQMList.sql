CREATE TABLE [dbo].[tblQMList]
(
	[intListId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMList_intConcurrencyId] DEFAULT 0, 
	[strListName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strSQL] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMList_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMList_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMList] PRIMARY KEY ([intListId]), 
	CONSTRAINT [AK_tblQMList_strListName] UNIQUE ([strListName])
)