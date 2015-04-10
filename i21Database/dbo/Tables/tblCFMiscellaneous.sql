CREATE TABLE [dbo].[tblCFMiscellaneous] (
    [intMiscellaneousId]          INT            IDENTITY (1, 1) NOT NULL,
    [intAccountId]                INT            NULL,
    [strMiscellaneous]            NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strMiscellaneousDescription] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]            INT            CONSTRAINT [DF_tblCFMiscellaneous_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFMiscellaneous] PRIMARY KEY CLUSTERED ([intMiscellaneousId] ASC),
    CONSTRAINT [FK_tblCFMiscellaneous_tblCFAccount] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblCFAccount] ([intAccountId])
);

