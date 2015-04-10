CREATE TABLE [dbo].[tblCFPPTaxCode] (
    [intPPTaxCodeId]   INT            NULL,
    [strPPTaxCode]     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strSSITaxCode]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFPPTaxCode_intConcurrencyId] DEFAULT ((1)) NULL
);

