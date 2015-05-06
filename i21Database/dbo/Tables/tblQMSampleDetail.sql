CREATE TABLE [dbo].[tblQMSampleDetail]
(
	[intSampleDetailId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMSampleDetail_intConcurrencyId] DEFAULT 0, 
	[intSampleId] INT NOT NULL, 
	[intAttributeId] INT, 
	[strAttributeValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '', 
	[intDocumentFileId] INT, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMSampleDetail_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMSampleDetail_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMSampleDetail] PRIMARY KEY ([intSampleDetailId]), 
	CONSTRAINT [FK_tblQMSampleDetail_tblQMSample] FOREIGN KEY ([intSampleId]) REFERENCES [tblQMSample]([intSampleId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMSampleDetail_tblQMAttribute] FOREIGN KEY ([intAttributeId]) REFERENCES [tblQMAttribute]([intAttributeId]), 
	CONSTRAINT [FK_tblQMSampleDetail_tblQMDocumentFile] FOREIGN KEY ([intDocumentFileId]) REFERENCES [tblQMDocumentFile]([intDocumentFileId]) 
)
