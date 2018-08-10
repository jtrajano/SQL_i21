CREATE PROCEDURE [dbo].[uspAPUpdateStagingPayable](
	@vendorId INT = NULL
	,@currencyId INT = NULL
)
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @vendorId > 0
BEGIN
	DELETE A
	FROM tblAPVoucherPayable A
	WHERE A.intEntityVendorId = @vendorId AND A.intCurrencyId = @currencyId
END
ELSE
BEGIN
	DELETE A
	FROM tblAPVoucherPayable A
END

IF @vendorId > 0
BEGIN
	INSERT INTO tblAPVoucherPayable(
		[intEntityVendorId]				
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
		,[intContractCostId]		
		,[strContractNumber]				
		,[intScaleTicketId]				
		,[strScaleTicketNumber]			
		,[intInventoryReceiptItemId]		
		,[intInventoryReceiptChargeId]	
		,[intLoadShipmentId]				
		,[intLoadShipmentDetailId]		
		,[intItemId]						
		,[strItemNo]						
		,[intPurchaseTaxGroupId]
		,[strTaxGroup]		
		,[intStorageLocationId]	
		,[strStorageLocationName]	
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
	SELECT
		[intEntityVendorId]					=	A.intEntityVendorId
		,[strVendorId]						=	A.strVendorId
		,[strName]							=	A.strName
		,[intLocationId]					=	A.intLocationId
		,[strLocationName] 					=	A.strReceiptLocation
		,[intCurrencyId]					=	A.intCurrencyId
		,[strCurrency]						=	A.strCurrency
		,[dtmDate]							=	A.dtmDate
		,[strReference]						=	A.strReference
		,[strSourceNumber]					=	A.strSourceNumber
		,[intPurchaseDetailId]				=	A.intPurchaseDetailId
		,[strPurchaseOrderNumber]			=	A.strPurchaseOrderNumber
		,[intContractHeaderId]				=	A.intContractHeaderId
		,[intContractDetailId]				=	A.intContractDetailId
		,[intContractSeqId]					=	A.intContractSequence
		,[intContractCostId]				=	A.intContractChargeId
		,[strContractNumber]				=	A.strContractNumber
		,[intScaleTicketId]					=	A.intScaleTicketId
		,[strScaleTicketNumber]				=	A.strScaleTicketNumber
		,[intInventoryReceiptItemId]		=	A.intInventoryReceiptItemId
		,[intInventoryReceiptChargeId]		=	A.intInventoryReceiptItemAllocatedChargeId
		,[intLoadShipmentId]				=	A.intShipmentId
		,[intLoadShipmentDetailId]			=	A.intLoadDetailId
		,[intItemId]						=	A.intItemId
		,[strItemNo]						=	A.strItemNo
		,[intPurchaseTaxGroupId]			=	A.intTaxGroupId
		,[strTaxGroup]						=	A.strTaxGroup
		,[intStorageLocationId]				=	A.intStorageLocationId
		,[strStorageLocationName]			=	A.strStorageLocationName
		,[strMiscDescription]				=	A.strMiscDescription
		,[dblOrderQty]						=	A.dblOrderQty
		,[dblOrderUnitQty]					=	A.dblUnitQty
		,[intOrderUOMId]					=	A.intUnitMeasureId
		,[strOrderUOM]						=	A.strUOM
		,[dblQuantityToBill]				=	A.dblQuantityToBill
		,[dblQtyToBillUnitQty]				=	A.dblUnitQty
		,[intQtyToBillUOMId]				=	A.intUnitMeasureId
		,[strQtyToBillUOM]					=	A.strUOM
		,[dblCost]							=	A.dblUnitCost
		,[dblCostUnitQty]					=	A.dblCostUnitQty
		,[intCostUOMId]						=	A.intCostUOMId
		,[strCostUOM]						=	A.strCostUOM
		,[dblNetWeight]						=	A.dblNetWeight
		,[dblWeightUnitQty]					=	A.dblWeightUnitQty
		,[intWeightUOMId]					=	A.intWeightUOMId
		,[strWeightUOM]						=	A.strgrossNetUOM
		,[intCostCurrencyId]				=	A.intCostCurrencyId
		,[strCostCurrency]					=	A.strCostCurrency
		,[dblTax]							=	A.dblTax
		,[dblDiscount]						=	A.dblDiscount
		,[intCurrencyExchangeRateTypeId]	=	A.intCurrencyExchangeRateTypeId
		,[strRateType]						=	A.strRateType
		,[dblExchangeRate]					=	A.dblRate
		,[ysnSubCurrency]					=	A.ysnSubCurrency
		,[intSubCurrencyCents]				=	A.intSubCurrencyCents
		,[intAccountId]						=	A.intAccountId
		,[strAccountId]						=	A.strAccountId
		,[strAccountDesc]					=	A.strAccountDesc
		,[intShipViaId]						=	NULL
		,[strShipVia]						=	A.strShipVia
		,[intTermId]						=	A.intTermId
		,[strTerm]							=	A.strTerm
		,[strBillOfLading]					=	A.strBillOfLading
		,[int1099Form]						=	NULL
		,[int1099Category]					=	NULL
		,[str1099Form]						=	A.str1099Form
		,[str1099Type]						=	A.str1099Type
		,[ysnReturn]						=	A.ysnReturn
	FROM vyuAPReceivedItems A
	WHERE A.intEntityVendorId = @vendorId AND A.intCurrencyId = @currencyId
END
ELSE
BEGIN
	INSERT INTO tblAPVoucherPayable(
		[intEntityVendorId]				
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
		,[intContractCostId]		
		,[strContractNumber]				
		,[intScaleTicketId]				
		,[strScaleTicketNumber]			
		,[intInventoryReceiptItemId]		
		,[intInventoryReceiptChargeId]	
		,[intLoadShipmentId]				
		,[intLoadShipmentDetailId]		
		,[intItemId]						
		,[strItemNo]						
		,[intPurchaseTaxGroupId]
		,[strTaxGroup]		
		,[intStorageLocationId]	
		,[strStorageLocationName]	
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
	SELECT
		[intEntityVendorId]					=	A.intEntityVendorId
		,[strVendorId]						=	A.strVendorId
		,[strName]							=	A.strName
		,[intLocationId]					=	A.intLocationId
		,[strLocationName] 					=	A.strReceiptLocation
		,[intCurrencyId]					=	A.intCurrencyId
		,[strCurrency]						=	A.strCurrency
		,[dtmDate]							=	A.dtmDate
		,[strReference]						=	A.strReference
		,[strSourceNumber]					=	A.strSourceNumber
		,[intPurchaseDetailId]				=	A.intPurchaseDetailId
		,[strPurchaseOrderNumber]			=	A.strPurchaseOrderNumber
		,[intContractHeaderId]				=	A.intContractHeaderId
		,[intContractDetailId]				=	A.intContractDetailId
		,[intContractSeqId]					=	A.intContractSequence
		,[intContractCostId]				=	A.intContractChargeId
		,[strContractNumber]				=	A.strContractNumber
		,[intScaleTicketId]					=	A.intScaleTicketId
		,[strScaleTicketNumber]				=	A.strScaleTicketNumber
		,[intInventoryReceiptItemId]		=	A.intInventoryReceiptItemId
		,[intInventoryReceiptChargeId]		=	A.intInventoryReceiptItemAllocatedChargeId
		,[intLoadShipmentId]				=	A.intShipmentId
		,[intLoadShipmentDetailId]			=	A.intLoadDetailId
		,[intItemId]						=	A.intItemId
		,[strItemNo]						=	A.strItemNo
		,[intPurchaseTaxGroupId]			=	A.intTaxGroupId
		,[strTaxGroup]						=	A.strTaxGroup
		,[intStorageLocationId]				=	A.intStorageLocationId
		,[strStorageLocationName]			=	A.strStorageLocationName
		,[strMiscDescription]				=	A.strMiscDescription
		,[dblOrderQty]						=	A.dblOrderQty
		,[dblOrderUnitQty]					=	A.dblUnitQty
		,[intOrderUOMId]					=	A.intUnitMeasureId
		,[strOrderUOM]						=	A.strUOM
		,[dblQuantityToBill]				=	A.dblQuantityToBill
		,[dblQtyToBillUnitQty]				=	A.dblUnitQty
		,[intQtyToBillUOMId]				=	A.intUnitMeasureId
		,[strQtyToBillUOM]					=	A.strUOM
		,[dblCost]							=	A.dblUnitCost
		,[dblCostUnitQty]					=	A.dblCostUnitQty
		,[intCostUOMId]						=	A.intCostUOMId
		,[strCostUOM]						=	A.strCostUOM
		,[dblNetWeight]						=	A.dblNetWeight
		,[dblWeightUnitQty]					=	A.dblWeightUnitQty
		,[intWeightUOMId]					=	A.intWeightUOMId
		,[strWeightUOM]						=	A.strgrossNetUOM
		,[intCostCurrencyId]				=	A.intCostCurrencyId
		,[strCostCurrency]					=	A.strCostCurrency
		,[dblTax]							=	A.dblTax
		,[dblDiscount]						=	A.dblDiscount
		,[intCurrencyExchangeRateTypeId]	=	A.intCurrencyExchangeRateTypeId
		,[strRateType]						=	A.strRateType
		,[dblExchangeRate]					=	A.dblRate
		,[ysnSubCurrency]					=	A.ysnSubCurrency
		,[intSubCurrencyCents]				=	A.intSubCurrencyCents
		,[intAccountId]						=	A.intAccountId
		,[strAccountId]						=	A.strAccountId
		,[strAccountDesc]					=	A.strAccountDesc
		,[intShipViaId]						=	NULL
		,[strShipVia]						=	A.strShipVia
		,[intTermId]						=	A.intTermId
		,[strTerm]							=	A.strTerm
		,[strBillOfLading]					=	A.strBillOfLading
		,[int1099Form]						=	NULL
		,[int1099Category]					=	NULL
		,[str1099Form]						=	A.str1099Form
		,[str1099Type]						=	A.str1099Type
		,[ysnReturn]						=	A.ysnReturn
	FROM vyuAPReceivedItems A
END

END