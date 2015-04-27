CREATE TABLE [dbo].[tblQMSampleTypeDetail]
(
	[intSampleTypeDetailId] INT NOT NULL IDENTITY, 
	[intSampleTypeId] INT NOT NULL, 
	[intAttributeId] INT NOT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMSampleTypeDetail_intConcurrencyId] DEFAULT 0, 
	[ysnIsMandatory] BIT NOT NULL CONSTRAINT [DF_tblQMSampleTypeDetail_ysnIsMandatory] DEFAULT 0, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMSampleTypeDetail_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMSampleTypeDetail_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMSampleTypeDetail] PRIMARY KEY ([intSampleTypeDetailId]), 
	CONSTRAINT [FK_tblQMSampleTypeDetail_tblQMSampleType] FOREIGN KEY ([intSampleTypeId]) REFERENCES [tblQMSampleType]([intSampleTypeId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMSampleTypeDetail_tblQMAttribute] FOREIGN KEY ([intAttributeId]) REFERENCES [tblQMAttribute]([intAttributeId]) 
)
