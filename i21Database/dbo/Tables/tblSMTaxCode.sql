﻿CREATE TABLE [dbo].[tblSMTaxCode]
(
    [intTaxCodeId]						INT				NOT NULL PRIMARY KEY IDENTITY, 
    [strTaxCode]						NVARCHAR(50)    COLLATE Latin1_General_CI_AS NULL, 
    [intTaxClassId]						INT				NULL, 
    [strDescription]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL, 
    [strTaxAgency]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL, 
	[intTaxAgencyId]					INT				NULL, 
    [strAddress]						NVARCHAR(150)	COLLATE Latin1_General_CI_AS NULL, 
    [strZipCode]						NVARCHAR (12)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strState]							NVARCHAR (50)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strCity]							NVARCHAR (50)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strCountry]						NVARCHAR (25)	COLLATE Latin1_General_CI_AS NOT NULL,
	[strCounty]							NVARCHAR (25)	COLLATE Latin1_General_CI_AS NULL,
	[ysnMatchTaxAddress]				BIT		NOT NULL	DEFAULT 1,
	[ysnAddToCost]						BIT		NOT NULL	DEFAULT 0,
	[intSalesTaxAccountId]				INT		NULL, 
	[intTaxAdjustmentAccountId]			INT		NULL, 
    [intPurchaseTaxAccountId]			INT		NULL, 
	[ysnExpenseAccountOverride]			BIT		NOT NULL	DEFAULT 0,
    [strTaxableByOtherTaxes]			NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS NULL,
	[ysnTaxOnly]						BIT		NOT NULL	DEFAULT 0,
	[ysnCheckoffTax]					BIT		NOT NULL	DEFAULT 0,
	[strTaxPoint]						NVARCHAR (15)	COLLATE Latin1_General_CI_AS NULL,
	[intTaxCategoryId]					INT		NULL, 
	[strStoreTaxNumber]					NVARCHAR (50)	COLLATE Latin1_General_CI_AS NULL,
	[intPayToVendorId]					INT		NULL, 
    [intPurchaseTaxExemptionAccountId]	INT		NULL, 
    [intSalesTaxExemptionAccountId]		INT		NULL, 
	[ysnIncludeInvoicePrice]			BIT		NULL DEFAULT 0,
	[ysnTexasLoadingFee]				BIT		NULL,

    [intConcurrencyId]			INT		NOT NULL	DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxCode_tblSMTaxClass] FOREIGN KEY ([intTaxClassId]) REFERENCES tblSMTaxClass(intTaxClassId),
    CONSTRAINT [FK_tblSMTaxCode_tblGLAccount_salesTax] FOREIGN KEY ([intSalesTaxAccountId]) REFERENCES tblGLAccount(intAccountId),
    CONSTRAINT [FK_tblSMTaxCode_tblGLAccount_purchaseTax] FOREIGN KEY ([intPurchaseTaxAccountId]) REFERENCES tblGLAccount(intAccountId), 
    CONSTRAINT [AK_tblSMTaxCode_strTaxCode] UNIQUE ([strTaxCode]), 
    CONSTRAINT [FK_tblSMTaxCode_tblTFTaxCategory] FOREIGN KEY ([intTaxCategoryId]) REFERENCES [tblTFTaxCategory]([intTaxCategoryId]),
	CONSTRAINT [FK_tblSMTaxCode_tblEMEntity] FOREIGN KEY ([intPayToVendorId]) REFERENCES [tblEMEntity]([intEntityId]),

    CONSTRAINT [FK_tblSMTaxCode_tblGLAccount_purchaseExemptionTax] FOREIGN KEY ([intPurchaseTaxExemptionAccountId]) REFERENCES tblGLAccount(intAccountId), 
    CONSTRAINT [FK_tblSMTaxCode_tblGLAccount_salesExemptionTax] FOREIGN KEY ([intSalesTaxExemptionAccountId]) REFERENCES tblGLAccount(intAccountId), 


)
GO

CREATE INDEX [IX_tblSMTaxCode_intTaxCategoryId] ON [dbo].[tblSMTaxCode] ([intTaxCategoryId])
GO
