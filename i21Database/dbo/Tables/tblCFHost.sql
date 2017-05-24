CREATE TABLE [dbo].[tblCFHost] (
    [intHostId]        INT            IDENTITY (1, 1) NOT NULL,
    [intNetworkId]     INT            NULL,
    [strHostNumber]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strHostName]      NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFHost_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFHost] PRIMARY KEY CLUSTERED ([intHostId] ASC),
    CONSTRAINT [FK_tblCFHost_tblCFNetwork] FOREIGN KEY ([intNetworkId]) REFERENCES [dbo].[tblCFNetwork] ([intNetworkId]) ON DELETE CASCADE
);

GO
CREATE UNIQUE NONCLUSTERED INDEX tblCFHost_UniqueNetworkHost
	ON tblCFHost (intNetworkId,strHostNumber);



