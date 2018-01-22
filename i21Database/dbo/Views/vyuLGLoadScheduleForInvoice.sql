﻿CREATE VIEW [dbo].[vyuLGLoadScheduleForInvoice]
AS
SELECT 
	 strTransactionType				= 'Load Schedule'
	,strTransactionNumber			= L.strLoadNumber
	,strShippedItemId				= 'lgis:' + CAST(L.intLoadId AS NVARCHAR(250))
	,intEntityCustomerId			= LD.intCustomerEntityId
	,intCurrencyId					= ARCC.intCurrencyId --For Review - Invoice Header Currency--
	,intSalesOrderId				= NULL
	,intSalesOrderDetailId			= NULL
	,strSalesOrderNumber			= ''
	,dtmProcessDate					= L.dtmScheduledDate
	,intInventoryShipmentId			= NULL
	,intInventoryShipmentItemId		= NULL
	,intInventoryShipmentChargeId	= NULL
	,strInventoryShipmentNumber		= NULL
	,intShipmentId					= NULL
	,strShipmentNumber				= NULL
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
	,strItemDescription				= NULL
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
	,dblDiscount					= 0
	,dblPrice						= ARCC.dblOrderPrice --For Review--
	,dblShipmentUnitPrice			= ((ARCC.dblUnitPrice) / dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), 1)) --For Review--
	,strPricing						= ''
	,strVFDDocumentNumber			= NULL
	,dblTotalTax					= 0
	,dblTotal						= ((ARCC.dblUnitPrice) / dbo.fnCalculateQtyBetweenUOM(ISNULL(ARCC.intPriceItemUOMId,LD.intItemUOMId), ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), 1))
										* dbo.fnCalculateQtyBetweenUOM(ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblNet,LD.dblNet)) --For Review--
	,intStorageLocationId			= NULL
	,intTermId						= NULL
	,intEntityShipViaId				= NULL
	,intTicketId					= NULL
	,intTaxGroupId					= NULL
	,dblGrossWt						= dbo.fnCalculateQtyBetweenUOM(ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblGross,LD.dblGross)) --For Review--
	,dblTareWt						= dbo.fnCalculateQtyBetweenUOM(ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblTare,LD.dblTare)) --For Review--
	,dblNetWt						= dbo.fnCalculateQtyBetweenUOM(ISNULL(LDL.intWeightUOMId, LD.intWeightItemUOMId), ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId), ISNULL(LDL.dblNet,LD.dblNet)) --For Review--
	,strPONumber					= ''
	,strBOLNumber					= ''
	,intSplitId						= NULL
	,intEntitySalespersonId			= NULL
	,ysnBlended						= NULL
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
	WHERE ysnPosted = 1
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
 FROM dbo.vyuARCustomerContract WITH (NOLOCK) --For Review - vyuARCustomerContract will be deleted once CT-1873 is completed--
) ARCC ON LD.intSContractDetailId = ARCC.intContractDetailId