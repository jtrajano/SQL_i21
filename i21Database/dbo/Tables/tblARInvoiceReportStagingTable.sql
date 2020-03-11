﻿CREATE TABLE [dbo].[tblARInvoiceReportStagingTable] (
    [intInvoiceId]      				INT             NULL,
	[intCompanyLocationId]				INT             NULL,
	[intEntityCustomerId]				INT				NULL,
	[intEntityUserId]					INT				NULL,
	[intInvoiceDetailId]				INT				NULL,
	[intTaxCodeId]						INT				NULL,
	[intDetailCount]					INT				NULL,
	[intRecipeId]						INT				NULL,
	[intOneLinePrintId]					INT				NULL,
	[intTruckDriverId]					INT				NULL,
	[intBillToLocationId]				INT				NULL,
	[intShipToLocationId]				INT				NULL,
	[intTermId]							INT				NULL,
	[intShipViaId]						INT				NULL,
	[intSiteId]							INT				NULL,
	[intItemId]							INT				NULL,
	[intTicketId]						INT				NULL,
	[strRequestId]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyAddress]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyInfo]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyPhoneNumber]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyEmail]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyLocation]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strType]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strLocationName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCurrency]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strBillToLocationName]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipToLocationName]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strBillTo]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipTo]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSalespersonName]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPONumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strBOLNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipVia]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTerm]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strFreightTerm]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strDeliverPickup]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceHeaderComment]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceFooterComment]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strItemNo]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strContractNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strItem]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strUnitMeasure]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strUnitMeasureSymbol]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPaid]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPosted]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceComments]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strItemComments]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPaymentComments]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerComments]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strItemType]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strVFDDocumentNumber]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strBOLNumberDetail]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strProvisional]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,	
	[strTicketNumbers]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTicketNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTicketNumberDate]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerReference]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSalesReference]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPurchaseReference]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strLoadNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strEntityContract]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSiteNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strAddonDetailKey]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTruckDriver]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSource]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strOrigin]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strComments]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strContractNo]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strContractNoSeq]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceFormat]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strBargeNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,	
	[strCommodity]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSubFormula]                     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTrailer]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSeals]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strLotNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[dblInvoiceSubtotal]				NUMERIC (18, 6)	NULL,
	[dblShipping]						NUMERIC (18, 6)	NULL,
	[dblTax]							NUMERIC (18, 6)	NULL,
	[dblInvoiceTotal]					NUMERIC (18, 6)	NULL,
	[dblAmountDue]						NUMERIC (18, 6)	NULL,
	[dblContractBalance]				NUMERIC (18, 6)	NULL,
	[dblQtyShipped]						NUMERIC (18, 6)	NULL,
	[dblQtyOrdered]						NUMERIC (18, 6)	NULL,
	[dblDiscount]						NUMERIC (18, 6)	NULL,
	[dblTotalTax]						NUMERIC (18, 6)	NULL,
	[dblPrice]							NUMERIC (18, 6)	NULL,
	[dblItemPrice]						NUMERIC (18, 6)	NULL,
	[dblTaxDetail]						NUMERIC (18, 6)	NULL,
	[dblTotalWeight]					NUMERIC (18, 6)	NULL,
	[dblTotalProvisional]				NUMERIC (18, 6)	NULL,
	[dblEstimatedPercentLeft]			NUMERIC (18, 6)	NULL,
	[dblPercentFull]					NUMERIC (18, 6)	NULL,
	[dblInvoiceTax]						NUMERIC (18, 6)	NULL,
	[dblPriceWithTax]					NUMERIC (18, 6)	NULL,
	[dblTotalPriceWithTax]				NUMERIC (18, 6)	NULL,
	[ysnHasEmailSetup]					BIT             NULL,
	[ysnHasRecipeItem]					BIT             NULL,
	[ysnHasVFDDrugItem]					BIT             NULL,
	[ysnHasProvisional]					BIT             NULL,
	[ysnPrintInvoicePaymentDetail]		BIT             NULL,
	[ysnListBundleSeparately]			BIT             NULL,
	[ysnHasAddOnItem]					BIT             NULL,
	[ysnStretchLogo]					BIT             NULL,
	[ysnHasSubFormula]					BIT             NULL,
	[dtmDate]							DATETIME		NULL,
	[dtmPostDate]						DATETIME		NULL,
	[dtmShipDate]						DATETIME		NULL,
	[dtmDueDate]						DATETIME		NULL,
	[dtmLoadedDate]						DATETIME		NULL,
	[dtmScaleDate]						DATETIME		NULL,
	[blbLogo]							VARBINARY (MAX) NULL,
	[blbSignature]						VARBINARY (MAX) NULL
);