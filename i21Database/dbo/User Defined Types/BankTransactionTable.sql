﻿CREATE TYPE [dbo].[BankTransactionTable] AS TABLE (
	[intTransactionId]         INT              IDENTITY (1, 1) NOT NULL,
    [strTransactionId]         NVARCHAR (40)    COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankTransactionTypeId] INT              NOT NULL,
    [intBankAccountId]         INT              NOT NULL,
    [intCurrencyId]            INT              NULL,
    [dblExchangeRate]          DECIMAL (38, 20) DEFAULT 1 NOT NULL,
    [dtmDate]                  DATETIME         NOT NULL,
    [strPayee]                 NVARCHAR (300)   COLLATE Latin1_General_CI_AS NULL,
    [intPayeeId]               INT              NULL,
    [strAddress]               NVARCHAR (65)    COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]               NVARCHAR (42)    COLLATE Latin1_General_CI_AS NULL,
    [strCity]                  NVARCHAR (85)    COLLATE Latin1_General_CI_AS NULL,
    [strState]                 NVARCHAR (60)    COLLATE Latin1_General_CI_AS NULL,
    [strCountry]               NVARCHAR (75)    COLLATE Latin1_General_CI_AS NULL,
    [dblAmount]                DECIMAL (18, 6)  DEFAULT 0 NOT NULL,
	[dblShortAmount]           DECIMAL (18, 6)  DEFAULT 0 NOT NULL,
	[intShortGLAccountId]      INT				NULL,
    [strAmountInWords]         NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
    [strMemo]                  NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
    [strReferenceNo]           NVARCHAR (20)    COLLATE Latin1_General_CI_AS NULL,
    [dtmCheckPrinted]          DATETIME         NULL,
    [ysnCheckToBePrinted]      BIT              DEFAULT 0 NOT NULL,
    [ysnCheckVoid]             BIT              DEFAULT 0 NOT NULL,
    [ysnPosted]                BIT              DEFAULT 0 NOT NULL,
    [strLink]                  NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL,
    [ysnClr]                   BIT              DEFAULT 0 NOT NULL,
	[ysnEmailSent]			   BIT				NULL,
	[strEmailStatus]		   NVARCHAR (250)	COLLATE Latin1_General_CI_AS NULL,
    [dtmDateReconciled]        DATETIME         NULL,
	[intBankStatementImportId] INT              NULL,
	[intBankFileAuditId]	   INT				NULL, 
	[strSourceSystem]		   NVARCHAR (2)		COLLATE Latin1_General_CI_AS NULL,
	[intEntityId]			   INT				NULL,
    [intCreatedUserId]         INT              NULL,
	[intCompanyLocationId]     INT              NULL,
    [dtmCreated]               DATETIME         NULL,
    [intLastModifiedUserId]    INT              NULL,
    [dtmLastModified]          DATETIME         NULL,
	[ysnDelete]				   BIT              NULL,
	[dtmDateDeleted]		   DATETIME	        NULL,
    [intConcurrencyId]         INT              DEFAULT 1 NOT NULL
)