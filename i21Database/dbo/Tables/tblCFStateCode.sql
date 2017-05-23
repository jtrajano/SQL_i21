CREATE TABLE [dbo].[tblCFStateCode] (
    [intStateCodeId]   INT            IDENTITY (1, 1) NOT NULL,
    [intNetworkId]     INT            NULL,
    [intStateCode]     INT            NULL,
    [strStateName]     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strPostalCode]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFStateCode_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFStateCode] PRIMARY KEY CLUSTERED ([intStateCodeId] ASC),
    CONSTRAINT [FK_tblCFStateCode_tblCFNetwork] FOREIGN KEY ([intNetworkId]) REFERENCES [dbo].[tblCFNetwork] ([intNetworkId]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX tblCFStateCode_UniqueNetworkStateCode
	ON tblCFStateCode (intNetworkId,strStateName);

