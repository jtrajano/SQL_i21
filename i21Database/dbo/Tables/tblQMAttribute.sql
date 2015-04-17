CREATE TABLE [dbo].[tblQMAttribute]
(
	[intAttributeId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMAttribute_intConcurrencyId] DEFAULT 0, 
	[strAttributeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[intDataTypeId] INT NOT NULL, 
	[intListId] INT, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMAttribute_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMAttribute_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMAttribute] PRIMARY KEY ([intAttributeId]), 
	CONSTRAINT [AK_tblQMAttribute_strAttributeName] UNIQUE ([strAttributeName]), 
	CONSTRAINT [FK_tblQMAttribute_tblQMAttributeDataType] FOREIGN KEY ([intDataTypeId]) REFERENCES [tblQMAttributeDataType]([intDataTypeId]), 
	CONSTRAINT [FK_tblQMAttribute_tblQMList] FOREIGN KEY ([intListId]) REFERENCES [tblQMList]([intListId]) 
)