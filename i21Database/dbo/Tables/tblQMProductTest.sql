CREATE TABLE [dbo].[tblQMProductTest]
(
	[intProductTestId] INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMProductTest_intConcurrencyId] DEFAULT 0, 
	[intProductId] INT NOT NULL, 
	[intTestId] INT NOT NULL, 
	[intSequenceNo] INT NOT NULL CONSTRAINT [DF_tblQMProductTest_intSequenceNo] DEFAULT 1, 

	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblQMProductTest_dtmCreated] DEFAULT GetDate(),
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblQMProductTest_dtmLastModified] DEFAULT GetDate(),
		
	CONSTRAINT [PK_tblQMProductTest] PRIMARY KEY ([intProductTestId]), 
	CONSTRAINT [AK_tblQMProductTest_intProductId_intTestId] UNIQUE ([intProductId],[intTestId]), 
	CONSTRAINT [FK_tblQMProductTest_tblQMProduct] FOREIGN KEY ([intProductId]) REFERENCES [tblQMProduct]([intProductId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblQMProductTest_tblQMTest] FOREIGN KEY ([intTestId]) REFERENCES [tblQMTest]([intTestId]) 
)