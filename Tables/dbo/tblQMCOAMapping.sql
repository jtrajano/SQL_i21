CREATE TABLE [dbo].[tblQMCOAMapping]
(
	[intCOAMappingId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMCOAMapping_intConcurrencyId] DEFAULT 0, 
	[intItemId] INT NOT NULL, 
	[strVersionNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[dtmEffectiveDate] DATETIME, 
	[strRevisionNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intNoOfSample] INT NOT NULL, 
	[strCommentCOA] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	[strDisclaimer] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	[strCommentTR] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	[strSamplingMethod] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMCOAMapping_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMCOAMapping_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMCOAMapping] PRIMARY KEY ([intCOAMappingId]), 
	CONSTRAINT [AK_tblQMCOAMapping_intItemId] UNIQUE ([intItemId]), 
	CONSTRAINT [FK_tblQMCOAMapping_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)