CREATE VIEW [dbo].[vyuARGetSalesOrderItems]
AS 
SELECT intSalesOrderId					= SO.intSalesOrderId
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
	 , intContractSeq					= CONTRACTS.intContractSeq
	 , strContractNumber				= CONTRACTS.strContractNumber
	 , strItemContractNumber			= ITEMCONTRACTS.strItemContractNumber
	 , intItemContractSeq				= ITEMCONTRACTS.intItemContractSeq
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
		 , ITEM.strItemNo
		 , ITEM.strType
		 , ITEM.strLotTracking
		 , ITEM.strBundleType
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	LEFT JOIN (
	SELECT intItemId
		 , strDescription
		 , strItemNo
		 , strType
		 , strLotTracking
		 , strBundleType
	FROM dbo.tblICItem WITH (NOLOCK)) ITEM 
			ON SOD.intItemId = ITEM.intItemId
	WHERE SOD.dblQtyShipped < SOD.dblQtyOrdered
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
		 , strItemDescription = COMP.strDescription
		 , SOD.strPricing
		 , SOD.strVFDDocumentNumber
		 , SOD.ysnBlended
		 , SOD.ysnItemContract
		 , SOD.intTaxGroupId
		 , SOD.intStorageLocationId
		 , SOD.strAddonDetailKey
		 , SOD.ysnAddonParent
		 , SOD.dblAddOnQuantity
		 , ITEMCOMP.strItemNo
		 , ITEMCOMP.strType
		 , ITEMCOMP.strLotTracking
		 , ITEMCOMP.strBundleType
	FROM  vyuARGetItemComponents COMP
	INNER JOIN 
		dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
				ON COMP.intItemId = SOD.intItemId
	INNER JOIN (
		SELECT intItemId
			 , strDescription
			 , strItemNo
			 , strType
			 , strLotTracking
			 , strBundleType
		FROM dbo.tblICItem WITH (NOLOCK)) ITEMCOMP
			ON COMP.intComponentItemId = ITEMCOMP.intItemId
	LEFT JOIN (
		SELECT intItemId
			 , strDescription
			 , strItemNo
			 , strType
			 , strLotTracking
			 , strBundleType
		FROM dbo.tblICItem WITH (NOLOCK)) ITEM 
			ON SOD.intItemId = ITEM.intItemId
	WHERE SOD.dblQtyShipped < SOD.dblQtyOrdered
		AND SOD.intItemId IS NOT NULL
		AND ISNULL(ITEM.strBundleType, '') = 'Option'

) SODETAIL ON SO.intSalesOrderId = SODETAIL.intSalesOrderId
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) E ON SO.intEntityCustomerId = E.intEntityId
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) LOCATION ON SO.intCompanyLocationId = LOCATION.intCompanyLocationId
LEFT JOIN (
	SELECT intItemId
		 , intUnitMeasureId
		 , intItemUOMId
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) ICUOM ON SODETAIL.intItemId = ICUOM.intItemId
       AND SODETAIL.intItemUOMId = ICUOM.intItemUOMId
LEFT JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) UOM ON ICUOM.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN (
	SELECT intItemId
		 , intUnitMeasureId
		 , intItemUOMId
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) ICPUOM ON SODETAIL.intItemId = ICPUOM.intItemId
       AND SODETAIL.intItemUOMId = ICPUOM.intItemUOMId
LEFT JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) PUOM ON ICPUOM.intUnitMeasureId = PUOM.intUnitMeasureId
LEFT JOIN (
	SELECT CH.intContractHeaderId
		 , CD.intContractDetailId
		 , CD.intContractSeq
		 , strContractNumber
	FROM dbo.tblCTContractHeader CH WITH (NOLOCK)
	INNER JOIN (
		SELECT intContractHeaderId
			 , intContractDetailId
			 , intContractSeq
		FROM dbo.tblCTContractDetail WITH (NOLOCK)
	) CD ON CH.intContractHeaderId = CD.intContractHeaderId
) CONTRACTS ON SODETAIL.intContractHeaderId = CONTRACTS.intContractHeaderId
	       AND SODETAIL.intContractDetailId = CONTRACTS.intContractDetailId
LEFT JOIN (
	SELECT ICH.intItemContractHeaderId
		 , ICD.intItemContractDetailId
		 , strItemContractNumber = strContractNumber
		 , intItemContractSeq	 = intLineNo
	FROM dbo.tblCTItemContractHeader ICH WITH (NOLOCK)
	INNER JOIN (
		SELECT intItemContractHeaderId
			 , intItemContractDetailId
			 , intLineNo
		FROM dbo.tblCTItemContractDetail
	) ICD ON ICH.intItemContractHeaderId = ICD.intItemContractHeaderId
) ITEMCONTRACTS ON SODETAIL.intItemContractHeaderId = ITEMCONTRACTS.intItemContractHeaderId
	           AND SODETAIL.intItemContractDetailId = ITEMCONTRACTS.intItemContractDetailId 
LEFT OUTER JOIN (
	SELECT intCurrencyID
		 , intCent
		 , strCurrency
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) CURRENCY ON SODETAIL.intSubCurrencyId = CURRENCY.intCurrencyID
LEFT JOIN ( 
	SELECT intStorageLocationId
		 , strName 
	FROM tblICStorageLocation WITH (NOLOCK) 
) STOLOC ON STOLOC.intStorageLocationId = SODETAIL.intStorageLocationId
LEFT JOIN ( 
	SELECT intCompanyLocationSubLocationId
	     , strSubLocationName 
	FROM tblSMCompanyLocationSubLocation WITH (NOLOCK)
) SUBLOC ON SUBLOC.intCompanyLocationSubLocationId = SODETAIL.intSubLocationId
LEFT JOIN (
	SELECT intTaxGroupId
		 , strTaxGroup
	FROM dbo.tblSMTaxGroup WITH (NOLOCK)
) TAXGROUP ON TAXGROUP.intTaxGroupId = SODETAIL.intTaxGroupId
WHERE SO.strTransactionType = 'Order'
  AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
  AND SO.intSalesOrderId NOT IN (SELECT intTransactionId FROM vyuARForApprovalTransction WHERE strScreenName = 'Sales Order')
  AND SO.ysnRejected = 0
