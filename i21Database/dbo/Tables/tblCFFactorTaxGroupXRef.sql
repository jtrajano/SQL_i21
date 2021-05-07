﻿CREATE TABLE [dbo].[tblCFFactorTaxGroupXRef] (
    [intFactorTaxGroupXRefId]  INT            IDENTITY (1, 1) NOT NULL,
	[intCustomerId]		INT NULL,
	[intCategoryId]		INT NULL,
	[intSiteId]		    INT NULL,
    [strFactorTaxGroup]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strAltAccount]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strState]   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFFactorTaxGroupXRef_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFFactorTaxGroupXRef] PRIMARY KEY CLUSTERED ([intFactorTaxGroupXRefId] ASC)
);
GO


CREATE UNIQUE NONCLUSTERED INDEX [tblCFFactorTaxGroupXRef_UniqueSiteCustomerStateCategory]
    ON [dbo].[tblCFFactorTaxGroupXRef]([intSiteId] ASC, [intCustomerId] ASC, [strState] ASC,  [intCategoryId] ASC);
GO

