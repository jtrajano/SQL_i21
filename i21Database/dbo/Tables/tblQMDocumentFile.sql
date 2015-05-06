CREATE TABLE [dbo].[tblQMDocumentFile]
(
	[intDocumentFileId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMDocumentFile_intConcurrencyId] DEFAULT 0, 
	[strDocFile] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, 
	[strDocName] NVARCHAR(512) COLLATE Latin1_General_CI_AS, 
	[strDocType] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[dblDocSize] NUMERIC(18, 6) NULL,
	[intEntityTypeId] INT, -- Foreign Key DocumentEntityTypes
	[intEntityId] INT, -- Foreign Key 
	[intDocumentId] INT, -- Foreign Key

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMDocumentFile_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMDocumentFile_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMDocumentFile] PRIMARY KEY ([intDocumentFileId]), 
	--CONSTRAINT [FK_tblQMDocumentFile_tblQMDataType] FOREIGN KEY ([intDataTypeId]) REFERENCES [tblQMDataType]([intDataTypeId]) 
)