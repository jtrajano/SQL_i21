CREATE VIEW [dbo].[vyuAGGetWorkOrderDetail]
AS
(
	SELECT 
		WOD.intWorkOrderDetailId
		, WOD.intWorkOrderId
		, WOD.intItemId
		, ITEM.strItemNo
		, WOD.strItemDescription
		, WOD.strEPARegNo
		, WOD.intItemUOMId
		, ITEMUOM.strUnitMeasure
		, PRICEUOM.strUnitMeasure AS strPriceUnitMeasure
		, WOD.intPriceUOMId
		, WOD.dblQtyOrdered
		, WOD.dblQtyAllocated
		, WOD.dblQtyShipped
		, WOD.dblDiscount
		, WOD.dblDiscountValue
		, WOD.dblItemTermDiscount
		, WOD.strItemTermDiscountBy
		, WOD.dblPrice
		, WOD.dblBasePrice
		, WOD.dblUnitPrice
		, WOD.dblBaseUnitPrice
		, WOD.dblUnitQuantity
		, WOD.strPricing
		, WOD.dblTotalTax
		, WOD.dblBaseTotalTax
		, WOD.dblTotal
		, WOD.dblBaseTotal
		, WOD.strComments
		, CONT.intContractSeq
		, WOD.intAccountId
		, WOD.intCOGSAccountId
		, WOD.intSalesAccountId
		, WOD.intInventoryAccountId
		, WOD.intLicenseAccountId
		, WOD.intMaintenanceAccountId
		, WOD.intStorageLocationId
		, strCurrency    = CURRENCY.strCurrency 
		, strStorageLocation  = STORAGELOCATION.strName 
		, WOD.strMaintenanceType
		, WOD.strFrequency
		, WOD.dtmMaintenanceDate
		, WOD.dblMaintenanceAmount
		, WOD.dblLicenseAmount
		, WOD.dblBaseLicenseAmount
		, WOD.strVFDDocumentNumber
		, WOD.intContractHeaderId 
		, strContractNumber = CONT.strContractNumber  
		, WOD.intContractDetailId
		, WOD.intItemContractHeaderId
		, WOD.intItemContractDetailId
		, WOD.dblContractBalance
		, WOD.dblContractAvailable
		, WOD.intTaxGroupId
		, TAXGROUP.strTaxGroup
		, WOD.intRecipeId
		, WOD.intSubLocationId
		, strSubLocation     = ISNULL(SUBLOCATION.strSubLocationName, '')  
		, WOD.ysnBlended
		, WOD.dblItemWeight
		, WOD.dblOriginalItemWeight
		, WOD.intCostTypeId
		, WOD.intMarginById
		, WOD.intCommentTypeId
		, WOD.intRecipeItemId
		, WOD.dblMargin
		, WOD.dblRecipeQuantity
		, WOD.intCustomerStorageId
		, WOD.intStorageScheduleTypeId
		, strStorageTypeDescription  = STORAGETYPE.strStorageTypeDescription 
		, WOD.intSubCurrencyId
		, WOD.dblSubCurrencyRate
		, WOD.intCurrencyExchangeRateTypeId
		, strCurrencyExchangeRateType  = CURRENCYTYPE.strCurrencyExchangeRateType    
		, WOD.intCurrencyExchangeRateId
		, WOD.dblCurrencyExchangeRate
		, WOD.strAddonDetailKey
		, WOD.dblAddOnQuantity
		, WOD.ysnAddonParent
		, WOD.ysnItemContract
		, WOD.dblRate
		, WOD.strLineNo
		, WOD.intItemWeightUOMId
		, WOD.intAGQtyUOMId
		, WOD.intAGAreaUOMId
		, QTYUOM.strUnitMeasure AS strQtyUOM
		, AREAUOM.strUnitMeasure AS strAreaUOM
		, ISNULL(ITEMCONTRACT.strContractNumber, '')  AS strItemContractNumber
		, WOD.intConcurrencyId
	FROM tblAGWorkOrderDetail WOD WITH(NOLOCK)  

	LEFT JOIN (
		SELECT 
		 intItemId
		 ,strItemNo
		 FROM tblICItem WITH(NOLOCK)  
	) ITEM on ITEM.intItemId = WOD.intItemId
	LEFT JOIN (
		SELECT
		intItemUOMId
		,strUnitMeasure
		,intUnitMeasureId
		FROM vyuARItemUOM WITH(NOLOCK) 
	) ITEMUOM on ITEMUOM.intItemUOMId = WOD.intItemUOMId
	LEFT JOIN (
		 SELECT intItemUOMId  
	   , strUnitMeasure  
	FROM vyuARItemWUOM WITH(NOLOCK)  
	) PRICEUOM ON PRICEUOM.intItemUOMId = WOD.intPriceUOMId  
	LEFT JOIN (  
 SELECT intStorageLocationId  
    , strName   
 FROM tblICStorageLocation WITH(NOLOCK)  
) STORAGELOCATION ON WOD.intStorageLocationId = STORAGELOCATION.intStorageLocationId  
LEFT JOIN (  
 SELECT intContractDetailId  
    , strContractNumber  
    , intContractSeq  
    , intPricingTypeId  
              , dblBalance  
    , strPricingType  
    , ysnLoad  
 FROM vyuCTCustomerContract WITH(NOLOCK)  
) CONT ON WOD.intContractDetailId = CONT.intContractDetailId 
LEFT JOIN (  
 SELECT intTaxGroupId  
   , strTaxGroup   
 FROM tblSMTaxGroup WITH(NOLOCK)  
) TAXGROUP ON WOD.intTaxGroupId = TAXGROUP.intTaxGroupId  
LEFT JOIN (  
 SELECT intCompanyLocationSubLocationId  
   , strSubLocationName  
 FROM tblSMCompanyLocationSubLocation WITH(NOLOCK)  
) SUBLOCATION ON WOD.intSubLocationId = SUBLOCATION.intCompanyLocationSubLocationId  
LEFT JOIN (  
 SELECT intStorageScheduleTypeId  
   , strStorageTypeDescription  
 FROM tblGRStorageType WITH(NOLOCK)  
) STORAGETYPE ON WOD.intStorageScheduleTypeId = STORAGETYPE.intStorageScheduleTypeId
LEFT JOIN (  
 SELECT intCurrencyID  
   , strCurrency  
 FROM tblSMCurrency WITH(NOLOCK)  
) CURRENCY ON WOD.intSubCurrencyId = CURRENCY.intCurrencyID  
LEFT JOIN (  
 SELECT intCurrencyExchangeRateTypeId  
   , strCurrencyExchangeRateType  
 FROM tblSMCurrencyExchangeRateType WITH(NOLOCK)  
) CURRENCYTYPE ON WOD.intCurrencyExchangeRateTypeId = CURRENCYTYPE.intCurrencyExchangeRateTypeId 
LEFT JOIN (
	SELECT intAGUnitMeasureId,
			strUnitMeasure
	FROM tblAGUnitMeasure WITH(NOLOCK)  
) QTYUOM ON WOD.intAGQtyUOMId = QTYUOM.intAGUnitMeasureId
LEFT JOIN (
	SELECT intAGUnitMeasureId,
			strUnitMeasure
	FROM tblAGUnitMeasure WITH(NOLOCK)   
) AREAUOM ON WOD.intAGAreaUOMId = AREAUOM.intAGUnitMeasureId
LEFT JOIN (
	SELECT intItemContractHeaderId,
			strContractNumber
	FROM tblCTItemContractHeader WITH(NOLOCK) 
	
) ITEMCONTRACT ON WOD.intItemContractHeaderId = ITEMCONTRACT.intItemContractHeaderId
)