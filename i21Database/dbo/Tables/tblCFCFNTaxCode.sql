CREATE TABLE [dbo].[tblCFCFNTaxCode] (
    [intCFNTaxCodeId]       INT            IDENTITY (1, 1) NOT NULL,
    [intCFNTaxCode]         INT            NULL,
    [strTaxCodeDescription] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strSSITaxCode]         NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT            CONSTRAINT [DF_tblCFCFNTaxCode_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFCFNTaxCode] PRIMARY KEY CLUSTERED ([intCFNTaxCodeId] ASC)
);



