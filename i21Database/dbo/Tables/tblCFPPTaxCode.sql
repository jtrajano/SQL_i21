CREATE TABLE [dbo].[tblCFPPTaxCode] (
    [intPPTaxCodeId]   INT            IDENTITY (1, 1) NOT NULL,
    [strPPTaxCode]     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strSSITaxCode]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFPPTaxCode_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFPPTaxCode] PRIMARY KEY CLUSTERED ([intPPTaxCodeId] ASC)
);



