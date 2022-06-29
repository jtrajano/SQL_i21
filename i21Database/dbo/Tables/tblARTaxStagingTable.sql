﻿CREATE TABLE [dbo].[tblARTaxStagingTable]
(
	[intEntityCustomerId]				INT				NULL,
	[intEntitySalespersonId]			INT				NULL,
	[intCurrencyId]						INT				NULL,
	[intCompanyLocationId]				INT				NULL,
	[intShipToLocationId]				INT				NULL,
	[intTaxCodeId]						INT				NULL,
	[intTaxClassId]						INT				NULL,
	[intInvoiceId]						INT				NULL,
	[intInvoiceDetailId]				INT				NULL,
	[intItemId]							INT				NULL,
	[intItemUOMId]						INT				NULL,
	[intTaxGroupId]						INT				NULL,
	[intTonnageTaxUOMId]				INT				NULL,
	[dtmDate]							DATETIME		NULL,
	[strInvoiceNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCalculationMethod]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strDisplayName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSalespersonNumber]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSalespersonName]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSalespersonDisplayName]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyAddress]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCurrency]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCurrencyDescription]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxGroup]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxAgency]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxCodeDescription]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCountry]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strState]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCounty]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCity]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxClass]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSalesTaxAccount]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPurchaseTaxAccount]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strLocationName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipToLocationAddress]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strItemNo]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCategoryCode]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxReportType]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strFederalTaxId]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strStateTaxId]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[dblRate]							NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblUnitPrice]						NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblQtyShipped]						NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblAdjustedTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblTax]							NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblTotalAdjustedTax]				NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblTotalTax]						NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblTaxDifference]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblTaxAmount]						NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblNonTaxable]						NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblTaxable]						NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblTotalSales]						NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblTaxCollected]					NUMERIC(18, 6)	NULL DEFAULT 0,	
	[dblQtyTonShipped]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblCheckOffTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblCitySalesTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblCityExciseTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblCountySalesTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblCountyExciseTax]				NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblFederalExciseTax]				NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblFederalLustTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblFederalOilSpillTax]				NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblFederalOtherTax]				NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblLocalOtherTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblPrepaidSalesTax]				NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblStateExciseTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblStateOtherTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblStateSalesTax]					NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblTonnageTax]						NUMERIC(18, 6)	NULL DEFAULT 0,
	[ysnTaxExempt]						BIT				NULL DEFAULT ((0)), 
    [blbCompanyLogo]					VARBINARY(MAX) NULL,	
	[strLogoType]						NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL
)
