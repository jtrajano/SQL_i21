CREATE VIEW [dbo].[vyuAPGetInventoryReceiptOtherCharge]  
AS   
SELECT DISTINCT ReceiptCharge.intInventoryReceiptChargeId  
	,ReceiptCharge.intInventoryReceiptId  
	,ReceiptCharge.intContractId  
	,ReceiptCharge.intContractDetailId  
	,ReceiptCharge.intConcurrencyId  
	,ReceiptCharge.intChargeId  
	,ReceiptCharge.intTaxGroupId  
	,ReceiptCharge.intForexRateTypeId  
	,ISNULL(ReceiptCharge.dblForexRate, 1) dblForexRate 
	,ReceiptCharge.strCostMethod  
	,CASE WHEN ReceiptCharge.dblRate <= 0 AND ReceiptCharge.strCostMethod = 'Amount' THEN ReceiptCharge.dblAmount ELSE ReceiptCharge.dblRate END dblRate  
	,CAST(ReceiptCharge.dblQuantity AS DECIMAL(18,2)) dblQuantity  
	,Contract.strContractNumber  
	,ReceiptCharge.intLoadShipmentId  
	,ReceiptCharge.intLoadShipmentCostId  
	,LoadShipment.strLoadNumber  
	,ContractDetail.intContractSeq  
	,Charge.intItemId  
	,Charge.strItemNo  
	,Charge.intOnCostTypeId  
	,Charge.strDescription  
	,Charge.strCostType  
	,Charge.intCostUOMId  
	,strCostUOM = UOM.strUnitMeasure  
	,intCostUnitMeasureId = UOM.intUnitMeasureId  
	,UOM.strUnitType  
	,ReceiptCharge.dblAmount  
	,ReceiptCharge.dblExchangeRate  
	,ReceiptCharge.intEntityVendorId  
	,Vendor.strVendorId  
	,Vendor.strName AS strVendorName  
	,SMTaxGroup.strTaxGroup  
	,ReceiptCharge.dblTax  
	,Receipt.strReceiptNumber  
	,Receipt.dtmReceiptDate  
	,Receipt.intLocationId  
	,[Location].strLocationName  
	,Receipt.strBillOfLading  
	,forexRateType.intCurrencyExchangeRateTypeId  
	,forexRateType.strCurrencyExchangeRateType  
	,intCurrencyId = ISNULL(ReceiptCharge.intCurrencyId, Receipt.intCurrencyId)   
	,Currency.strCurrency  
	,Currency.ysnSubCurrency  
	,ItemGLAccount.intAccountId  
	,strAccountDescription = ItemGLAccount.strDescription  
	,ItemGLAccount.strAccountId  
	,Receipt.intFreightTermId  
  ,FreightTerm.strFreightTerm  
  ,Receipt.intShipFromEntityId  
  ,Receipt.intShipFromId   
FROM tblICInventoryReceiptCharge ReceiptCharge  
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ReceiptCharge.intCostUOMId  
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId  
LEFT JOIN vyuICGetOtherCharges Charge ON Charge.intItemId = ReceiptCharge.intChargeId AND Charge.ysnInventoryCost = 1  
LEFT JOIN vyuAPVendor Vendor ON Vendor.[intEntityId] = ReceiptCharge.intEntityVendorId  
LEFT JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ReceiptCharge.intContractId   
LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = ReceiptCharge.intContractDetailId  
LEFT JOIN tblSMTaxGroup SMTaxGroup ON SMTaxGroup.intTaxGroupId = ReceiptCharge.intTaxGroupId  
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId  
LEFT JOIN tblSMCompanyLocation [Location] ON [Location].intCompanyLocationId = Receipt.intLocationId  
LEFT JOIN tblEMEntity ReceiptVendor ON ReceiptVendor.intEntityId = Receipt.intEntityVendorId  
LEFT JOIN tblSMCurrencyExchangeRateType forexRateType ON ReceiptCharge.intForexRateTypeId = forexRateType.intCurrencyExchangeRateTypeId  
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = ISNULL(ReceiptCharge.intCurrencyId, Receipt.intCurrencyId)   
LEFT JOIN tblLGLoad LoadShipment ON LoadShipment.intLoadId = ReceiptCharge.intLoadShipmentId  
LEFT JOIN tblLGLoadCost LoadShipmentCost ON LoadShipmentCost.intLoadId = ReceiptCharge.intLoadShipmentCostId  
LEFT JOIN tblAPBillDetail BillDetail ON ReceiptCharge.intInventoryReceiptChargeId = BillDetail.intInventoryReceiptChargeId  
LEFT JOIN tblAPVoucherPayable Payable ON Payable.intInventoryReceiptChargeId = ReceiptCharge.intInventoryReceiptChargeId
LEFT JOIN tblICItemLocation ItemLocation ON Receipt.intLocationId = ItemLocation.intLocationId AND ItemLocation.intItemId = Charge.intItemId  
LEFT JOIN tblSMFreightTerms FreightTerm ON FreightTerm.intFreightTermId = Receipt.intFreightTermId  
OUTER APPLY (  
  SELECT dbo.fnGetItemGLAccount(Charge.intItemId, ItemLocation.intItemLocationId, 'Other Charge Expense') [intAccountId]  
) ItemAccount  
OUTER APPLY (  
  SELECT intAccountId, strAccountId, strDescription FROM tblGLAccount WHERE intAccountId = ItemAccount.intAccountId  
) ItemGLAccount  
WHERE ReceiptCharge.ysnInventoryCost = 1 --AND BillDetail.intBillDetailId IS NULL 
AND Payable.intVoucherPayableId IS NULL 
AND Receipt.ysnPosted = 1