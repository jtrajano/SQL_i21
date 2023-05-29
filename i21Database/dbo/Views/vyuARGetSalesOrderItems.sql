CREATE VIEW [dbo].[vyuARGetSalesOrderItems]
AS 
SELECT intRowId							= CAST(ROW_NUMBER() OVER(ORDER BY SODETAIL.intSalesOrderDetailId) AS INT)
	 , intSalesOrderId					= SO.intSalesOrderId
	 , intEntityCustomerId				= SO.intEntityCustomerId
	 , intCompanyLocationId				= SO.intCompanyLocationId
     , intSalesOrderDetailId			= SODETAIL.intSalesOrderDetailId
	 , intItemId						= SODETAIL.intItemId
	 , strItemDescription				= SODETAIL.strItemDescription
	 , intItemUOMId						= SODETAIL.intItemUOMId
	 , intPriceUOMId					= SODETAIL.intPriceUOMId
	 , intContractHeaderId				= SODETAIL.intContractHeaderId
	 , intContractDetailId				= SODETAIL.intContractDetailId
	 , intItemContractHeaderId			= SODETAIL.intItemContractHeaderId
	 , intItemContractDetailId			= SODETAIL.intItemContractDetailId
	 , intRecipeId						= SODETAIL.intRecipeId
	 , intRecipeItemId					= SODETAIL.intRecipeItemId
	 , intSubLocationId					= SODETAIL.intSubLocationId
	 , intStorageLocationId				= SODETAIL.intStorageLocationId
	 , intCostTypeId					= SODETAIL.intCostTypeId
	 , intMarginById					= SODETAIL.intMarginById
	 , intCommentTypeId					= SODETAIL.intCommentTypeId
	 , intStorageScheduleTypeId			= SODETAIL.intStorageScheduleTypeId
	 , intCurrencyExchangeRateTypeId	= SODETAIL.intCurrencyExchangeRateTypeId
	 , intCurrencyExchangeRateId		= SODETAIL.intCurrencyExchangeRateId
	 , intSubCurrencyId					= SODETAIL.intSubCurrencyId
	 , dblQtyOrdered					= SODETAIL.dblQtyOrdered
	 , dblQtyShipped					= SODETAIL.dblQtyShipped
	 , dblQtyRemaining					= SODETAIL.dblQtyRemaining
	 , dblPrice							= SODETAIL.dblPrice
	 , dblBasePrice						= SODETAIL.dblBasePrice
	 , dblUnitPrice						= SODETAIL.dblUnitPrice
	 , dblBaseUnitPrice					= SODETAIL.dblBaseUnitPrice
	 , dblUnitQuantity					= SODETAIL.dblUnitQuantity
	 , dblDiscount						= SODETAIL.dblDiscount
	 , dblCurrencyExchangeRate			= SODETAIL.dblCurrencyExchangeRate
	 , dblSubCurrencyRate				= SODETAIL.dblSubCurrencyRate
	 , strSalesOrderNumber				= SO.strSalesOrderNumber
	 , strCustomerName					= E.strName
	 , strLocationName					= LOCATION.strLocationName
	 , strDescription					= SODETAIL.strItemDescription
	 , strPricing						= SODETAIL.strPricing
	 , strVFDDocumentNumber				= SODETAIL.strVFDDocumentNumber
	 , strType							= SODETAIL.strType
	 , strBundleType					= SODETAIL.strBundleType
	 , strLotTracking					= SODETAIL.strLotTracking
	 , intContractSeq					= CD.intContractSeq
	 , strContractNumber				= CH.strContractNumber
	 , strItemContractNumber			= ICH.strContractNumber
	 , intItemContractSeq				= ICD.intLineNo
	 , strItemNo						= SODETAIL.strItemNo
	 , strUnitMeasure					= UOM.strUnitMeasure
	 , strPriceUnitMeasure				= PUOM.strUnitMeasure
	 , dtmDate							= SO.dtmDate
	 , ysnBlended						= SODETAIL.ysnBlended
	 , ysnItemContract					= SODETAIL.ysnItemContract
	 , intTaxGroupId					= SODETAIL.intTaxGroupId
	 , strSubCurrency					= CURRENCY.strCurrency
	 , strStorageLocation				= STOLOC.strName
	 , strSubLocationName				= SUBLOC.strSubLocationName	
	 , strTaxGroup						= TAXGROUP.strTaxGroup
	 , strAddonDetailKey				= SODETAIL.strAddonDetailKey
	 , ysnAddonParent					= SODETAIL.ysnAddonParent
	 , dblAddOnQuantity					= SODETAIL.dblAddOnQuantity
	 , dblStandardWeight				= SODETAIL.dblStandardWeight
	 , intCustomerStorageId				= SODETAIL.intCustomerStorageId
FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
INNER JOIN (
	SELECT SOD.intSalesOrderId
		 , SOD.intSalesOrderDetailId
		 , ITEM.intItemId
		 , SOD.intItemUOMId
		 , SOD.intPriceUOMId
		 , SOD.intContractHeaderId
		 , SOD.intContractDetailId
		 , SOD.intItemContractHeaderId
		 , SOD.intItemContractDetailId
		 , SOD.intRecipeId
		 , SOD.intRecipeItemId
		 , SOD.intSubLocationId
		 , SOD.intCostTypeId
		 , SOD.intMarginById
		 , SOD.intCommentTypeId
		 , SOD.intStorageScheduleTypeId
		 , SOD.intCurrencyExchangeRateTypeId
		 , SOD.intCurrencyExchangeRateId
		 , SOD.intSubCurrencyId
		 , SOD.dblQtyOrdered
		 , SOD.dblQtyShipped
		 , dblQtyRemaining = SOD.dblQtyOrdered - SOD.dblQtyShipped
		 , SOD.dblPrice
		 , SOD.dblBasePrice
		 , SOD.dblUnitPrice
		 , SOD.dblBaseUnitPrice
		 , SOD.dblUnitQuantity
		 , SOD.dblDiscount
		 , SOD.dblCurrencyExchangeRate
		 , SOD.dblSubCurrencyRate
		 , strItemDescription = CASE WHEN ISNULL(SOD.intItemId, 0) <> 0 THEN ITEM.strDescription ELSE SOD.strItemDescription END
		 , SOD.strPricing
		 , SOD.strVFDDocumentNumber
		 , SOD.ysnBlended
		 , SOD.ysnItemContract
		 , SOD.intTaxGroupId
		 , SOD.intStorageLocationId
		 , SOD.strAddonDetailKey
		 , SOD.ysnAddonParent
		 , SOD.dblAddOnQuantity
		 , SOD.dblStandardWeight
		 , ITEM.strItemNo
		 , ITEM.strType
		 , ITEM.strLotTracking
		 , ITEM.strBundleType
		 , SOD.intCustomerStorageId
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	LEFT JOIN tblICItem ITEM WITH (NOLOCK) ON SOD.intItemId = ITEM.intItemId
	WHERE ((SOD.dblQtyOrdered > 0 AND SOD.dblQtyShipped < SOD.dblQtyOrdered) OR (SOD.dblQtyOrdered < 0 AND SOD.dblQtyShipped > SOD.dblQtyOrdered))
	  AND (SOD.intItemId IS NOT NULL OR (SOD.intItemId IS NULL AND ISNULL(SOD.strItemDescription, '') <> ''))
	  AND ISNULL(ITEM.strBundleType, '') <> 'Option'

	UNION ALL

	SELECT SOD.intSalesOrderId
		 , SOD.intSalesOrderDetailId
		 , ITEMCOMP.intItemId
		 , intItemUOMId = COMP.intUnitMeasureId
		 , intPriceUOMId = COMP.intUnitMeasureId
		 , SOD.intContractHeaderId
		 , SOD.intContractDetailId
		 , SOD.intItemContractHeaderId
		 , SOD.intItemContractDetailId
		 , SOD.intRecipeId
		 , SOD.intRecipeItemId
		 , SOD.intSubLocationId
		 , SOD.intCostTypeId
		 , SOD.intMarginById
		 , SOD.intCommentTypeId
		 , SOD.intStorageScheduleTypeId
		 , SOD.intCurrencyExchangeRateTypeId
		 , SOD.intCurrencyExchangeRateId
		 , SOD.intSubCurrencyId
		 , dblQtyOrdered = SOD.dblQtyOrdered * COMP.dblQuantity
		 , dblQtyShipped = SOD.dblQtyShipped * COMP.dblQuantity
		 , dblQtyRemaining = (SOD.dblQtyOrdered * COMP.dblQuantity) - (SOD.dblQtyShipped * COMP.dblQuantity)
		 , dblPrice = COMP.dblPrice
		 , dblBasePrice = COMP.dblPrice
		 , dblUnitPrice =  COMP.dblPrice
		 , dblBaseUnitPrice = COMP.dblPrice
		 , dblUnitQuantity = COMP.dblQuantity
		 , SOD.dblDiscount
		 , SOD.dblCurrencyExchangeRate
		 , SOD.dblSubCurrencyRate
		 , strItemDescription = ITEMCOMP.strDescription
		 , SOD.strPricing
		 , SOD.strVFDDocumentNumber
		 , SOD.ysnBlended
		 , SOD.ysnItemContract
		 , SOD.intTaxGroupId
		 , SOD.intStorageLocationId
		 , SOD.strAddonDetailKey
		 , SOD.ysnAddonParent
		 , SOD.dblAddOnQuantity
		 , SOD.dblStandardWeight
		 , ITEMCOMP.strItemNo
		 , ITEMCOMP.strType
		 , ITEMCOMP.strLotTracking
		 , ITEMCOMP.strBundleType
		 , SOD.intCustomerStorageId
	FROM  vyuARGetItemComponents COMP
	INNER JOIN tblSOSalesOrderDetail SOD WITH (NOLOCK) ON COMP.intItemId = SOD.intItemId
	INNER JOIN tblICItem ITEMCOMP WITH (NOLOCK) ON COMP.intComponentItemId = ITEMCOMP.intItemId
	INNER JOIN tblICItem ITEM WITH (NOLOCK) ON SOD.intItemId = ITEM.intItemId
	INNER JOIN tblSOSalesOrder SO WITH (NOLOCK) ON SOD.intSalesOrderId = SO.intSalesOrderId AND COMP.intCompanyLocationId = SO.intCompanyLocationId
	WHERE ((SOD.dblQtyOrdered > 0 AND SOD.dblQtyShipped < SOD.dblQtyOrdered) OR (SOD.dblQtyOrdered < 0 AND SOD.dblQtyShipped > SOD.dblQtyOrdered))
	  AND SOD.intItemId IS NOT NULL
	  AND ISNULL(ITEM.strBundleType, '') = 'Option'
) SODETAIL ON SO.intSalesOrderId = SODETAIL.intSalesOrderId
INNER JOIN tblEMEntity E WITH (NOLOCK) ON SO.intEntityCustomerId = E.intEntityId
INNER JOIN tblSMCompanyLocation [LOCATION] WITH (NOLOCK) ON SO.intCompanyLocationId = [LOCATION].intCompanyLocationId
LEFT JOIN tblICItemUOM ICUOM WITH (NOLOCK) ON SODETAIL.intItemId = ICUOM.intItemId AND SODETAIL.intItemUOMId = ICUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM WITH (NOLOCK) ON ICUOM.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN tblICItemUOM ICPUOM WITH (NOLOCK) ON SODETAIL.intItemId = ICPUOM.intItemId AND SODETAIL.intItemUOMId = ICPUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure PUOM WITH (NOLOCK) ON ICPUOM.intUnitMeasureId = PUOM.intUnitMeasureId
LEFT JOIN tblCTContractDetail CD WITH (NOLOCK) ON SODETAIL.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblCTContractHeader CH WITH (NOLOCK) ON CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblCTItemContractDetail ICD WITH (NOLOCK) ON SODETAIL.intItemContractDetailId = ICD.intItemContractDetailId
LEFT JOIN tblCTItemContractHeader ICH WITH (NOLOCK) ON ICD.intItemContractHeaderId = ICH.intItemContractHeaderId
LEFT JOIN tblSMCurrency CURRENCY WITH (NOLOCK) ON SODETAIL.intSubCurrencyId = CURRENCY.intCurrencyID
LEFT JOIN tblICStorageLocation STOLOC WITH (NOLOCK) ON STOLOC.intStorageLocationId = SODETAIL.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SUBLOC WITH (NOLOCK) ON SUBLOC.intCompanyLocationSubLocationId = SODETAIL.intSubLocationId
LEFT JOIN tblSMTaxGroup TAXGROUP WITH (NOLOCK) ON TAXGROUP.intTaxGroupId = SODETAIL.intTaxGroupId
WHERE SO.strTransactionType = 'Order'
  AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
  AND SO.intSalesOrderId NOT IN (SELECT intTransactionId FROM vyuARForApprovalTransction WHERE strScreenName = 'Sales Order')
  AND SO.ysnRejected = 0
