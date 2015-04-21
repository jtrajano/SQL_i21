CREATE TABLE [dbo].[tblQMSampleType]
(
	[intSampleTypeId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMSampleType_intConcurrencyId] DEFAULT 0, 
	[strSampleTypeName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS, 
	[intControlPointId] INT NOT NULL, 
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMSampleType_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMSampleType_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMSampleType] PRIMARY KEY ([intSampleTypeId]), 
	CONSTRAINT [AK_tblQMSampleType_strSampleTypeName] UNIQUE ([strSampleTypeName]), 
	CONSTRAINT [FK_tblQMSampleType_tblQMControlPoint] FOREIGN KEY ([intControlPointId]) REFERENCES [tblQMControlPoint]([intControlPointId])
)