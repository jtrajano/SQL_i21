CREATE TABLE tblICTally (
	[intKey] INT NOT NULL IDENTITY, 
	[intId1] INT NOT NULL,
	[intId2] INT NULL
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICTally_Id]
	ON [dbo].[tblICTally]([intId1] ASC, [intId2] ASC)
GO