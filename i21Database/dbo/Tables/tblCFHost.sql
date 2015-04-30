CREATE TABLE [dbo].[tblCFHost] (
    [intHostId]        INT            IDENTITY (1, 1) NOT NULL,
    [strHostNumber]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strHostName]      NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFHost_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFHost] PRIMARY KEY CLUSTERED ([intHostId] ASC)
);



