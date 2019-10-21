CREATE TABLE [dbo].[tblARTaxAuthority] (
    [intTaxAuthorityId] INT           IDENTITY (1, 1) NOT NULL,
    [strState]          NVARCHAR (2)  COLLATE Latin1_General_CI_AS  NOT NULL,
    [strAuthorityId1]   NVARCHAR (25)  COLLATE Latin1_General_CI_AS  NULL,
    [strAuthorityId2]   NVARCHAR (25)  COLLATE Latin1_General_CI_AS  NULL,
    [intConcurrencyId]  INT           CONSTRAINT [DF_tblARTaxAuthority_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARTaxAuthority_intTaxAuthorityId] PRIMARY KEY CLUSTERED ([intTaxAuthorityId] ASC)
);

