CREATE VIEW [dbo].[vyuSOGetSalesOrderDetail]
AS 
SELECT intSalesOrderDetailId			= SOD.intSalesOrderDetailId
     , intSalesOrderId					= SOD.intSalesOrderId
     , intItemId						= SOD.intItemId
     , strItemDescription				= SOD.strItemDescription
     , strComments						= SOD.strComments
     , intItemUOMId						= SOD.intItemUOMId
     , dblQtyShipped					= SOD.dblQtyShipped
     , dblQtyOrdered					= SOD.dblQtyOrdered
     , dblQtyAllocated					= SOD.dblQtyAllocated
     , dblDiscount						= SOD.dblDiscount
     , dblDiscountValue					= SOD.dblDiscountValue
     , dblItemTermDiscount				= SOD.dblItemTermDiscount
     , strItemTermDiscountBy			= SOD.strItemTermDiscountBy
     , dblPrice							= SOD.dblPrice
     , dblBasePrice						= SOD.dblBasePrice
     , dblUnitPrice						= SOD.dblUnitPrice
     , dblBaseUnitPrice					= SOD.dblBaseUnitPrice
     , strPricing						= SOD.strPricing
     , dblTotalTax						= SOD.dblTotalTax
     , dblBaseTotalTax					= SOD.dblBaseTotalTax
     , dblTotal							= SOD.dblTotal
     , dblBaseTotal						= SOD.dblBaseTotal
     , intAccountId						= SOD.intAccountId
     , intCOGSAccountId					= SOD.intCOGSAccountId
     , intSalesAccountId				= SOD.intSalesAccountId
     , intInventoryAccountId			= SOD.intInventoryAccountId
     , intStorageLocationId				= SOD.intStorageLocationId
     , strMaintenanceType				= SOD.strMaintenanceType
     , strFrequency						= SOD.strFrequency
     , dtmMaintenanceDate				= SOD.dtmMaintenanceDate
     , dblMaintenanceAmount				= SOD.dblMaintenanceAmount
     , dblBaseMaintenanceAmount			= SOD.dblBaseMaintenanceAmount
     , dblLicenseAmount					= SOD.dblLicenseAmount
     , dblBaseLicenseAmount				= SOD.dblBaseLicenseAmount
     , intContractHeaderId				= SOD.intContractHeaderId
     , intContractDetailId				= SOD.intContractDetailId
     , intItemContractHeaderId			= SOD.intItemContractHeaderId
     , intItemContractDetailId			= SOD.intItemContractDetailId
     , dblContractBalance				= ISNULL(CONT.dblBalance, 0)
     , dblItemContractBalance			= ISNULL(ITEMCONTRACT.dblBalance, 0)
     , dblContractAvailable				= SOD.dblContractAvailable
     , ysnBlended						= SOD.ysnBlended
     , intTaxGroupId					= SOD.intTaxGroupId
     , intRecipeId						= SOD.intRecipeId
     , intSubLocationId					= SOD.intSubLocationId
     , dblItemWeight					= SOD.dblItemWeight
     , dblStandardWeight				= SOD.dblStandardWeight
     , dblOriginalItemWeight			= SOD.dblOriginalItemWeight
     , intItemWeightUOMId				= SOD.intItemWeightUOMId
     , intCostTypeId					= SOD.intCostTypeId
     , intMarginById					= SOD.intMarginById
     , intCommentTypeId					= SOD.intCommentTypeId
     , intRecipeItemId					= SOD.intRecipeItemId
     , dblMargin						= SOD.dblMargin
     , dblRecipeQuantity				= SOD.dblRecipeQuantity
     , intCustomerStorageId				= SOD.intCustomerStorageId
     , intStorageScheduleTypeId			= SOD.intStorageScheduleTypeId
     , intConcurrencyId					= SOD.intConcurrencyId
     , strVFDDocumentNumber				= SOD.strVFDDocumentNumber
     , intCurrencyExchangeRateTypeId	= SOD.intCurrencyExchangeRateTypeId
     , intCurrencyExchangeRateId		= SOD.intCurrencyExchangeRateId
     , dblCurrencyExchangeRate			= SOD.dblCurrencyExchangeRate
     , intPriceUOMId					= SOD.intPriceUOMId
     , dblUnitQuantity					= SOD.dblUnitQuantity
     , dblOriginalQty					= SOD.dblQtyOrdered
     , dblOriginalPrice					= SOD.dblPrice
     , intOriginalItemUOMId				= SOD.intItemUOMId
     , strItemNo						= ITEM.strItemNo
     , strBundleType					= ITEM.strBundleType
     , strUnitMeasure					= ITEMUOM.strUnitMeasure
     , intUnitMeasureId					= ITEMUOM.intUnitMeasureId
     , strPriceUnitMeasure				= PRICEUOM.strUnitMeasure
     , strPriceUOM						= PRICEUOM.strUnitMeasure     
     , strWeightUnitMeasure				= WEIGHTUOM.strUnitMeasure
     , strStorageLocation				= STORAGELOCATION.strName
     , strSubLocation					= ISNULL(SUBLOCATION.strSubLocationName, '')
     , strContractNumber				= CONT.strContractNumber
     , intContractSeq					= CONT.intContractSeq
     , intPricingTypeId					= CONT.intPricingTypeId
     , strPricingType					= CONT.strPricingType
     , ysnLoad							= CONT.ysnLoad
     , strItemContractNumber			= ISNULL(ITEMCONTRACT.strItemContractNumber, '')
     , intItemContractSeq				= ITEMCONTRACT.intLineNo
     , strItemType						= ITEM.strType
     , strLotTracking					= ITEM.strLotTracking
     , strModule						= ITEM.strModule
     , strRequired						= ITEM.strRequired
     , strTaxGroup						= TAXGROUP.strTaxGroup     
     , strCurrency						= CURRENCY.strCurrency
     , dblOriginalLicenseAmount			= CASE WHEN ITEM.strType =  'Software' THEN ITEM.dblSalePrice ELSE 0 END
     , dblOriginalMaintenanceAmount		= CASE WHEN ITEM.strType = 'Software' THEN
											CASE WHEN ITEM.strMaintenanceCalculationMethod = 'Percentage' THEN 
												ITEM.dblMaintenanceRatePercentage 
											ELSE ITEM.dblMaintenanceRate END
										  ELSE 0 END
     , dblDiscountAmount				= CASE WHEN ISNULL(SOD.dblDiscount, 0) > 0 THEN ((SOD.dblQtyOrdered * SOD.dblPrice) * (SOD.dblDiscount / 100)) ELSE 0 END
     , strStorageTypeDescription		= STORAGETYPE.strStorageTypeDescription     
     , strCurrencyExchangeRateType		= CURRENCYTYPE.strCurrencyExchangeRateType	 
	 , strAddonDetailKey				= SOD.strAddonDetailKey
     , ysnAddonParent					= SOD.ysnAddonParent
	 , ysnItemContract					= SOD.ysnItemContract
	 , dblAddOnQuantity					= SOD.dblAddOnQuantity
	 , intCategoryId					= ITEM.intCategoryId
	 , strItemContractCategory			= ITEMCONTRACT.strContractCategoryId
	 , strItemContractCategoryCode		= ITEMCONTRACT.strCategory
FROM tblSOSalesOrderDetail SOD WITH(NOLOCK)
INNER JOIN (
	SELECT intSalesOrderId
		 , intCompanyLocationId 
	FROM tblSOSalesOrder WITH(NOLOCK)
) SO ON SO.intSalesOrderId = SOD.intSalesOrderId
LEFT JOIN (
	SELECT intItemId						= I.intItemId
		 , strItemNo						= I.strItemNo
		 , strBundleType					= I.strBundleType
		 , strType							= I.strType
		 , strLotTracking					= I.strLotTracking
		 , strModule						= MODULE.strModule
		 , strRequired						= I.strRequired
		 , strMaintenanceCalculationMethod	= I.strMaintenanceCalculationMethod
		 , dblSalePrice						= ISNULL(PRICING.dblSalePrice, 0)
		 , dblMaintenanceRate				= ISNULL(dblMaintenanceRate, 0)
		 , dblMaintenanceRatePercentage		= ISNULL(dblSalePrice, 0) * (ISNULL(dblMaintenanceRate, 0) / 100)
		 , intLocationId
		 , intCategoryId
	FROM tblICItem I WITH(NOLOCK) 
	LEFT JOIN tblSMModule MODULE WITH(NOLOCK) ON I.intModuleId = MODULE.intModuleId
	LEFT JOIN tblICItemLocation ITEMLOC WITH(NOLOCK) ON I.intItemId = ITEMLOC.intItemId					
	LEFT JOIN tblICItemPricing PRICING WITH(NOLOCK) ON I.intItemId = PRICING.intItemId AND ITEMLOC.intItemLocationId = PRICING.intItemLocationId
) ITEM ON SOD.intItemId = ITEM.intItemId 
      AND SO.intCompanyLocationId = ITEM.intLocationId
LEFT JOIN (
	SELECT intItemUOMId
		 , strUnitMeasure
		 , intUnitMeasureId
	FROM vyuARItemUOM WITH(NOLOCK)
) ITEMUOM ON SOD.intItemUOMId = ITEMUOM.intItemUOMId
LEFT JOIN (
	SELECT intItemUOMId
		 , strUnitMeasure
	FROM vyuARItemWUOM WITH(NOLOCK)
) PRICEUOM ON SOD.intPriceUOMId = PRICEUOM.intItemUOMId		
LEFT JOIN (
	SELECT intItemWeightUOMId
		  , strUnitMeasure 
	FROM vyuARItemWUOM WITH(NOLOCK)
) WEIGHTUOM ON SOD.intItemWeightUOMId = WEIGHTUOM.intItemWeightUOMId
LEFT JOIN (
	SELECT intStorageLocationId
		  ,	strName 
	FROM tblICStorageLocation WITH(NOLOCK)
) STORAGELOCATION ON SOD.intStorageLocationId = STORAGELOCATION.intStorageLocationId
LEFT JOIN (
	SELECT intCompanyLocationSubLocationId
		 , strSubLocationName
	FROM tblSMCompanyLocationSubLocation WITH(NOLOCK)
) SUBLOCATION ON SOD.intSubLocationId = SUBLOCATION.intCompanyLocationSubLocationId
LEFT JOIN (
	SELECT intContractDetailId
		  ,	strContractNumber
		  , intContractSeq
		  ,	intPricingTypeId
              , dblBalance
		  , strPricingType
		  ,	ysnLoad
	FROM vyuCTCustomerContract WITH(NOLOCK)
) CONT ON SOD.intContractDetailId = CONT.intContractDetailId
LEFT JOIN ( 
	SELECT	  ARICNS.intItemContractHeaderId
			, intItemContractDetailId
			, strItemContractNumber
            , intLineNo
            , dblBalance
			, strContractCategoryId
			, strCategory
	FROM vyuARItemContractNumberSearch ARICNS WITH(NOLOCK)
	LEFT JOIN tblCTItemContractDetail ICD WITH(NOLOCK) ON ARICNS.intItemContractHeaderId = ICD.intItemContractHeaderId
) ITEMCONTRACT ON (SOD.intItemContractHeaderId = ITEMCONTRACT.intItemContractHeaderId AND strContractCategoryId = 'Dollar') OR SOD.intItemContractDetailId = ITEMCONTRACT.intItemContractDetailId
LEFT JOIN (
	SELECT intTaxGroupId
		 , strTaxGroup 
	FROM tblSMTaxGroup WITH(NOLOCK)
) TAXGROUP ON SOD.intTaxGroupId = TAXGROUP.intTaxGroupId
LEFT JOIN (
	SELECT intCurrencyExchangeRateTypeId
		 , strCurrencyExchangeRateType
	FROM tblSMCurrencyExchangeRateType WITH(NOLOCK)
) CURRENCYTYPE ON SOD.intCurrencyExchangeRateTypeId = CURRENCYTYPE.intCurrencyExchangeRateTypeId
LEFT JOIN (
	SELECT intCurrencyID
		 , strCurrency
	FROM tblSMCurrency WITH(NOLOCK)
) CURRENCY ON SOD.intSubCurrencyId = CURRENCY.intCurrencyID 
LEFT JOIN (
	SELECT intStorageScheduleTypeId
		 , strStorageTypeDescription
	FROM tblGRStorageType WITH(NOLOCK)
) STORAGETYPE ON SOD.intStorageScheduleTypeId = STORAGETYPE.intStorageScheduleTypeId