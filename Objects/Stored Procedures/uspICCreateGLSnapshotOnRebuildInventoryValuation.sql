CREATE PROCEDURE [dbo].[uspICCreateGLSnapshotOnRebuildInventoryValuation]
	@dtmRebuildDate AS DATETIME 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE name = 'tblICRebuildValuationGLSnapshot' and type = 'U')
BEGIN 
	EXEC ('
		CREATE TABLE [dbo].[tblICRebuildValuationGLSnapshot]
		(
			[intId] INT NOT NULL IDENTITY, 
			[intAccountId] INT NOT NULL, 
			[dblDebit] NUMERIC(38, 20) NULL DEFAULT 0, 
			[dblCredit] NUMERIC(38, 20) NULL DEFAULT 0, 
			[intYear] INT NOT NULL, 
			[intMonth] INT NOT NULL, 
			[dtmRebuildDate] DATETIME NOT NULL,
			CONSTRAINT [PK_tblICRebuildValuationGLSnapshot] PRIMARY KEY ([intId]), 
			CONSTRAINT [UN_tblICRebuildValuationGLSnapshot] UNIQUE NONCLUSTERED ([intAccountId] ASC, [intYear] ASC, [intMonth] ASC, [dtmRebuildDate] ASC),		
			CONSTRAINT [FK_tblICRebuildValuationGLSnapshot_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId])
		)
	')

	EXEC ('
			CREATE NONCLUSTERED INDEX [IX_tblICRebuildValuationGLSnapshot_intAccountId]
			ON [dbo].[tblICRebuildValuationGLSnapshot]([intAccountId] ASC);	

	')
END

INSERT INTO tblICRebuildValuationGLSnapshot (
	intAccountId
	,dtmRebuildDate
	,intYear
	,intMonth
	,dblDebit
	,dblCredit 
)
SELECT	intAccountId 		
		,@dtmRebuildDate
		,[year] = year(dtmDate) 
		,[month] = month(dtmDate)
		,SUM(dblDebit)
		,SUM(dblCredit)		
FROM	dbo.tblGLDetail 
GROUP BY intAccountId, YEAR(dtmDate), MONTH(dtmDate) 