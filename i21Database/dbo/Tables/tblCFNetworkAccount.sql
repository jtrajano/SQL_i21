CREATE TABLE [dbo].[tblCFNetworkAccount] (
    [intNetworkAccountId] INT            IDENTITY (1, 1) NOT NULL,
    [intAccountId]        INT            NOT NULL,
    [intNetworkId]        INT            NOT NULL,
    [strNetworkAccountId] NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFNetworkAccount_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFNetworkAccount] PRIMARY KEY CLUSTERED ([intNetworkAccountId] ASC)
);

