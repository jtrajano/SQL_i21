﻿CREATE TABLE [dbo].[tblGLPosted]
(
	[intPostedId]			INT             IDENTITY (1, 1) NOT NULL,
	[intAccountId]			INT             NOT NULL,
	[dtmDate]				DATETIME		NOT NULL,
	[dblDebit]				NUMERIC(20, 6)	NULL,
	[dblCredit]				NUMERIC(20, 6)	NULL,
	[dblDebitForeign]		NUMERIC(20, 6)	NULL,
	[dblCreditForeign]		NUMERIC(20, 6)	NULL,
	[dblDebitUnit]			NUMERIC(20, 6)	NULL,
	[dblCreditUnit]			NUMERIC(20, 6)	NULL,
	[strCode]				NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]			INT             NOT NULL,
	[intConcurrencyId]		INT             NOT NULL,
	CONSTRAINT [PK_tblGLPosted] PRIMARY KEY CLUSTERED ([intAccountId] ASC,[dtmDate] ASC,[intCurrencyId] ASC,[strCode] ASC),
)
