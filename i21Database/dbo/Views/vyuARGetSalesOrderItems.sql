CREATE VIEW [dbo].[vyuARGetSalesOrderItems]
AS 
SELECT intSalesOrderId			= SO.intSalesOrderId
	 , intEntityCustomerId		= SO.intEntityCustomerId
	 , intCompanyLocationId		= SO.intCompanyLocationId
     , intSalesOrderDetailId	= SODETAIL.intSalesOrderDetailId
	 , intItemId				= SODETAIL.intItemId
	 , intItemUOMId				= SODETAIL.intItemUOMId
	 , intContractHeaderId		= SODETAIL.intContractHeaderId
	 , intContractDetailId		= SODETAIL.intContractDetailId
	 , intRecipeId				= SODETAIL.intRecipeId
	 , intSubLocationId			= SODETAIL.intSubLocationId
	 , intCostTypeId			= SODETAIL.intCostTypeId
	 , intMarginById			= SODETAIL.intMarginById
	 , intCommentTypeId			= SODETAIL.intCommentTypeId
	 , intStorageScheduleTypeId	= SODETAIL.intStorageScheduleTypeId
	 , intCurrencyExchangeRateTypeId = SODETAIL.intCurrencyExchangeRateTypeId
	 , intCurrencyExchangeRateId = SODETAIL.intCurrencyExchangeRateId
	 , intSubCurrencyId			= SODETAIL.intSubCurrencyId
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
	 , intContractSeq			= CONTRACTS.intContractSeq
	 , strContractNumber		= CONTRACTS.strContractNumber
	 , strItemNo				= ITEM.strItemNo
	 , strUnitMeasure			= ITEM.strUnitMeasure
	 , ysnBlended				= SODETAIL.ysnBlended
FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
INNER JOIN (
	SELECT intSalesOrderId
		 , intSalesOrderDetailId
		 , intItemId
		 , intItemUOMId
		 , intContractHeaderId
		 , intContractDetailId
		 , intRecipeId
		 , intSubLocationId
		 , intCostTypeId
		 , intMarginById
		 , intCommentTypeId
		 , intStorageScheduleTypeId
		 , intCurrencyExchangeRateTypeId
		 , intCurrencyExchangeRateId
		 , intSubCurrencyId
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
		 , ICUOM.intItemUOMId
		 , strDescription
		 , strItemNo
		 , strUnitMeasure
	FROM dbo.tblICItem IC WITH (NOLOCK)
	INNER JOIN (
		SELECT intItemId
			 , intUnitMeasureId
			 , intItemUOMId
		FROM dbo.tblICItemUOM WITH (NOLOCK)
	) ICUOM ON IC.intItemId = ICUOM.intItemId
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UOM ON ICUOM.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE dbo.fnIsStockTrackingItem(IC.intItemId) = 0 OR ISNULL(strLotTracking, 'No') = 'No' OR IC.strType = 'Bundle'
) ITEM ON SODETAIL.intItemId = ITEM.intItemId
      AND SODETAIL.intItemUOMId = ITEM.intItemUOMId
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