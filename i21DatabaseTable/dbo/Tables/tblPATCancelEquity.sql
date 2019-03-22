CREATE TABLE [dbo].[tblPATCancelEquity]
(
	[intCancelEquityId] INT NOT NULL IDENTITY, 
    [dtmCancelDate] DATETIME NULL, 
    [strCancelNo] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
    [strCancelBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dblCancelByValue] NUMERIC(18, 6) NULL, 
	[ysnPosted] BIT NULL DEFAULT 0,
    [intConcurrencyId] INT NULL DEFAULT 0,
	CONSTRAINT [PK_tblPATCancelEquity_intCancelEquityId] PRIMARY KEY ([intCancelEquityId])
)