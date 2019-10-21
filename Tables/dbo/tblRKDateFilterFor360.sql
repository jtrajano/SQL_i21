CREATE TABLE [dbo].[tblRKDateFilterFor360]
(
	[intDateFilterFor360Id] INT NOT NULL IDENTITY,
	[intConcurrencyId] INT NOT NULL, 
	[dtmToDate] DATETIME NULL
	CONSTRAINT [PK_tblRKDateFilterFor360_intDateFilterFor360Id] PRIMARY KEY ([intDateFilterFor360Id])
)