CREATE TABLE [dbo].[tblQMTestProperty]
(
	[intTestPropertyId] INT NOT NULL IDENTITY, 
	[intTestId] INT NOT NULL, 
	[intPropertyId] INT NOT NULL, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMTestProperty_intConcurrencyId] DEFAULT 0, 
	[intSequenceNo] INT NOT NULL CONSTRAINT [DF_tblQMTestProperty_intSequenceNo] DEFAULT 1, 
	[intFormulaID] INT NULL CONSTRAINT [DF_tblQMTestProperty_intFormulaID] DEFAULT 0, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMTestProperty_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMTestProperty_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMTestProperty] PRIMARY KEY ([intTestPropertyId]), 
	CONSTRAINT [AK_tblQMTestProperty_intTestId_intPropertyId] UNIQUE ([intTestId],[intPropertyId]), 
	CONSTRAINT [FK_tblQMTestProperty_tblQMTest] FOREIGN KEY ([intTestId]) REFERENCES [tblQMTest]([intTestId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMTestProperty_tblQMProperty] FOREIGN KEY ([intPropertyId]) REFERENCES [tblQMProperty]([intPropertyId]) 
)