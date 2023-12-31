﻿CREATE TABLE [dbo].[tblTRDistributionTax]
(
	[intDistributionTaxId] INT NOT NULL IDENTITY, 
    [intDistributionDetailId] INT NOT NULL, 
    [intTaxGroupMasterId] INT NOT NULL, 
    [intTaxGroupId] INT NOT NULL, 
    [intTaxCodeId] INT NOT NULL, 
    [intTaxClassId] INT NOT NULL, 
	[strTaxableByOtherTaxes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [numRate] NUMERIC(18, 6) NULL, 
    [intSalesTaxAccountId] INT NULL, 
    [dblTax] NUMERIC(18, 6) NULL, 
    [dblAdjustedTax] NUMERIC(18, 6) NULL, 
	[ysnTaxAdjusted] BIT NULL DEFAULT ((0)), 
	[ysnSeparateOnInvoice] BIT NULL DEFAULT ((0)), 
	[ysnCheckoffTax] BIT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT CONSTRAINT [DF_tblTRDistributionTax_intConcurrencyId] DEFAULT ((0)) NOT NULL,	
    CONSTRAINT [PK_tblTRDistributionTax_intDistributionTaxId] PRIMARY KEY CLUSTERED ([intDistributionTaxId] ASC),
	CONSTRAINT [FK_tblTRDistributionTax_tblTRDistributionDetail_intDistributionDetailId] FOREIGN KEY ([intDistributionDetailId]) REFERENCES [dbo].[tblTRDistributionDetail] ([intDistributionDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRDistributionTax_tblSMTaxGroupMaster_intTaxGroupMasterId] FOREIGN KEY ([intTaxGroupMasterId]) REFERENCES [dbo].[tblSMTaxGroupMaster] ([intTaxGroupMasterId]),
	CONSTRAINT [FK_tblTRDistributionTax_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblTRDistributionTax_tblSMTaxCode_intTaxCodeId] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
	CONSTRAINT [FK_tblTRDistributionTax_tblSMTaxClass_intTaxClassId] FOREIGN KEY ([intTaxClassId]) REFERENCES [dbo].[tblSMTaxClass] ([intTaxClassId]),
	CONSTRAINT [FK_tblTRDistributionTax_tblGLAccount_intSalesTaxAccountId] FOREIGN KEY ([intSalesTaxAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId])
)
