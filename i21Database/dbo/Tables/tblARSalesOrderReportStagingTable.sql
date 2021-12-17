﻿CREATE TABLE [dbo].[tblARSalesOrderReportStagingTable] (
    [intSalesOrderId]      				INT             NULL,
	[intCompanyLocationId]				INT             NULL,
	[intEntityCustomerId]				INT             NULL,
	[intCategoryId]						INT             NULL,
	[intSalesOrderDetailId]				INT             NULL,
	[intTaxCodeId]						INT             NULL,
	[intQuoteTemplateId]				INT             NULL,
	[intRecipeId]						INT             NULL,
	[intOneLinePrintId]					INT             NULL,
	[intProductTypeId]					INT             NULL,
	[intDetailCount]					INT             NULL,	
	[strCompanyName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyAddress]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCompanyInfo]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strOrderType]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCustomerName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strLocationName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCurrency]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strBOLNumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strOrderStatus]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSalesOrderNumber]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strPONumber]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipVia]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTerm]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strFreightTerm]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strItemNo]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strType]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCategoryCode]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCategoryDescription]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strContractNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strItem]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strUnitMeasure]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTemplateName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strOrganization]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strBillTo]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strShipTo]							NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSalespersonName]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strOrderedByName]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSplitName]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSOHeaderComment]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSOFooterComment]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strProductTypeDescription]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strProductTypeName]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strTaxCode]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strQuoteType]						NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCustomerComments]				NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[dblContractBalance]				NUMERIC (18, 6)	NULL,
	[dblSalesOrderSubtotal]				NUMERIC (18, 6)	NULL,
	[dblShipping]						NUMERIC (18, 6)	NULL,
	[dblTax]							NUMERIC (18, 6)	NULL,
	[dblSalesOrderTotal]				NUMERIC (18, 6)	NULL,
	[dblQtyShipped]						NUMERIC (18, 6)	NULL,
	[dblQtyOrdered]						NUMERIC (18, 6)	NULL,
	[dblDiscount]						NUMERIC (18, 6)	NULL,
	[dblTotalTax]						NUMERIC (18, 6)	NULL,
	[dblPrice]							NUMERIC (18, 6)	NULL,
	[dblItemPrice]						NUMERIC (18, 6)	NULL,
	[dblCategoryTotal]					NUMERIC (18, 6)	NULL,
	[dblProductTotal]					NUMERIC (18, 6)	NULL,
	[dblTaxDetail]						NUMERIC (18, 6)	NULL,
	[dblTotalWeight]					NUMERIC (18, 6)	NULL,
	[dblTotalDiscount]					NUMERIC (18, 6)	NULL,
	[ysnHasEmailSetup]					BIT             NULL,
	[ysnHasRecipeItem]					BIT             NULL,
	[ysnDisplayTitle]					BIT             NULL,
	[ysnListBundleSeparately]			BIT             NULL,
	[dtmDate]							DATETIME		NULL,
	[dtmDueDate]						DATETIME		NULL,
	[dtmExpirationDate]					DATETIME		NULL,
	[blbLogo]							VARBINARY (MAX) NULL
);