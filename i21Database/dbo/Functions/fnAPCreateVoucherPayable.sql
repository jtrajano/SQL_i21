CREATE FUNCTION [dbo].[fnAPCreateVoucherPayable]
(
	@payableIds AS Id READONLY
)
RETURNS @returntable TABLE
(
	[intVoucherPayableId]			INT NOT NULL,
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
	[intLoadHeaderId]				INT NULL,
	[intWeightClaimId]				INT NULL,
	[intWeightClaimDetailId]		INT NULL,
	[intPaycheckHeaderId]			INT NULL,
	[intCustomerStorageId]			INT NULL,
	[intCCSiteDetailId]				INT NULL,
	[intInvoiceId]					INT NULL,
	[intBuybackChargeId]			INT NULL,
	[intTicketId]					INT NULL,
	/*Quantity info*/
	[dblOrderQty]					DECIMAL(18,6) NOT NULL DEFAULT(0),	--IF NOT PROVIDED, WE WILL DEFAULT TO dblQuantityToBill
	[dblOrderUnitQty]				DECIMAL(38,20) NOT NULL DEFAULT(1),	
	[intOrderUOMId]					INT NULL,
	[dblQuantityToBill]				DECIMAL(18,6) NOT NULL DEFAULT(0),
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
AS
BEGIN
	INSERT @returntable
	SELECT 
		 [intVoucherPayableId]			= A.[intVoucherPayableId]
		,[intEntityVendorId]			= A.[intEntityVendorId]
		,[intTransactionType]			= A.[intTransactionType]
		,[intLocationId]				= A.[intLocationId]				
		,[intShipToId]					= A.[intShipToId]					
		,[intShipFromId]				= A.[intShipFromId]					
		,[intShipFromEntityId]			= A.[intShipFromEntityId]			
		,[intPayToAddressId]			= A.[intPayToAddressId]				
		,[intCurrencyId]				= A.[intCurrencyId]					
		,[dtmDate]						= A.[dtmDate]						
		,[dtmVoucherDate]				= A.[dtmVoucherDate]				
		,[dtmDueDate]					= dbo.fnGetDueDateBasedOnTerm(A.[dtmVoucherDate], A.[intTermId])					
		,[strVendorOrderNumber]			= A.[strVendorOrderNumber]			
		,[strReference]					= A.[strReference]			
		,[strLoadShipmentNumber]		= A.[strLoadShipmentNumber]
		,[strSourceNumber]				= A.[strSourceNumber]				
		,[intSubCurrencyCents]			= A.[intSubCurrencyCents]			
		,[intShipViaId]					= A.[intShipViaId]					
		,[intTermId]					= A.[intTermId]						
		,[strBillOfLading]				= A.[strBillOfLading]				
		,[strCheckComment]				= A.[strCheckComment]				
		,[intAPAccount]					= A.[intAPAccount]					
		/*Detail info*/					
		,[strMiscDescription]			= A.[strMiscDescription]			
		,[intItemId]					= A.[intItemId]						
		,[ysnSubCurrency]				= A.[ysnSubCurrency]				
		,[intAccountId]					= A.[intAccountId]					
		,[ysnReturn]					= A.[ysnReturn]						
		,[intLineNo]					= A.[intLineNo]						
		,[intItemLocationId]			= A.[intItemLocationId]				
		,[intStorageLocationId]			= A.[intStorageLocationId]			
		,[intSubLocationId]				= A.[intSubLocationId]				
		,[dblBasis]						= A.[dblBasis]						
		,[dblFutures]					= A.[dblFutures]					
		/*Integration fields*/			
		,[intPurchaseDetailId]			= A.[intPurchaseDetailId]			
		,[intContractHeaderId]			= A.[intContractHeaderId]			
		,[intContractCostId]			= A.[intContractCostId]				
		,[intContractSeqId]				= A.[intContractSeqId]				
		,[intContractDetailId]			= A.[intContractDetailId]			
		,[intScaleTicketId]				= A.[intScaleTicketId]				
		,[intInventoryReceiptItemId]	= A.[intInventoryReceiptItemId]		
		,[intInventoryReceiptChargeId]	= A.[intInventoryReceiptChargeId]	
		,[intInventoryShipmentItemId]	= A.[intInventoryShipmentItemId]	
		,[intInventoryShipmentChargeId]	= A.[intInventoryShipmentChargeId]	
		,[intLoadShipmentId]			= A.[intLoadShipmentId]				
		,[intLoadShipmentDetailId]		= A.[intLoadShipmentDetailId]		
		,[intLoadShipmentCostId]		= A.[intLoadShipmentCostId]
		,[intLoadHeaderId]				= A.[intLoadHeaderId]
		,[intWeightClaimId]				= A.[intWeightClaimId]		
		,[intWeightClaimDetailId]		= A.[intWeightClaimDetailId]		
		,[intPaycheckHeaderId]			= A.[intPaycheckHeaderId]			
		,[intCustomerStorageId]			= A.[intCustomerStorageId]			
		,[intCCSiteDetailId]			= A.[intCCSiteDetailId]				
		,[intInvoiceId]					= A.[intInvoiceId]					
		,[intBuybackChargeId]			= A.[intBuybackChargeId]			
		,[intTicketId]					= A.[intTicketId]					
		/*Quantity info*/				
		,[dblOrderQty]					= A.[dblOrderQty]					
		,[dblOrderUnitQty]				= A.[dblOrderUnitQty]				
		,[intOrderUOMId]				= A.[intOrderUOMId]					
		,[dblQuantityToBill]			= A.[dblQuantityToBill]				
		,[dblQtyToBillUnitQty]			= A.[dblQtyToBillUnitQty]			
		,[intQtyToBillUOMId]			= A.[intQtyToBillUOMId]				
		/*Cost info*/					
		,[dblCost]						= A.[dblCost]						
		,[dblOldCost]					= A.[dblOldCost]					
		,[dblCostUnitQty]				= A.[dblCostUnitQty]				
		,[intCostUOMId]					= A.[intCostUOMId]					
		,[intCostCurrencyId]			= A.[intCostCurrencyId]				
		/*Weight info*/					
		,[dblWeight]					= ISNULL(A.[dblWeight],0)
		,[dblNetWeight]					= A.[dblNetWeight]					
		,[dblWeightUnitQty]				= A.[dblWeightUnitQty]				
		,[intWeightUOMId]				= A.[intWeightUOMId]				
		/*Exchange Rate info*/			
		,[intCurrencyExchangeRateTypeId]= A.[intCurrencyExchangeRateTypeId]
		,[dblExchangeRate]				= A.[dblExchangeRate]
		/*Tax info*/					
		,[intPurchaseTaxGroupId]		= A.[intPurchaseTaxGroupId]	
		,[dblTax]						= A.[dblTax]
		/*Discount Info*/				
		,[dblDiscount]					= A.[dblDiscount]				
		,[dblDetailDiscountPercent]		= A.[dblDetailDiscountPercent]	
		,[ysnDiscountOverride]			= A.[ysnDiscountOverride]		
		/*Deferred Voucher*/			
		,[intDeferredVoucherId]			= A.[intDeferredVoucherId]			
		,[dtmDeferredInterestDate]		= A.[dtmDeferredInterestDate]		
		,[dtmInterestAccruedThru]		= A.[dtmInterestAccruedThru]		
		/*Prepaid Info*/				
		,[dblPrepayPercentage]			= A.[dblPrepayPercentage]
		,[intPrepayTypeId]				= A.[intPrepayTypeId]
		/*Claim info*/					
		,[dblNetShippedWeight]			= A.[dblNetShippedWeight]			
		,[dblWeightLoss]				= A.[dblWeightLoss]					
		,[dblFranchiseWeight]			= A.[dblFranchiseWeight]			
		,[dblFranchiseAmount]			= A.[dblFranchiseAmount]			
		,[dblActual]					= A.[dblActual]						
		,[dblDifference]				= A.[dblDifference]					
		/*1099 Info*/					
		,[int1099Form]					= A.[int1099Form]					
		,[int1099Category]				= A.[int1099Category]				
		,[dbl1099]						= A.[dbl1099]						
		,[ysnStage]						= 1
	FROM tblAPVoucherPayable A
	INNER JOIN @payableIds B ON A.intVoucherPayableId = B.intId
	RETURN;
END
