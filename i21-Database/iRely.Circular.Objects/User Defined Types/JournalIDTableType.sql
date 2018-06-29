﻿CREATE TYPE [dbo].[JournalIDTableType] AS TABLE(
	[intJournalId] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[intJournalId] ASC
)WITH (IGNORE_DUP_KEY = OFF),
	UNIQUE NONCLUSTERED 
(
	[intJournalId] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)