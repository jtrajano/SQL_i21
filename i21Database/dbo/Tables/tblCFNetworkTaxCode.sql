CREATE TABLE [dbo].[tblCFNetworkTaxCode] (
    [intNetworkTaxCodeId]   INT            IDENTITY (1, 1) NOT NULL,
    [intNetworkId]          INT            NULL,
    [intNetworkTaxCode]     INT            NULL,
    [strTaxCodeDescription] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strSSITaxCode]         NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT            CONSTRAINT [DF_tblCFNetworkTaxCode_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFNetworkTaxCode] PRIMARY KEY CLUSTERED ([intNetworkTaxCodeId] ASC),
    CONSTRAINT [FK_tblCFNetworkTaxCode_tblCFNetwork] FOREIGN KEY ([intNetworkId]) REFERENCES [dbo].[tblCFNetwork] ([intNetworkId]) ON DELETE CASCADE
);

