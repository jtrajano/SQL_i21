CREATE TABLE [dbo].[tblQMSampleTypeUserRole]
(
	[intSampleTypeUserRoleId] INT NOT NULL IDENTITY, 
	[intSampleTypeId] INT NOT NULL, 
	[intUserRoleID] INT NOT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMSampleTypeUserRole_intConcurrencyId] DEFAULT 0,
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMSampleTypeUserRole_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMSampleTypeUserRole_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMSampleTypeUserRole] PRIMARY KEY ([intSampleTypeUserRoleId]), 
	CONSTRAINT [FK_tblQMSampleTypeUserRole_tblQMSampleType] FOREIGN KEY ([intSampleTypeId]) REFERENCES [tblQMSampleType]([intSampleTypeId]) ON DELETE CASCADE
)
