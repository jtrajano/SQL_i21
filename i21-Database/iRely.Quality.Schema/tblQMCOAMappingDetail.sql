CREATE TABLE [dbo].[tblQMCOAMappingDetail]
(
	[intCOAMappingDetailId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMCOAMappingDetail_intConcurrencyId] DEFAULT 0, 
	[intCOAMappingId] INT NOT NULL, 
	[strTemplate] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intProductId] INT NOT NULL, 
	[intPropertyId] INT NOT NULL, 
	[strTestType] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[ysnIsRequired] BIT NOT NULL CONSTRAINT [DF_tblQMCOAMappingDetail_ysnIsRequired] DEFAULT 0, 
	[intTestMethodId] INT, 
	[strSpecification] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMCOAMappingDetail_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMCOAMappingDetail_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMCOAMappingDetail] PRIMARY KEY ([intCOAMappingDetailId]), 
	CONSTRAINT [FK_tblQMCOAMappingDetail_tblQMCOAMapping] FOREIGN KEY ([intCOAMappingId]) REFERENCES [tblQMCOAMapping]([intCOAMappingId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMCOAMappingDetail_tblQMProduct] FOREIGN KEY ([intProductId]) REFERENCES [tblQMProduct]([intProductId]), 
	CONSTRAINT [FK_tblQMCOAMappingDetail_tblQMProperty] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]), 
	CONSTRAINT [FK_tblQMCOAMappingDetail_tblQMTestMethod] FOREIGN KEY ([intTestMethodId]) REFERENCES [tblQMTestMethod]([intTestMethodId])
)