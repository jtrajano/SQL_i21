CREATE TABLE [dbo].[tblCFNetworkTaxCode] (
    [intNetworkTaxCodeId] INT            IDENTITY (1, 1) NOT NULL,
    [intNetworkId]        INT            NULL,
    [intItemCategory]     INT            NULL,
    [strNetworkTaxCode]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strState]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intTaxCodeId]        INT            NULL,
    [intConcurrencyId]    INT            CONSTRAINT [DF_tblCFNetworkTaxCode_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFNetworkTaxCode] PRIMARY KEY CLUSTERED ([intNetworkTaxCodeId] ASC),
    CONSTRAINT [FK_tblCFNetworkTaxCode_tblCFNetwork] FOREIGN KEY ([intNetworkId]) REFERENCES [dbo].[tblCFNetwork] ([intNetworkId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCFNetworkTaxCode_tblICCategory] FOREIGN KEY ([intItemCategory]) REFERENCES [dbo].[tblICCategory] ([intCategoryId])
);





