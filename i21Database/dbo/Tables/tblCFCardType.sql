CREATE TABLE [dbo].[tblCFCardType] (
    [intCardTypeId]    INT            IDENTITY (1, 1) NOT NULL,
    [strCardType]      NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intNetworkId]     INT            NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFCardType_intConcurrencyId] DEFAULT ((1)) NULL,
    [strDescription]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFCardType] PRIMARY KEY CLUSTERED ([intCardTypeId] ASC)
);

