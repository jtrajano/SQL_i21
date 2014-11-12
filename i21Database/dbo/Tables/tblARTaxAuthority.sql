CREATE TABLE [dbo].[tblARTaxAuthority] (
    [intTaxAuthorityId] INT           IDENTITY (1, 1) NOT NULL,
    [strState]          NVARCHAR (2)  NOT NULL,
    [strAuthorityId1]   NVARCHAR (25) NULL,
    [strAuthorityId2]   NVARCHAR (25) NULL,
    [intConcurrencyId]  INT           CONSTRAINT [DF_tblARTaxAuthority_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARTaxAuthority] PRIMARY KEY CLUSTERED ([intTaxAuthorityId] ASC)
);

