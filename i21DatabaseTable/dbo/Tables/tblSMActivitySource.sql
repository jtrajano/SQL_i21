CREATE TABLE [dbo].[tblSMActivitySource]
(
	[intActivitySourceId]	INT				NOT NULL PRIMARY KEY IDENTITY, 
    [strActivitySource]		NVARCHAR(250)	COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId]		INT				NOT NULL DEFAULT 1
)
