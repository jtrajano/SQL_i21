CREATE TABLE [dbo].[tblQMTestMethod]
(
	[intTestMethodId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMTestMethod_intConcurrencyId] DEFAULT 0, 
	[strTestMethodName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMTestMethod_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMTestMethod_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMTestMethod] PRIMARY KEY ([intTestMethodId]), 
	CONSTRAINT [AK_tblQMTestMethod_strTestMethodName] UNIQUE ([strTestMethodName])
)