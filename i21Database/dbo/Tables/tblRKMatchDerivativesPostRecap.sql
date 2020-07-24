﻿CREATE TABLE [dbo].[tblRKMatchDerivativesPostRecap](
	[intMatchDerivativesPostRecapId] INT IDENTITY(1,1) NOT NULL,
	[dtmPostDate] DATETIME NOT NULL,
	[strBatchId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strReversalBatchId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intAccountId] INT NULL,
	[strAccountId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[dblDebit] NUMERIC(18, 6) NULL,
	[dblCredit] NUMERIC(18, 6) NULL,
	[dblDebitUnit] NUMERIC(18, 6) NULL,
	[dblCreditUnit] NUMERIC(18, 6) NULL,
	[strAccountDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId] INT NULL,
	[dblExchangeRate] NUMERIC(38, 20) NOT NULL,
	[dtmTransactionDate] DATETIME NULL,
	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId] INT NULL,
	[strReference] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionForm] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strModuleName] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strCode] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateEntered] DATETIME NOT NULL,
	[ysnIsUnposted] BIT NOT NULL,
	[intUserId] INT NULL,
	[intEntityId] INT NULL,
	[intSourceLocationId] INT NULL,
	[intSourceUOMId] INT NULL,
	[intCommodityId] INT NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)),
		
	CONSTRAINT [PK_tblRKMatchDerivativesPostRecap] PRIMARY KEY CLUSTERED ([intMatchDerivativesPostRecapId] ASC)
);
