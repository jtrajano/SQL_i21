﻿/*
	This will use to add voucher payable on tblAPVoucherPayable table
*/
CREATE PROCEDURE [dbo].[uspAPAddVoucherPayable]
	@voucherPayable AS VoucherPayable READONLY,
	@voucherPayableTax AS VoucherDetailTax READONLY,
	@throwError BIT = 0,
	@error NVARCHAR(MAX) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
--SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @insertedData TABLE(intOldPayableId int, intNewPayableId int);
DECLARE @SavePoint NVARCHAR(32) = 'uspAPAddVoucherPayable';
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

IF EXISTS(SELECT TOP 1 1 FROM @voucherPayable)
BEGIN
	--Make sure it has not been added yet
	IF EXISTS( 
		SELECT TOP 1 1
		FROM tblAPVoucherPayable A
		INNER JOIN @voucherPayable C
			ON C.intTransactionType = A.intTransactionType
			AND	ISNULL(C.intPurchaseDetailId,-1) = ISNULL(A.intPurchaseDetailId,-1)
			AND ISNULL(C.intContractDetailId,-1) = ISNULL(A.intContractDetailId,-1)
			AND ISNULL(C.intContractCostId,-1) = ISNULL(A.intContractCostId,-1)
			AND ISNULL(C.intScaleTicketId,-1) = ISNULL(A.intScaleTicketId,-1)
			AND ISNULL(C.intInventoryReceiptChargeId,-1) = ISNULL(A.intInventoryReceiptChargeId,-1)
			AND ISNULL(C.intInventoryReceiptItemId,-1) = ISNULL(A.intInventoryReceiptItemId,-1)
			AND ISNULL(C.intInventoryShipmentItemId,-1) = ISNULL(A.intInventoryShipmentItemId,-1)
			AND ISNULL(C.intInventoryShipmentChargeId,-1) = ISNULL(A.intInventoryShipmentChargeId,-1)
			AND ISNULL(C.intLoadShipmentDetailId,-1) = ISNULL(A.intLoadShipmentDetailId,-1)
			AND ISNULL(C.intLoadShipmentCostId,-1) = ISNULL(A.intLoadShipmentCostId,-1)
			AND ISNULL(C.intCustomerStorageId,-1) = ISNULL(A.intCustomerStorageId,-1)
			AND ISNULL(C.intItemId,-1) = ISNULL(A.intItemId,-1)
			AND ISNULL(C.intEntityVendorId,-1) = ISNULL(A.intEntityVendorId,-1)
			AND C.ysnStage = 1
		)
	BEGIN
		IF @transCount = 0
		BEGIN
			COMMIT TRANSACTION;
		END
		RETURN;
	END
	MERGE INTO tblAPVoucherPayable AS destination
	USING (
		SELECT
			[intVoucherPayableId]				=	A.intVoucherPayableId
			,[intTransactionType]				=	A.intTransactionType
			,[intEntityVendorId]				=	A.intEntityVendorId
			,[strVendorId]						=	vendor.strVendorId
			,[strName]							=	entity.strName
			,[intLocationId]					=	A.intLocationId
			,[strLocationName] 					=	loc.strLocationName
			,[intCurrencyId]					=	A.intCurrencyId
			,[strCurrency]						=	tranCur.strCurrency
			,[dtmDate]							=	A.dtmDate
			,[strReference]						=	A.strReference
			,[strSourceNumber]					=	A.strSourceNumber
			,[intPurchaseDetailId]				=	A.intPurchaseDetailId
			,[strPurchaseOrderNumber]			=	po.strPurchaseOrderNumber
			,[intContractHeaderId]				=	A.intContractHeaderId
			,[intContractDetailId]				=	A.intContractDetailId
			,[intContractSeqId]					=	A.intContractSeqId
			,[intContractCostId]				=	A.intContractCostId
			,[strContractNumber]				=	ctDetail.strContractNumber
			,[intScaleTicketId]					=	A.intScaleTicketId
			,[strScaleTicketNumber]				=	ticket.strTicketNumber
			,[intInventoryReceiptItemId]		=	A.intInventoryReceiptItemId
			,[intInventoryReceiptChargeId]		=	A.intInventoryReceiptChargeId
			,[intInventoryShipmentItemId]		=	A.intInventoryShipmentItemId
			,[intInventoryShipmentChargeId]		=	A.intInventoryShipmentChargeId
			,[intLoadShipmentId]				=	A.intLoadShipmentId
			,[intLoadShipmentDetailId]			=	A.intLoadShipmentDetailId
			,[intLoadShipmentCostId]			=	A.intLoadShipmentCostId
			,[intCustomerStorageId]				=	A.intCustomerStorageId
			,[intItemId]						=	A.intItemId
			,[strItemNo]						=	item.strItemNo
			,[intPurchaseTaxGroupId]			=	A.intPurchaseTaxGroupId
			,[strMiscDescription]				=	A.strMiscDescription
			,[dblOrderQty]						=	CASE 
													WHEN A.intTransactionType = 1 --Consider contract logic if voucher only
													THEN 
													(
														CASE 
														WHEN A.intContractDetailId > 0
														THEN ctDetail.dblDetailQuantity
														ELSE A.dblOrderQty
														END
													)
													ELSE A.dblOrderQty 
													END
			,[dblOrderUnitQty]					=	CASE 
													WHEN A.intTransactionType = 1
													THEN
													(
														CASE
														WHEN A.intContractDetailId > 0
														THEN contractItemUOM.dblUnitQty
														ELSE A.dblOrderUnitQty 
														END
													)
													ELSE A.dblOrderUnitQty
													END
			,[intOrderUOMId]					=	CASE 
													WHEN A.intTransactionType = 1
													THEN
													(
														CASE 
														WHEN A.intContractDetailId > 0
														THEN ctDetail.intItemUOMId
														ELSE A.intOrderUOMId
														END
													)
													ELSE A.intOrderUOMId 
													END
			,[strOrderUOM]						=	CASE 
													WHEN A.intTransactionType = 1
													THEN
													(
														CASE 
														WHEN A.intContractDetailId > 0
														THEN contractUOM.strUnitMeasure
														ELSE orderQtyUOM.strUnitMeasure
														END
													)
													ELSE orderQtyUOM.strUnitMeasure 
													END
			,[dblQuantityToBill]				=	A.dblQuantityToBill
			,[dblQtyToBillUnitQty]				=	A.dblQtyToBillUnitQty
			,[intQtyToBillUOMId]				=	A.intQtyToBillUOMId
			,[strQtyToBillUOM]					=	qtyUOM.strUnitMeasure
			,[dblCost]							=	CASE 
													WHEN A.intTransactionType = 1 
													THEN 
													(
														CASE 
														WHEN A.intContractDetailId > 0 AND A.dblCost = 0 AND ctDetail.dblSeqPrice > 0 AND ctDetail.intPricingTypeId <> 5
														THEN ctDetail.dblSeqPrice
														ELSE A.dblCost
														END
													)
													ELSE A.dblCost
													END
			,[dblCostUnitQty]					=	CASE 
													WHEN A.intTransactionType = 1 
													THEN
													(
														CASE 
														WHEN A.intContractDetailId > 0 AND ctDetail.intPricingTypeId <> 5
														THEN contractItemCostUOM.dblUnitQty
														ELSE A.dblCostUnitQty 
														END
													)
													ELSE A.dblCostUnitQty 
													END
			,[intCostUOMId]						=	CASE 
													WHEN A.intTransactionType = 1
													THEN 
													(
														CASE 
														WHEN A.intContractDetailId > 0 AND ctDetail.intPricingTypeId <> 5
														THEN ctDetail.intPriceItemUOMId
														ELSE A.intCostUOMId 
														END
													)
													ELSE A.intCostUOMId 
													END
			,[strCostUOM]						=	CASE 
													WHEN A.intTransactionType = 1
													THEN
													(
														CASE 
														WHEN A.intContractDetailId > 0 AND ctDetail.intPricingTypeId <> 5
														THEN contractCostUOM.strUnitMeasure
														ELSE costUOM.strUnitMeasure
														END
													)
													ELSE costUOM.strUnitMeasure END
			,[dblNetWeight]						=	A.dblNetWeight
			,[dblWeightUnitQty]					=	A.dblWeightUnitQty
			,[intWeightUOMId]					=	NULLIF(A.intWeightUOMId,0)
			,[strWeightUOM]						=	weightUOM.strUnitMeasure
			,[intCostCurrencyId]				=	CASE WHEN A.intCostCurrencyId > 0 THEN A.intCostCurrencyId ELSE A.intCurrencyId END
			,[strCostCurrency]					=	ISNULL(costCur.strCurrency, tranCur.strCurrency)
			,[dblTax]							=	A.dblTax
			,[dblDiscount]						=	A.dblDiscount
			,[intCurrencyExchangeRateTypeId]	=	A.intCurrencyExchangeRateTypeId
			,[strRateType]						=	exRates.strCurrencyExchangeRateType
			,[dblExchangeRate]					=	ISNULL(A.dblExchangeRate,-1)
			,[ysnSubCurrency]					=	ISNULL(ISNULL(A.ysnSubCurrency,costCur.ysnSubCurrency),0)
			,[intSubCurrencyCents]				=	CASE WHEN costCur.intCurrencyID > 0 AND costCur.ysnSubCurrency = 1 THEN A.intSubCurrencyCents ELSE 1 END
			,[intAccountId]						=	ISNULL(A.intAccountId, vendor.intGLAccountExpenseId)
			,[strAccountId]						=	ISNULL(accnt.strAccountId, vendorAccnt.strAccountId)
			,[strAccountDesc]					=	ISNULL(accnt.strDescription, vendorAccnt.strDescription)
			,[intShipViaId]						=	A.intShipViaId
			,[strShipVia]						=	shipVia.strShipVia
			,[intTermId]						=	CASE WHEN contractTerm.intTermID IS NOT NULL THEN contractTerm.intTermID
														ELSE A.intTermId END
			,[strTerm]							=	CASE WHEN contractTerm.intTermID IS NOT NULL THEN contractTerm.strTerm
														ELSE term.strTerm END
			,[strBillOfLading]					=	A.strBillOfLading
			,[int1099Form]						=	CASE 	WHEN patron.intEntityId IS NOT NULL 
																AND A.intItemId > 0
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN 4
															WHEN entity.str1099Form = '1099-MISC' THEN 1
															WHEN entity.str1099Form = '1099-INT' THEN 2
															WHEN entity.str1099Form = '1099-B' THEN 3
													ELSE 0
													END
			,[int1099Category]					=	CASE 	WHEN patron.intEntityId IS NOT NULL 
																AND A.intItemId > 0
																AND item.ysn1099Box3 = 1
																AND patron.ysnStockStatusQualified = 1 
															THEN 3
													ELSE
														ISNULL(category1099.int1099CategoryId,0)
													END
			,[str1099Form]						=	CASE 	WHEN patron.intEntityId IS NOT NULL 
																	AND item.ysn1099Box3 = 1
																	AND patron.ysnStockStatusQualified = 1 
																	THEN '1099 PATR'
													ELSE entity.str1099Form	END
			,[str1099Type]						=	CASE 	WHEN patron.intEntityId IS NOT NULL 
																	AND item.ysn1099Box3 = 1
																	AND patron.ysnStockStatusQualified = 1 
																	THEN 'Per-unit retain allocations'
													ELSE entity.str1099Type END
			,[ysnReturn]						=	A.ysnReturn
		FROM @voucherPayable A
		INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)
			ON A.intEntityVendorId = vendor.intEntityId
		LEFT JOIN tblGLAccount accnt ON A.intAccountId = accnt.intAccountId
		--IF NO ACCOUNT PROVIDED, USE VENDOR EXPENSE ACCOUNT
		LEFT JOIN tblGLAccount vendorAccnt ON vendor.intGLAccountExpenseId = vendorAccnt.intAccountId
		LEFT JOIN tblSMCompanyLocation loc ON loc.intCompanyLocationId = A.intLocationId
		LEFT JOIN vyuPATEntityPatron patron ON A.intEntityVendorId = patron.intEntityId
		LEFT JOIN tblAP1099Category category1099 ON entity.str1099Type = category1099.strCategory
		LEFT JOIN tblICItem item ON A.intItemId = item.intItemId
		LEFT JOIN tblSMTerm term ON term.intTermID = A.intTermId
		LEFT JOIN tblSMShipVia shipVia ON shipVia.intEntityId = A.intShipViaId
		LEFT JOIN tblSMCurrency tranCur ON A.intCurrencyId = tranCur.intCurrencyID
		LEFT JOIN tblSMCurrency costCur ON A.intCostCurrencyId = costCur.intCurrencyID
		LEFT JOIN tblSMCurrencyExchangeRateType exRates ON A.intCurrencyExchangeRateTypeId = exRates.intCurrencyExchangeRateTypeId
		LEFT JOIN tblICItemUOM itemWeightUOM ON itemWeightUOM.intItemUOMId = A.intWeightUOMId
		LEFT JOIN tblICUnitMeasure weightUOM ON weightUOM.intUnitMeasureId = itemWeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM itemCostUOM ON itemCostUOM.intItemUOMId = A.intCostUOMId
		LEFT JOIN tblICUnitMeasure costUOM ON costUOM.intUnitMeasureId = itemCostUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM itemQtyUOM ON itemQtyUOM.intItemUOMId = A.intQtyToBillUOMId
		LEFT JOIN tblICUnitMeasure qtyUOM ON qtyUOM.intUnitMeasureId = itemQtyUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM itemOrderQtyUOM ON itemOrderQtyUOM.intItemUOMId = A.intQtyToBillUOMId
		LEFT JOIN tblICUnitMeasure orderQtyUOM ON orderQtyUOM.intUnitMeasureId = itemOrderQtyUOM.intUnitMeasureId
		LEFT JOIN (tblPOPurchase po INNER JOIN tblPOPurchaseDetail poDetail ON po.intPurchaseId = poDetail.intPurchaseId)
			ON poDetail.intPurchaseDetailId = A.intPurchaseDetailId
		LEFT JOIN vyuCTContractDetailView ctDetail ON ctDetail.intContractDetailId = A.intContractDetailId
		LEFT JOIN tblICItemUOM contractItemUOM ON contractItemUOM.intItemUOMId = ctDetail.intItemUOMId
		LEFT JOIN tblICUnitMeasure contractUOM ON contractUOM.intUnitMeasureId = contractItemUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM contractItemCostUOM ON contractItemCostUOM.intItemUOMId = ctDetail.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure contractCostUOM ON contractCostUOM.intUnitMeasureId = contractItemCostUOM.intUnitMeasureId
		LEFT JOIN tblSCTicket ticket ON ticket.intTicketId = A.intScaleTicketId
		LEFT JOIN tblSMTerm contractTerm ON ctDetail.intTermId = contractTerm.intTermID
		WHERE A.ysnStage = 1
	) AS SourceData
	 ON (1=0)
	 WHEN NOT MATCHED THEN
	INSERT (
		[intEntityVendorId]		
		,[intTransactionType]		
		,[strVendorId]					
		,[strName]						
		,[intLocationId]					
		,[strLocationName] 				
		,[intCurrencyId]					
		,[strCurrency]					
		,[dtmDate]						
		,[strReference]					
		,[strSourceNumber]				
		,[intPurchaseDetailId]			
		,[strPurchaseOrderNumber]		
		,[intContractHeaderId]			
		,[intContractDetailId]			
		,[intContractSeqId]				
		,[strContractNumber]				
		,[intScaleTicketId]				
		,[strScaleTicketNumber]			
		,[intInventoryReceiptItemId]		
		,[intInventoryReceiptChargeId]	
		,[intInventoryShipmentItemId]
		,[intInventoryShipmentChargeId]
		,[intLoadShipmentId]				
		,[intLoadShipmentDetailId]		
		,[intLoadShipmentCostId]	
		,[intCustomerStorageId]	
		,[intItemId]						
		,[strItemNo]						
		,[intPurchaseTaxGroupId]			
		,[strMiscDescription]			
		,[dblOrderQty]					
		,[dblOrderUnitQty]				
		,[intOrderUOMId]					
		,[strOrderUOM]					
		,[dblQuantityToBill]				
		,[dblQtyToBillUnitQty]			
		,[intQtyToBillUOMId]				
		,[strQtyToBillUOM]				
		,[dblCost]						
		,[dblCostUnitQty]				
		,[intCostUOMId]					
		,[strCostUOM]					
		,[dblNetWeight]					
		,[dblWeightUnitQty]				
		,[intWeightUOMId]				
		,[strWeightUOM]					
		,[intCostCurrencyId]				
		,[strCostCurrency]				
		,[dblTax]		
		,[dblDiscount]
		,[intCurrencyExchangeRateTypeId]
		,[strRateType]					
		,[dblExchangeRate]						
		,[ysnSubCurrency]				
		,[intSubCurrencyCents]			
		,[intAccountId]					
		,[strAccountId]					
		,[strAccountDesc]				
		,[intShipViaId]					
		,[strShipVia]					
		,[intTermId]						
		,[strTerm]						
		,[strBillOfLading]
		,[int1099Form]
		,[int1099Category]				
		,[str1099Form]					
		,[str1099Type]							
		,[ysnReturn]			
	)
	VALUES (
		[intEntityVendorId]		
		,[intTransactionType]		
		,[strVendorId]					
		,[strName]						
		,[intLocationId]					
		,[strLocationName] 				
		,[intCurrencyId]					
		,[strCurrency]					
		,[dtmDate]						
		,[strReference]					
		,[strSourceNumber]				
		,[intPurchaseDetailId]			
		,[strPurchaseOrderNumber]		
		,[intContractHeaderId]			
		,[intContractDetailId]			
		,[intContractSeqId]				
		,[strContractNumber]				
		,[intScaleTicketId]				
		,[strScaleTicketNumber]			
		,[intInventoryReceiptItemId]		
		,[intInventoryReceiptChargeId]	
		,[intInventoryShipmentItemId]
		,[intInventoryShipmentChargeId]
		,[intLoadShipmentId]				
		,[intLoadShipmentDetailId]	
		,[intLoadShipmentCostId]		
		,[intCustomerStorageId]
		,[intItemId]						
		,[strItemNo]						
		,[intPurchaseTaxGroupId]			
		,[strMiscDescription]			
		,[dblOrderQty]					
		,[dblOrderUnitQty]				
		,[intOrderUOMId]					
		,[strOrderUOM]					
		,[dblQuantityToBill]				
		,[dblQtyToBillUnitQty]			
		,[intQtyToBillUOMId]				
		,[strQtyToBillUOM]				
		,[dblCost]						
		,[dblCostUnitQty]				
		,[intCostUOMId]					
		,[strCostUOM]					
		,[dblNetWeight]					
		,[dblWeightUnitQty]				
		,[intWeightUOMId]				
		,[strWeightUOM]					
		,[intCostCurrencyId]				
		,[strCostCurrency]				
		,[dblTax]		
		,[dblDiscount]
		,[intCurrencyExchangeRateTypeId]
		,[strRateType]					
		,[dblExchangeRate]						
		,[ysnSubCurrency]				
		,[intSubCurrencyCents]			
		,[intAccountId]					
		,[strAccountId]					
		,[strAccountDesc]				
		,[intShipViaId]					
		,[strShipVia]					
		,[intTermId]						
		,[strTerm]						
		,[strBillOfLading]
		,[int1099Form]
		,[int1099Category]				
		,[str1099Form]					
		,[str1099Type]							
		,[ysnReturn]			
	)
	OUTPUT
		SourceData.intVoucherPayableId,
		inserted.intVoucherPayableId
	INTO @insertedData;
	
	INSERT INTO tblAPVoucherPayableTaxStaging(
		[intVoucherPayableId]		
		,[intTaxGroupId]				
		,[intTaxCodeId]				
		,[intTaxClassId]				
		,[strTaxableByOtherTaxes]	
		,[strCalculationMethod]		
		,[dblRate]					
		,[intAccountId]				
		,[dblTax]					
		,[dblAdjustedTax]			
		,[ysnTaxAdjusted]			
		,[ysnSeparateOnBill]			
		,[ysnCheckOffTax]
		,[ysnTaxOnly]	
		,[ysnTaxExempt]		
	)
	SELECT
		[intVoucherPayableId]		= B.intNewPayableId
		,[intTaxGroupId]			= A.intTaxGroupId
		,[intTaxCodeId]				= A.intTaxCodeId
		,[intTaxClassId]			= A.intTaxClassId
		,[strTaxableByOtherTaxes]	= A.strTaxableByOtherTaxes
		,[strCalculationMethod]		= A.strCalculationMethod
		,[dblRate]					= A.dblRate
		,[intAccountId]				= A.intAccountId
		,[dblTax]					= A.dblTax
		,[dblAdjustedTax]			= A.dblAdjustedTax
		,[ysnTaxAdjusted]			= A.ysnTaxAdjusted
		,[ysnSeparateOnBill]		= A.ysnSeparateOnBill
		,[ysnCheckOffTax]			= A.ysnCheckOffTax
		,[ysnTaxOnly]				= A.ysnTaxOnly
		,[ysnTaxExempt]				= A.ysnTaxExempt
	FROM @voucherPayableTax A
	INNER JOIN @insertedData B
		ON B.intOldPayableId = A.intVoucherPayableId
	INNER JOIN @voucherPayable payables
		ON A.intVoucherPayableId = payables.intVoucherPayableId
		
	--IF NO TAX PROVIDED, WE WILL GENERATE TAX AND WILL USE TAX ACCOUNT
	DECLARE @ParamTable AS TABLE
		(intVoucherPayableId		INT
		,intItemId					INT
		,intVendorId				INT
		,dtmTransactionDate			DATETIME
		,dblItemCost				NUMERIC(38,20)
		,dblQuantity				NUMERIC(38,20)
		,intTaxGroupId				INT
		,intCompanyLocationId		INT
		,intVendorLocationId		INT
		,ysnIncludeExemptedCodes	BIT
		,intFreightTermId			INT
		,ysnExcludeCheckOff			BIT
		,intItemUOMId				INT)
	DECLARE @companyLocation INT = (SELECT TOP 1 intCompanyLocationId  FROM tblSMUserRoleCompanyLocationPermission)
		
	INSERT INTO @ParamTable
		(intVoucherPayableId
		,intItemId
		,intVendorId
		,dtmTransactionDate
		,dblItemCost
		,dblQuantity
		,intTaxGroupId
		,intCompanyLocationId
		,intVendorLocationId
		,ysnIncludeExemptedCodes
		,intFreightTermId
		,ysnExcludeCheckOff
		,intItemUOMId)
	SELECT
		intVoucherPayableId			= B.intNewPayableId
		,intItemId					= A.intItemId
		,intVendorId				= CASE WHEN A.intShipFromEntityId != A.intEntityVendorId THEN A.intShipFromEntityId ELSE A.intEntityVendorId END
		,dtmTransactionDate			= A.dtmDate
		,dblItemCost				= A.dblCost
		,dblQuantity				= CASE WHEN A.intWeightUOMId > 0 AND A.dblNetWeight > 0
										THEN A.dblNetWeight
										ELSE A.dblQuantityToBill END
		,intTaxGroupId				= CASE 
									WHEN A.intPurchaseTaxGroupId > 0 THEN A.intPurchaseTaxGroupId
									ELSE D.intTaxGroupId END 
		,intCompanyLocationId		= A.intShipToId
		,intVendorLocationId		= A.intShipFromId
		,ysnIncludeExemptedCodes	= 0
		,intFreightTermId			= NULL
		,ysnExcludeCheckOff			= 0
		,intItemUOMId				= CASE WHEN A.intWeightUOMId > 0 AND A.dblNetWeight > 0
										THEN A.intWeightUOMId
										ELSE A.intQtyToBillUOMId END
	FROM @voucherPayable A
	INNER JOIN @insertedData B
		ON A.intVoucherPayableId = B.intOldPayableId
	LEFT JOIN @voucherPayableTax tax
		ON A.intVoucherPayableId = tax.intVoucherPayableId
	LEFT JOIN [tblEMEntityLocation] D ON A.[intEntityVendorId] = D.intEntityId AND D.ysnDefaultLocation = 1
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = @companyLocation
	WHERE tax.intVoucherPayableId IS NULL --generate only for no tax provided

	IF EXISTS(SELECT TOP 1 1 FROM @ParamTable)
	BEGIN
		INSERT INTO tblAPVoucherPayableTaxStaging(
			[intVoucherPayableId]		
			,[intTaxGroupId]				
			,[intTaxCodeId]				
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]	
			,[strCalculationMethod]		
			,[dblRate]					
			,[intAccountId]				
			,[dblTax]					
			,[dblAdjustedTax]			
			,[ysnTaxAdjusted]			
			,[ysnSeparateOnBill]			
			,[ysnCheckOffTax]
			,[ysnTaxOnly]	
			,[ysnTaxExempt]		
		)
		SELECT
			[intVoucherPayableId]	=	A.intVoucherPayableId, 
			[intTaxGroupId]			=	Taxes.intTaxGroupId, 
			[intTaxCodeId]			=	Taxes.intTaxCodeId, 
			[intTaxClassId]			=	Taxes.intTaxClassId, 
			[strTaxableByOtherTaxes]=	Taxes.strTaxableByOtherTaxes, 
			[strCalculationMethod]	=	Taxes.strCalculationMethod, 
			[dblRate]				=	Taxes.dblRate, 
			[intAccountId]			=	Taxes.intTaxAccountId, 
			[dblTax]				=	ISNULL(Taxes.dblTax,0), 
			[dblAdjustedTax]		=	ISNULL(Taxes.dblAdjustedTax,0), 
			[ysnTaxAdjusted]		=	Taxes.ysnTaxAdjusted, 
			[ysnSeparateOnBill]		=	Taxes.ysnSeparateOnInvoice, 
			[ysnCheckOffTax]		=	Taxes.ysnCheckoffTax,
			[ysnTaxOnly]			=	Taxes.ysnTaxOnly,
			[ysnTaxExempt]			=	Taxes.ysnTaxExempt
		FROM @ParamTable A	
		CROSS APPLY fnGetItemTaxComputationForVendor
			(intItemId
			,intVendorId
			,dtmTransactionDate
			,dblItemCost
			,dblQuantity
			,intTaxGroupId
			,intCompanyLocationId
			,intVendorLocationId
			,ysnIncludeExemptedCodes
			,0 --@IncludeInvalidCodes
			,intFreightTermId
			,ysnExcludeCheckOff
			,intItemUOMId
			,NULL
			,NULL
			,NULL) Taxes
		WHERE Taxes.dblTax IS NOT NULL
	END
END

IF @transCount = 0
	BEGIN
		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION
		END
		ELSE IF (XACT_STATE()) = 1
		BEGIN
			COMMIT TRANSACTION
		END
	END		
ELSE
	BEGIN
		IF (XACT_STATE()) = -1
		BEGIN
			ROLLBACK TRANSACTION  @SavePoint
		END
	END	

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()

	IF @transCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION
			END
			ELSE IF (XACT_STATE()) = 1
			BEGIN
				COMMIT TRANSACTION
			END
		END		
	-- ELSE
	-- 	BEGIN
	-- 		IF (XACT_STATE()) = -1
	-- 		BEGIN
	-- 			ROLLBACK TRANSACTION  @SavePoint
	-- 		END
	-- 	END	

	SET @error = @ErrorMessage;
	
	IF @throwError = 1
	BEGIN
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END
END CATCH
