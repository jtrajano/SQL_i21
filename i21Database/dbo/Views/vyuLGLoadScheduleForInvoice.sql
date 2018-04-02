CREATE VIEW [dbo].[vyuLGLoadScheduleForInvoice]
AS
SELECT 
	 strTransactionType				= 'Load Schedule'
	,strTransactionNumber			= L.strLoadNumber
	,strShippedItemId				= 'lgis:' + CAST(L.intLoadId AS NVARCHAR(250))
	,intEntityCustomerId			= LD.intCustomerEntityId
	,intCurrencyId					= ARCC.intCurrencyId --For Review - Invoice Header Currency--
	,intSalesOrderId				= NULL
	,intSalesOrderDetailId			= NULL
	,strSalesOrderNumber			= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,dtmProcessDate					= L.dtmScheduledDate
	,intInventoryShipmentId			= NULL
	,intInventoryShipmentItemId		= NULL
	,intInventoryShipmentChargeId	= NULL
	,strInventoryShipmentNumber		= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,intShipmentId					= NULL
	,strShipmentNumber				= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,intLoadId						= L.intLoadId
	,intLoadDetailId				= LD.intLoadDetailId
	,intLotId						= NULL
	,strLoadNumber					= L.strLoadNumber
	,intRecipeItemId				= NULL
	,intContractHeaderId			= ARCC.intContractHeaderId --For Review--
	,intContractDetailId			= ISNULL(ARCC.intContractDetailId, LD.intPContractDetailId) --For Review--
	,intCompanyLocationId			= LD.intSCompanyLocationId
	,intShipToLocationId			= NULL
	,intFreightTermId				= ARCC.intFreightTermId
	,intItemId						= LD.intItemId
	,strItemDescription				= ICI.[strDescription]
	,intItemUOMId					= ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId) --For Review--
	,intOrderUOMId					= ARCC.intOrderUOMId
	,intShipmentItemUOMId			= ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId) --For Review--
	,intWeightUOMId					= LD.intWeightItemUOMId --For Review--
	,dblWeight						= dbo.fnCalculateQtyBetweenUOM(LD.intWeightItemUOMId, ISNULL(ARCC.intItemUOMId, LD.intItemUOMId), 1.000000) --For Review--
	,dblQtyShipped					= dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.intOrderUOMId, LD.intWeightItemUOMId), ISNULL(ARCC.intItemUOMId, LD.intItemUOMId), LD.dblQuantity) --For Review--
	,dblQtyOrdered					= ISNULL(LD.dblQuantity, 0) --For Review--
	,dblShipmentQuantity			= dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, ARCC.intItemUOMId), ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LD.dblQuantity, ARCC.dblShipQuantity)) --For Review--
	,dblShipmentQtyShippedTotal		= dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, ARCC.intItemUOMId), ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LD.dblQuantity, ARCC.dblShipQuantity)) --For Review--
	,dblQtyRemaining				= dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intItemUOMId, ARCC.intItemUOMId), ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LD.dblQuantity, ARCC.dblShipQuantity)) --For Review--
	,dblDiscount					= 0.0000000
	,dblPrice						= ARCC.dblOrderPrice --For Review--
	,dblShipmentUnitPrice			= ((ARCC.dblUnitPrice) / dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), 1)) --For Review--
	,strPricing						= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,strVFDDocumentNumber			= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,dblTotalTax					= 0.000000
	,dblTotal						= ((ARCC.dblUnitPrice) / dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), 1))
										* dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId,LDL.intWeightUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblNet,LD.dblNet)) --For Review--
	,intStorageLocationId			= NULL
	,intTermId						= NULL
	,intEntityShipViaId				= NULL
	,intTicketId					= NULL
	,intTaxGroupId					= NULL
	,dblGrossWt						= dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblGross,LD.dblGross)) --For Review--
	,dblTareWt						= dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblTare,LD.dblTare)) --For Review--
	,dblNetWt						= dbo.fnCalculateQtyBetweenUOM(ISNULL(LD.intWeightItemUOMId, LDL.intWeightUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblNet,LD.dblNet)) --For Review--
	,strPONumber					= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,strBOLNumber					= CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	,intSplitId						= NULL
	,intEntitySalespersonId			= NULL
	,ysnBlended						= CAST(0 AS BIT)
	,intRecipeId					= NULL
	,intSubLocationId				= NULL
	,intCostTypeId					= NULL
	,intMarginById					= NULL
	,intCommentTypeId				= NULL
	,dblMargin						= NULL
	,dblRecipeQuantity				= NULL
	,intStorageScheduleTypeId		= NULL
	,intDestinationGradeId			= ARCC.intDestinationGradeId
	,intDestinationWeightId			= ARCC.intDestinationWeightId
	,intCurrencyExchangeRateTypeId	= ARCC.intCurrencyExchangeRateTypeId --For Review--
	,intCurrencyExchangeRateId		= ARCC.intCurrencyExchangeRateId --For Review--
	,dblCurrencyExchangeRate		= ARCC.dblCurrencyExchangeRate --For Review--
	,intSubCurrencyId				= ARCC.intSubCurrencyId --For Review--
	,dblSubCurrencyRate				= ARCC.dblSubCurrencyRate --For Review--
FROM (
	SELECT intLoadId
		 , strLoadNumber
		 , dtmScheduledDate
	FROM dbo.tblLGLoad WITH (NOLOCK)
	WHERE ysnPosted = 1 --AND intShipmentStatus = 6
) L
JOIN (
	SELECT intLoadId
		 , intLoadDetailId
		 , intCustomerEntityId
		 , intItemId
		 , intSContractDetailId
		 , intItemUOMId
		 , intWeightItemUOMId
		 , intSCompanyLocationId
		 , intPContractDetailId
		 , dblQuantity
		 , dblGross
		 , dblTare
		 , dblNet
	FROM 
		dbo.tblLGLoadDetail WITH (NOLOCK)		

) LD ON L.intLoadId  = LD.intLoadId
LEFT JOIN (
	SELECT intLoadDetailId
		 , intWeightUOMId
		 , dblGross	= SUM(dblGross)
		 , dblTare	= SUM(dblTare)
		 , dblNet	= SUM(dblNet)
	FROM dbo.tblLGLoadDetailLot WITH (NOLOCK) 
	GROUP BY
		 intLoadDetailId
		,intWeightUOMId
) LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
--LEFT JOIN (
--	SELECT intLotId
--		 , intStorageLocationId
--	FROM dbo.tblICLot WITH (NOLOCK)
--) LO ON LO.intLotId = LDL.intLotId
--LEFT OUTER JOIN (
--	SELECT intInventoryShipmentItemId
--		 , intRecipeItemId
--		 , strShipmentNumber
--		 , intLoadDetailId
--	 FROM tblARInvoiceDetail WITH (NOLOCK)
--	 WHERE ISNULL(intLoadDetailId, 0) = 0
--) ARID ON LDL.intLoadDetailId = ARID.intLoadDetailId
LEFT OUTER JOIN (
SELECT intContractHeaderId
	 , intContractDetailId
	 , strContractNumber
	 , intContractSeq
	 , intDestinationGradeId
	 , strDestinationGrade
	 , intDestinationWeightId
	 , strDestinationWeight
	 , intSubCurrencyId
	 , intCurrencyId
	 , strUnitMeasure
	 , intOrderUOMId
	 , intPriceItemUOMId
	 , intItemUOMId
	 , strOrderUnitMeasure
	 , intItemWeightUOMId	 
	 , dblCashPrice
	 , dblOrderPrice
	 , dblUnitPrice
	 , dblDetailQuantity
	 , intFreightTermId			 
	 , dblShipQuantity
	 , dblOrderQuantity
	 , dblSubCurrencyRate
	 , intCurrencyExchangeRateTypeId
	 , strCurrencyExchangeRateType
	 , intCurrencyExchangeRateId
	 , dblCurrencyExchangeRate
 FROM dbo.vyuCTCustomerContract WITH (NOLOCK) --For Review - vyuARCustomerContract will be deleted once CT-1873 is completed--
) ARCC ON LD.intSContractDetailId = ARCC.intContractDetailId
INNER JOIN
	(SELECT [intItemId], [strItemNo], [strDescription] FROM tblICItem WITH(NOLOCK)) ICI
		ON LD.[intItemId] = ICI.[intItemId]