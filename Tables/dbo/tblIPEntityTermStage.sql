CREATE TABLE [dbo].[tblIPEntityTermStage]
(
	[intStageEntityTermId] INT IDENTITY(1,1),
	[intStageEntityId] INT,
	strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTerm NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	
	CONSTRAINT [PK_tblIPEntityTermStage_intStageEntityTermId] PRIMARY KEY ([intStageEntityTermId]),
	CONSTRAINT [FK_tblIPEntityTermStage_intStageEntityId] FOREIGN KEY ([intStageEntityId]) REFERENCES [tblIPEntityStage]([intStageEntityId]) ON DELETE CASCADE
)
