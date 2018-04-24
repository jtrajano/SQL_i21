﻿CREATE TABLE [dbo].[tblSOSalesOrderDetail] (
    [intSalesOrderDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intSalesOrderId]       INT             NOT NULL,
    [intItemId]             INT             NULL,
    [strItemDescription]    NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intItemUOMId]          INT             NULL,
	[intPriceUOMId]         INT             NULL,
    [dblQtyOrdered]         NUMERIC (18, 6) NULL,
    [dblQtyAllocated]       NUMERIC (18, 6) NULL,
	[dblQtyShipped]			NUMERIC (18, 6) NULL DEFAULT ((0)),
    [dblDiscount]           NUMERIC (18, 6) NULL,
	[dblItemTermDiscount]	NUMERIC (18, 6)	NULL DEFAULT ((0)),	
	[strItemTermDiscountBy]	NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
    [intTaxId]              INT             NULL,
    [dblPrice]              NUMERIC (18, 6) NULL,
	[dblBasePrice]          NUMERIC (18, 6) NULL,
	[dblUnitPrice]          NUMERIC (18, 6) NULL,
	[dblBaseUnitPrice]      NUMERIC (18, 6) NULL,
	[dblUnitQuantity]       NUMERIC (18, 6) NULL,
	[strPricing]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[dblTotalTax]           NUMERIC (18, 6) NULL,
	[dblBaseTotalTax]       NUMERIC (18, 6) NULL,
    [dblTotal]              NUMERIC (18, 6) NULL,
	[dblBaseTotal]          NUMERIC (18, 6) NULL,
    [strComments]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountId]          INT             NULL,
    [intCOGSAccountId]      INT             NULL,
    [intSalesAccountId]     INT             NULL,
    [intInventoryAccountId] INT             NULL,
	[intLicenseAccountId]	INT				NULL,
	[intMaintenanceAccountId]	INT			NULL,
	[intStorageLocationId]  INT             NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblSOSalesOrderDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	[strMaintenanceType]    NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL,
    [strFrequency]          NVARCHAR(25)    COLLATE Latin1_General_CI_AS NULL,
    [dtmMaintenanceDate]    DATETIME        NULL, 
    [dblMaintenanceAmount]  NUMERIC(18, 6)  NULL, 
	[dblBaseMaintenanceAmount]  NUMERIC(18, 6)  NULL, 
    [dblLicenseAmount]      NUMERIC(18, 6)  NULL,     
	[dblBaseLicenseAmount]  NUMERIC(18, 6)  NULL,     
	[strVFDDocumentNumber]	NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL,
    [intContractHeaderId]	INT				NULL, 
    [intContractDetailId]	INT				NULL,
	[dblContractBalance]	NUMERIC(18, 6)	NOT NULL DEFAULT 0, 
	[dblContractAvailable]	NUMERIC(18, 6)	NOT NULL DEFAULT 0, 
	[intTaxGroupId]			INT				NULL,
	[intRecipeId]			INT				NULL,
	[intSubLocationId]		INT				NULL,	
	[ysnBlended]			BIT				NULL DEFAULT 0, 
	[dblItemWeight]			NUMERIC(18, 6)	NULL DEFAULT 0,
	[dblOriginalItemWeight]	NUMERIC(18, 6)	NULL DEFAULT 0,
	[intItemWeightUOMId]	INT				NULL,    
    [intCostTypeId]			INT				NULL, 
    [intMarginById]			INT				NULL, 
    [intCommentTypeId]		INT				NULL, 
	[intRecipeItemId]		INT				NULL,
    [dblMargin]				NUMERIC(18, 6)	NULL DEFAULT 0, 
	[dblRecipeQuantity]		NUMERIC(18, 6)	NULL DEFAULT 0,
	[intCustomerStorageId]	INT				NULL,
	[intStorageScheduleTypeId]		INT				NULL,
	[intSubCurrencyId]		INT				NULL,
	[dblSubCurrencyRate]	NUMERIC(18, 6)	CONSTRAINT [DF_tblSOSalesOrderDetail_dblSubCurrencyRate] DEFAULT ((1)) NOT NULL,
	[intCurrencyExchangeRateTypeId] INT		NULL,
	[intCurrencyExchangeRateId] INT			NULL,
	[dblCurrencyExchangeRate] NUMERIC(18, 6) CONSTRAINT [DF_tblSOSalesOrderDetail_dblCurrencyExchangeRate] DEFAULT ((1)) NULL,
	[dblLastCost]			NUMERIC(18,6)	NULL,
	[dblPriceMargin]		NUMERIC(18,6)	NULL,
	[dblMarginPercentage]	NUMERIC(18,6)	NULL,
	[intEntityVendorId]		INT				NULL,
	[intPurchaseDetailId]			INT				NULL
    CONSTRAINT [PK_tblSOSalesOrderDetail] PRIMARY KEY CLUSTERED ([intSalesOrderDetailId] ASC),
    CONSTRAINT [FK_tblSOSalesOrderDetail_tblSOSalesOrder] FOREIGN KEY ([intSalesOrderId]) REFERENCES [dbo].[tblSOSalesOrder] ([intSalesOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intCOGSAccountId] FOREIGN KEY ([intCOGSAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intSalesAccountId] FOREIGN KEY ([intSalesAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intInventoryAccountId] FOREIGN KEY ([intInventoryAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intLicenseAccountId] FOREIGN KEY ([intLicenseAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGLAccount_intMaintenanceAccountId] FOREIGN KEY ([intMaintenanceAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [dbo].[tblICStorageLocation] ([intStorageLocationId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblSMCompanyLocationSubLocation_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [dbo].[tblSMCompanyLocationSubLocation] ([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblMFRecipe_intRecipeId] FOREIGN KEY ([intRecipeId]) REFERENCES [dbo].[tblMFRecipe] ([intRecipeId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblGRStorageType_intStorageScheduleTypeId] FOREIGN KEY ([intStorageScheduleTypeId]) REFERENCES [dbo].[tblGRStorageType] ([intStorageScheduleTypeId]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblSMCurrency_intSubCurrencyId] FOREIGN KEY ([intSubCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblSOSalesOrderDetail_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY ([intCurrencyExchangeRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
	--CONSTRAINT [FK_tblSOSalesOrderDetail_tblSMCurrencyExchangeRate_intCurrencyExchangeRateId] FOREIGN KEY ([intCurrencyExchangeRateId]) REFERENCES [tblSMCurrencyExchangeRate]([intCurrencyExchangeRateId]),
);