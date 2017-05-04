CREATE TABLE [dbo].[tblTRState]
(
	[intStateId] INT NOT NULL IDENTITY,
	[strStateName] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strStateAbbreviation] nvarchar(2) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL default 1,
	CONSTRAINT [PK_tblTRState] PRIMARY KEY ([intStateId])
)
