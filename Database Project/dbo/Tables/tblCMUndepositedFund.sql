CREATE TABLE [dbo].[tblCMUndepositedFund] (
    [intUndepositedFundID]  INT             IDENTITY (1, 1) NOT NULL,
    [strTransactionID]      NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dblDebit]              DECIMAL (18, 6) NOT NULL,
    [strBankTransactionID]  NVARCHAR (20)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intCreatedUserID]      INT             NULL,
    [dtmCreated]            DATETIME        NULL,
    [intLastModifiedUserID] INT             NULL,
    [dtmLastModified]       DATETIME        NULL,
    [intConcurrencyID]      INT             NOT NULL,
    CONSTRAINT [PK_tblCMUndepositedFund] PRIMARY KEY CLUSTERED ([intUndepositedFundID] ASC)
);

