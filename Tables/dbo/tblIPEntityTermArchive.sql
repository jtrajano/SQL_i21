CREATE TABLE [dbo].[tblIPEntityTermArchive]
(
	[intStageEntityTermId] INT IDENTITY(1,1),
	[intStageEntityId] INT,
	strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTerm NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	CONSTRAINT [PK_tblIPEntityTermArchive_intStageEntityTermId] PRIMARY KEY ([intStageEntityTermId])
)
