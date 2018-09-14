﻿/*
DROP PROCEDURE uspAPAddVoucherDetail
DROP PROCEDURE uspAPCreateVoucher
DROP FUNCTION fnAPCreateVoucherData
DROP TYPE VoucherPayable
*/
CREATE TYPE [dbo].[VoucherPayable] AS TABLE
(
    [intVoucherPayableId]			INT IDENTITY(1,1) PRIMARY KEY,
	[intPartitionId]				INT NULL,  --FOR INTERNAL USE ONLY
	/*Header info*/
	[intBillId]						INT NULL, --provide if adding on existing voucher
	[intEntityVendorId]				INT NOT NULL,
	[intTransactionType]			INT NOT NULL,
	[intLocationId]					INT NULL, --default to current user location
	[intShipToId]					INT NULL, --will default to intLocationId
	[intShipFromId]					INT NULL, --will default to default location of vendor
	[intShipFromEntityId]			INT NULL, --will default to vendor
	[intPayToAddressId]				INT NULL, --will default to ship from
	[intCurrencyId]					INT NULL, --will default to default currency in company pref
	[dtmDate]						DATETIME DEFAULT GETDATE(),
	[strVendorOrderNumber]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strReference]					NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strSourceNumber]				NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL, --record number of integrated module
	[intSubCurrencyCents]			INT NULL, --default to cents of currency setup
	[intShipViaId]					INT NULL, --default to vendor location ship via if not provided
	[intTermId]						INT NULL, --default to vendor location term setup
	[strBillOfLading]				NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[intAPAccount]					INT NULL, --if null, we will use default setup
	/*Detail info*/
	[strMiscDescription]			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[intItemId]						INT NULL,
	[ysnSubCurrency]				INT NULL,
	[intAccountId]					INT NULL, --account to use for voucher detail, if not provided, we will use default vendor expense account
	[ysnReturn]						BIT DEFAULT(0), --this should be 1 if transaction type is 3 (Debit Memo)
	[intLineNo]						INT	NULL, --Provide value if what order we will insert the data
	[intStorageLocationId]			INT NULL,
	[dblBasis]						DECIMAL(18, 6),
	[dblFutures]					DECIMAL(18, 6),
	/*Integration fields*/
	[intPurchaseDetailId]			INT NULL,
	[intContractHeaderId]			INT NULL,
	[intContractCostId]				INT NULL,
	[intContractSeqId]				INT NULL,
	[intContractDetailId]			INT NULL,
	[intScaleTicketId]				INT NULL,
	[intInventoryReceiptItemId]		INT NULL,
	[intInventoryReceiptChargeId]	INT NULL,
	[intInventoryShipmentItemId]	INT NULL,
	[intInventoryShipmentChargeId]	INT NULL,
	[intLoadShipmentId]				INT NULL,
	[intLoadShipmentDetailId]		INT NULL,
	[intPaycheckHeaderId]			INT NULL,
	[intCustomerStorageId]			INT NULL,
	[intCCSiteDetailId]				INT NULL,
	[intInvoiceId]					INT NULL,
	[intBuybackChargeId]			INT NULL,
	/*Quantity info*/
	[dblOrderQty]					DECIMAL(18,6),	
	[dblOrderUnitQty]				DECIMAL(38,20) DEFAULT(1),	
	[intOrderUOMId]					INT NULL,
	[dblQuantityToBill]				DECIMAL(18,6),
	[dblQtyToBillUnitQty]			DECIMAL(38,20) DEFAULT(1),	
	[intQtyToBillUOMId]				INT NULL,
	/*Cost info*/
	[dblCost]						DECIMAL(38,20),
	[dblOldCost]					DECIMAL(38,20) NULL,
	[dblCostUnitQty]				DECIMAL(38,20) DEFAULT(1),
	[intCostUOMId]					INT NULL,
	[intCostCurrencyId]				INT NULL,  --deprecated, use only for vyuAPReceivedItems, use ysnSubCurrency instead
	/*Weight info*/
	[dblWeight]						DECIMAL(18,6),
	[dblNetWeight]					DECIMAL(18,6),
	[dblWeightUnitQty]				DECIMAL(38,20) DEFAULT(1),
	[intWeightUOMId]				INT NULL,
	/*Exchange Rate info*/
	[intCurrencyExchangeRateTypeId]	INT NULL,
	[dblExchangeRate]				DECIMAL(18,6) DEFAULT(1),
	/*Tax info*/
	[intPurchaseTaxGroupId]			INT NULL,
	[dblTax]						DECIMAL(18,2),
	/*Discount Info*/
	[dblDiscount]					DECIMAL(18,2),
	[dblDetailDiscountPercent]		DECIMAL(18,2),
	[ysnDiscountOverride]			BIT DEFAULT(0),
	/*Deferred Voucher*/
	[intDeferredVoucherId]			INT NULL,
	/*Prepaid Info*/
	[dblPrepayPercentage]			DECIMAL(18,6),
	[intPrepayTypeId]				INT NULL,
	/*Claim info*/
	[dblNetShippedWeight]			DECIMAL(18,6),
	[dblWeightLoss]					DECIMAL(18,6),
	[dblFranchiseWeight]			DECIMAL(18,6),
	[dblFranchiseAmount]			DECIMAL(18,6),
	[dblActual]						DECIMAL(18,6),
	[dblDifference]					DECIMAL(18,6)
)