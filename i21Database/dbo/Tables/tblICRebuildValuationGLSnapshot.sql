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

GO

CREATE NONCLUSTERED INDEX [IX_tblICRebuildValuationGLSnapshot_intAccountId]
	ON [dbo].[tblICRebuildValuationGLSnapshot]([intAccountId] ASC, dtmRebuildDate ASC);