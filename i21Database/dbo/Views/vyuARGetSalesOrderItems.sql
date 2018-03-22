﻿CREATE VIEW [dbo].[vyuARGetSalesOrderItems]
AS 
SELECT intSalesOrderId			= SO.intSalesOrderId
	 , intEntityCustomerId		= SO.intEntityCustomerId
	 , intCompanyLocationId		= SO.intCompanyLocationId
     , intSalesOrderDetailId	= SODETAIL.intSalesOrderDetailId
	 , intItemId				= SODETAIL.intItemId
	 , strItemDescription		= SODETAIL.strItemDescription
	 , intItemUOMId				= SODETAIL.intItemUOMId
	 , intContractHeaderId		= SODETAIL.intContractHeaderId
	 , intContractDetailId		= SODETAIL.intContractDetailId
	 , intRecipeId				= SODETAIL.intRecipeId
	 , intRecipeItemId			= SODETAIL.intRecipeItemId
	 , intSubLocationId			= SODETAIL.intSubLocationId
	 , intCostTypeId			= SODETAIL.intCostTypeId
	 , intMarginById			= SODETAIL.intMarginById
	 , intCommentTypeId			= SODETAIL.intCommentTypeId
	 , intStorageScheduleTypeId	= SODETAIL.intStorageScheduleTypeId
	 , intCurrencyExchangeRateTypeId = SODETAIL.intCurrencyExchangeRateTypeId
	 , intCurrencyExchangeRateId = SODETAIL.intCurrencyExchangeRateId
	 , intSubCurrencyId			= SODETAIL.intSubCurrencyId
	 , dblQtyOrdered			= SODETAIL.dblQtyOrdered
	 , dblQtyShipped			= SODETAIL.dblQtyShipped
	 , dblQtyRemaining			= SODETAIL.dblQtyRemaining
	 , dblPrice					= SODETAIL.dblPrice
	 , dblBasePrice				= SODETAIL.dblBasePrice
	 , dblDiscount				= SODETAIL.dblDiscount
	 , dblCurrencyExchangeRate	= SODETAIL.dblCurrencyExchangeRate
	 , dblSubCurrencyRate		= SODETAIL.dblSubCurrencyRate
	 , strSalesOrderNumber		= SO.strSalesOrderNumber
	 , strCustomerName			= E.strName
	 , strLocationName			= LOCATION.strLocationName
	 , strDescription			= CASE WHEN ISNULL(SODETAIL.intItemId, 0) <> 0 THEN ITEM.strDescription ELSE SODETAIL.strItemDescription END
	 , strPricing				= SODETAIL.strPricing
	 , strVFDDocumentNumber		= SODETAIL.strVFDDocumentNumber
	 , strType					= ITEM.strType
	 , strBundleType			= ITEM.strBundleType
	 , intContractSeq			= CONTRACTS.intContractSeq
	 , strContractNumber		= CONTRACTS.strContractNumber
	 , strItemNo				= ITEM.strItemNo
	 , strUnitMeasure			= UOM.strUnitMeasure
	 , dtmDate					= SO.dtmDate
	 , ysnBlended				= SODETAIL.ysnBlended
	 , intTaxGroupId			= SODETAIL.intTaxGroupId
FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
INNER JOIN (
	SELECT intSalesOrderId
		 , intSalesOrderDetailId
		 , intItemId
		 , intItemUOMId
		 , intContractHeaderId
		 , intContractDetailId
		 , intRecipeId
		 , intRecipeItemId
		 , intSubLocationId
		 , intCostTypeId
		 , intMarginById
		 , intCommentTypeId
		 , intStorageScheduleTypeId
		 , intCurrencyExchangeRateTypeId
		 , intCurrencyExchangeRateId
		 , intSubCurrencyId
		 , dblQtyOrdered
		 , dblQtyShipped
		 , dblQtyRemaining = dblQtyOrdered - dblQtyShipped
		 , dblPrice
		 , dblBasePrice
		 , dblDiscount
		 , dblCurrencyExchangeRate
		 , dblSubCurrencyRate
		 , strItemDescription
		 , strPricing
		 , strVFDDocumentNumber
		 , ysnBlended
		 , intTaxGroupId
	FROM dbo.tblSOSalesOrderDetail WITH (NOLOCK)
	WHERE dblQtyShipped < dblQtyOrdered
	 AND (ISNULL(intItemId, 0) <> 0 OR ISNULL(strItemDescription, '') <> '') 
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
	SELECT IC.intItemId
		 , strDescription
		 , strItemNo
		 , strType
		 , strLotTracking
		 , strBundleType
	FROM dbo.tblICItem IC WITH (NOLOCK)	
) ITEM ON SODETAIL.intItemId = ITEM.intItemId
LEFT JOIN (
	SELECT intItemId
		 , intUnitMeasureId
		 , intItemUOMId
	FROM dbo.tblICItemUOM WITH (NOLOCK)
) ICUOM ON SODETAIL.intItemId = ICUOM.intItemId
       AND SODETAIL.intItemUOMId = ICUOM.intItemUOMId
INNER JOIN (
	SELECT intUnitMeasureId
		 , strUnitMeasure
	FROM dbo.tblICUnitMeasure WITH (NOLOCK)
) UOM ON ICUOM.intUnitMeasureId = UOM.intUnitMeasureId
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
WHERE SO.strTransactionType = 'Order'
  AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')
  AND ((dbo.fnIsStockTrackingItem(SODETAIL.intItemId) = 0 OR ISNULL(strLotTracking, 'No') = 'No') OR (SODETAIL.intItemId IS NULL AND ISNULL(SODETAIL.strItemDescription, '') <> ''))