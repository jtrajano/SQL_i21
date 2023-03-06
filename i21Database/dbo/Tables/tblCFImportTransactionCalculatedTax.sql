﻿CREATE TABLE [dbo].[tblCFImportTransactionCalculatedTax](
	[intTransactionId] INT NULL,
	[intTransactionDetailTaxId] INT NULL,
	[intInvoiceDetailId] INT NULL,
	[intTransactionDetailId] INT NULL,
	[intTaxGroupMasterId] INT NULL,
	[intTaxGroupId] INT NULL,
	[intTaxCodeId] INT NULL,
	[intTaxClassId] INT NULL,
	[strTaxableByOtherTaxes] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
	[strCalculationMethod] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
	[dblRate] numeric(18, 10) NULL,
	[dblBaseRate] numeric(18, 10) NULL,
	[dblTax] numeric(18, 10) NULL,
	[dblAdjustedTax] numeric(18, 10) NULL,
	[dblExemptionPercent] numeric(18, 10) NULL,
	[intSalesTaxAccountId] INT NULL,
	[intTaxAccountId] INT NULL,
	[ysnSeparateOnInvoice]bit NULL,
	[ysnCheckoffTax]bit NULL,
	[strTaxCode] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
	[ysnTaxExempt]bit NULL,
	[ysnInvalidSetup]bit NULL,
	[strTaxGroup] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
	[ysnInvalid]bit NULL,
	[strReason] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
	[strNotes] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
	[strTaxExemptReason] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
	[dblCalculatedTax] numeric(18, 10) NULL,
	[dblOriginalTax] numeric(18, 10) NULL,
	[dblExemptionAmount] numeric(18, 6) NULL,
	[ysnTaxOnly]bit NULL,
	[intLineItemId] INT NULL,
	[strGUID] nvarchar(max) COLLATE Latin1_General_CI_AS  NULL,
	[intUserId] INT NULL
) 