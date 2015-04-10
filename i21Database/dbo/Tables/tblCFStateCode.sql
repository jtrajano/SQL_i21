CREATE TABLE [dbo].[tblCFStateCode] (
    [intStateCodeId]   INT            NULL,
    [intStateCode]     INT            NULL,
    [strStateName]     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strPostalCode]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFStateCode_intConcurrencyId] DEFAULT ((1)) NULL
);

