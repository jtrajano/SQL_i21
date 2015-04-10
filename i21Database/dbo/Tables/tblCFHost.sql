CREATE TABLE [dbo].[tblCFHost] (
    [intHostId]        INT            NULL,
    [strHostNumber]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strHostName]      NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFHost_intConcurrencyId] DEFAULT ((1)) NULL
);

