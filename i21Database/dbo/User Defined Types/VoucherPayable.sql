/*
DROP PROCEDURE uspAPAddVoucherDetail
DROP PROCEDURE uspAPCreateVoucher
DROP PROCEDURE uspAPUpdateVoucherPayableQty
DROP PROCEDURE uspAPAddVoucherPayable
DROP PROCEDURE uspAPRemoveVoucherPayable
DROP FUNCTION fnAPCreateVoucherData
DROP FUNCTION fnAPValidateVoucherPayable
DROP TYPE VoucherPayable
*/
CREATE TYPE [dbo].[VoucherPayable] AS TABLE
(
    [intVoucherPayableId]			INT IDENTITY(1,1) PRIMARY KEY,
	--IF NOT PROVIDED, WE WILL GROUP THE PAYABLES BASED ON THESE FIELS
	--intEntityVendorId,intTransactionType,intLocationId,intShipToId,intShipFromId,intShipFromEntityId,intPayToAddressId,intCurrencyId,strVendorOrderNumber
	--IF PROVIDED, WE WILL VALIDATE THE VALUES OF THOSE FIELDS ABOVE IF intParitionId IS VALID TO GROUP
	[intPartitionId]				INT NULL, 
	/*Header info*/
	[intBillId]						INT NULL, --provide if adding on existing voucher
	[intEntityVendorId]				INT NOT NULL,
	/*
		1 = Voucher
		2 = Vendor Prepayment
		3 = Debit Memo
		9 = 1099 Adjustment
		11= Weight Claim
		13= Basis Advance
		14= Deferred Interest
	*/
	[intTransactionType]			INT NOT NULL,
	[intLocationId]					INT NULL, --default to current user location
	[intShipToId]					INT NULL, --will default to intLocationId
	[intShipFromId]					INT NULL, --will default to default location of vendor
	[intShipFromEntityId]			INT NULL, --will default to vendor
	[intPayToAddressId]				INT NULL, --will default to ship from
	[intCurrencyId]					INT NULL, --will default to default currency in company pref
	[dtmDate]						DATETIME NULL DEFAULT GETDATE(),
	[dtmVoucherDate]				DATETIME NULL DEFAULT GETDATE(),
	[dtmDueDate]					DATETIME NULL DEFAULT GETDATE(),
	[strVendorOrderNumber]			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strReference]					NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strLoadShipmentNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strSourceNumber]				NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL, --record number of integrated module
	[intSubCurrencyCents]			INT NULL, --default to cents of currency setup
	[intShipViaId]					INT NULL, --default to vendor location ship via if not provided
	[intTermId]						INT NULL, --default to vendor location term setup
	[strBillOfLading]				NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strCheckComment]				NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[intAPAccount]					INT NULL, --if null, we will use default setup
	/*Detail info*/
	[strMiscDescription]			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[intItemId]						INT NULL,
	[ysnSubCurrency]				INT NULL,
	[intAccountId]					INT NULL, --account to use for voucher detail, if not provided, we will use default vendor expense account
	[ysnReturn]						BIT DEFAULT(0), --this should be 1 if transaction type is 3 (Debit Memo)
	[intLineNo]						INT	NULL, --Provide value if what order we will insert the data
	[intItemLocationId]				INT NULL,
	[intStorageLocationId]			INT NULL,
	[intSubLocationId]				INT NULL,
	[dblBasis]						DECIMAL(18, 6) NOT NULL DEFAULT(0),
	[dblFutures]					DECIMAL(18, 6) NOT NULL DEFAULT(0),
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
	[intLoadShipmentCostId]			INT NULL,
	[intPaycheckHeaderId]			INT NULL,
	[intCustomerStorageId]			INT NULL,
	[intSettleStorageId]			INT NULL,
	[intCCSiteDetailId]				INT NULL,
	[intInvoiceId]					INT NULL,
	[intBuybackChargeId]			INT NULL,
	[intTicketId]					INT NULL,
	/*Quantity info*/
	[dblOrderQty]					DECIMAL(38,15) NOT NULL DEFAULT(0),	--IF NOT PROVIDED, WE WILL DEFAULT TO dblQuantityToBill
	[dblOrderUnitQty]				DECIMAL(38,20) NOT NULL DEFAULT(1),	
	[intOrderUOMId]					INT NULL,
	[dblQuantityToBill]				DECIMAL(38,15) NOT NULL DEFAULT(0),
	[dblQtyToBillUnitQty]			DECIMAL(38,20) DEFAULT(1),	
	[intQtyToBillUOMId]				INT NULL,
	/*Cost info*/
	[dblCost]						DECIMAL(38,20) NOT NULL DEFAULT(0),
	[dblOldCost]					DECIMAL(38,20) NULL,
	[dblCostUnitQty]				DECIMAL(38,20) DEFAULT(1),
	[intCostUOMId]					INT NULL,
	[intCostCurrencyId]				INT NULL,  --deprecated, use only for vyuAPReceivedItems, use ysnSubCurrency instead
	/*Weight info*/
	[dblWeight]						DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblNetWeight]					DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblWeightUnitQty]				DECIMAL(38,20) DEFAULT(1),
	[intWeightUOMId]				INT NULL,
	/*Exchange Rate info*/
	[intCurrencyExchangeRateTypeId]	INT NULL,
	[dblExchangeRate]				DECIMAL(18,6) DEFAULT(1),
	/*Tax info*/
	[intFreightTermId]				INT NULL,
	[intPurchaseTaxGroupId]			INT NULL,
	[dblTax]						DECIMAL(18,2) NOT NULL DEFAULT(0), --IF THIS IS NOT 0, PLEASE PROVIDE DATA FOR VoucherDetailTax
	/*Discount Info*/
	[dblDiscount]					DECIMAL(18,2) NOT NULL DEFAULT(0),
	[dblDetailDiscountPercent]		DECIMAL(18,2) NOT NULL DEFAULT(0),
	[ysnDiscountOverride]			BIT DEFAULT(0),
	/*Deferred Voucher*/
	[intDeferredVoucherId]			INT NULL,
	[dtmDeferredInterestDate]		DATETIME NULL,
	[dtmInterestAccruedThru]		DATETIME NULL,
	/*Prepaid Info*/
	[dblPrepayPercentage]			DECIMAL(18,6) NOT NULL DEFAULT(0),
	[intPrepayTypeId]				INT NULL,
	/*Claim info*/
	[dblNetShippedWeight]			DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblWeightLoss]					DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblFranchiseWeight]			DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblFranchiseAmount]			DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblActual]						DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblDifference]					DECIMAL(18,6) NOT NULL DEFAULT(0),
	/*1099 Info*/
	[int1099Form]					INT NULL,
	[int1099Category]				INT NULL,
	[dbl1099]						DECIMAL(18,6) NOT NULL DEFAULT(0),
	[ysnStage]						BIT DEFAULT(1)
)