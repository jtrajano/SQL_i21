CREATE TYPE [dbo].[BankTransactionDetailTable] AS TABLE (
	[intTransactionDetailId] INT             NULL,
    [intTransactionId]       INT             NOT NULL,
    [dtmDate]                DATETIME        NULL,
    [intGLAccountId]         INT             NOT NULL,
    [strDescription]         NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [dblDebit]               DECIMAL (18, 6) DEFAULT 0 NOT NULL,
    [dblCredit]              DECIMAL (18, 6) DEFAULT 0 NOT NULL,
    [intUndepositedFundId]   INT             NULL,
    [intEntityId]            INT             NULL,
    [intCreatedUserId]       INT             NULL,
    [dtmCreated]             DATETIME        NULL,
    [intLastModifiedUserId]  INT             NULL,
    [dtmLastModified]        DATETIME        NULL,
    [intConcurrencyId]       INT             DEFAULT 1 NOT NULL
)