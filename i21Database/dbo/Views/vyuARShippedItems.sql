CREATE VIEW [dbo].[vyuARShippedItems]
AS
SELECT id							= NEWID()
	 , strTransactionType			= SHIPPEDITEMS.strTransactionType
	 , strTransactionNumber			= SHIPPEDITEMS.strTransactionNumber
	 , strShippedItemId				= SHIPPEDITEMS.strShippedItemId
	 , intEntityCustomerId			= SHIPPEDITEMS.intEntityCustomerId
	 , intCurrencyId				= ISNULL(ISNULL(SHIPPEDITEMS.intCurrencyId, CUSTOMER.intCurrencyId), DEFAULTCURRENCY.intDefaultCurrencyId)
	 , strCustomerName				= CUSTOMER.strName
	 , intSalesOrderId				= SHIPPEDITEMS.intSalesOrderId
	 , intSalesOrderDetailId		= SHIPPEDITEMS.intSalesOrderDetailId
	 , strSalesOrderNumber			= SHIPPEDITEMS.strSalesOrderNumber
	 , dtmProcessDate				= SHIPPEDITEMS.dtmProcessDate
	 , intInventoryShipmentId		= SHIPPEDITEMS.intInventoryShipmentId
	 , intInventoryShipmentItemId	= SHIPPEDITEMS.intInventoryShipmentItemId
	 , intInventoryShipmentChargeId	= SHIPPEDITEMS.intInventoryShipmentChargeId
	 , strInventoryShipmentNumber	= SHIPPEDITEMS.strInventoryShipmentNumber	
	 , intShipmentId				= SHIPPEDITEMS.intShipmentId
	 , strShipmentNumber			= SHIPPEDITEMS.strShipmentNumber
	 , intLoadId					= SHIPPEDITEMS.intLoadId
	 , intLoadDetailId				= SHIPPEDITEMS.intLoadDetailId
	 , intLotId						= SHIPPEDITEMS.intLotId
	 , strLoadNumber				= SHIPPEDITEMS.strLoadNumber
	 , intRecipeItemId 				= SHIPPEDITEMS.intRecipeItemId
	 , intContractHeaderId			= SHIPPEDITEMS.intContractHeaderId
	 , strContractNumber			= CUSTOMERCONTRACT.strContractNumber
	 , intContractDetailId			= SHIPPEDITEMS.intContractDetailId
	 , intContractSeq				= CUSTOMERCONTRACT.intContractSeq
	 , intPricingTypeId				= CUSTOMERCONTRACT.intPricingTypeId
	 , intCompanyLocationId			= SHIPPEDITEMS.intCompanyLocationId
	 , strLocationName				= COMPANYLOCATION.strLocationName
	 , intShipToLocationId			= SHIPPEDITEMS.intShipToLocationId
	 , intFreightTermId				= SHIPPEDITEMS.intFreightTermId
	 , intItemId					= SHIPPEDITEMS.intItemId
	 , strItemNo					= ITEM.strItemNo 
	 , strItemDescription			= ISNULL(SHIPPEDITEMS.strItemDescription, ITEM.strDescription)
	 , intItemUOMId					= SHIPPEDITEMS.intItemUOMId
	 , strUnitMeasure				= ITEMUOM.strUnitMeasure
	 , intPriceUOMId				= SHIPPEDITEMS.intPriceUOMId	 
	 , strPriceUnitMeasure			= ITEMPRICEUOM.strUnitMeasure
	 , intOrderUOMId				= SHIPPEDITEMS.intOrderUOMId
	 , strOrderUnitMeasure			= ITEMORDERUOM.strUnitMeasure
	 , intShipmentItemUOMId			= SHIPPEDITEMS.intItemUOMId	 
	 , strShipmentUnitMeasure		= ITEMUOM.strUnitMeasure
	 , dblQtyShipped				= SHIPPEDITEMS.dblQtyShipped	
	 , dblQtyOrdered				= SHIPPEDITEMS.dblQtyOrdered 
	 , dblShipmentQuantity			= SHIPPEDITEMS.dblShipmentQuantity
	 , dblShipmentQtyShippedTotal	= SHIPPEDITEMS.dblShipmentQtyShippedTotal
	 , dblQtyRemaining				= SHIPPEDITEMS.dblQtyRemaining
	 , dblPriceUOMQuantity			= SHIPPEDITEMS.dblPriceUOMQuantity
	 , dblDiscount					= SHIPPEDITEMS.dblDiscount
	 , dblPrice						= SHIPPEDITEMS.dblPrice
	 , dblUnitPrice					= SHIPPEDITEMS.dblUnitPrice
	 , dblShipmentUnitPrice			= SHIPPEDITEMS.dblShipmentUnitPrice
	 , strPricing					= SHIPPEDITEMS.strPricing
	 , strVFDDocumentNumber			= SHIPPEDITEMS.strVFDDocumentNumber
	 , dblTotalTax					= SHIPPEDITEMS.dblTotalTax
	 , dblTotal						= SHIPPEDITEMS.dblTotal
	 , intStorageLocationId			= SHIPPEDITEMS.intStorageLocationId
	 , strStorageLocationName		= STORAGELOCATION.strName
	 , strSubLocationName			= SUBLOCATION.strSubLocationName
	 , intTermID					= SHIPPEDITEMS.intTermId
	 , strTerm						= TERM.strTerm
	 , intEntityShipViaId			= SHIPPEDITEMS.intEntityShipViaId
	 , strShipVia					= SHIPVIA.strShipVia
	 , strTicketNumber				= SCALETICKET.strTicketNumber
	 , strCustomerReference			= SCALETICKET.strCustomerReference
	 , intTicketId					= SHIPPEDITEMS.intTicketId
	 , intTaxGroupId				= SHIPPEDITEMS.intTaxGroupId
	 , strTaxGroup					= TAXGROUP.strTaxGroup	 
	 , dblWeight					= SHIPPEDITEMS.dblWeight
	 , intWeightUOMId				= SHIPPEDITEMS.intWeightUOMId
	 , strWeightUnitMeasure			= WEIGHTUOM.strUnitMeasure
	 , dblGrossWt					= SHIPPEDITEMS.dblGrossWt
	 , dblTareWt					= SHIPPEDITEMS.dblTareWt
	 , dblNetWt						= SHIPPEDITEMS.dblNetWt
	 , strPONumber					= SHIPPEDITEMS.strPONumber
	 , strBOLNumber					= SHIPPEDITEMS.strBOLNumber
	 , intSplitId					= SHIPPEDITEMS.intSplitId
	 , intEntitySalespersonId		= SHIPPEDITEMS.intEntitySalespersonId
	 , strSalespersonName			= SALESPERSON.strName
	 , ysnBlended					= SHIPPEDITEMS.ysnBlended
	 , intRecipeId					= SHIPPEDITEMS.intRecipeId
	 , intSubLocationId				= SHIPPEDITEMS.intSubLocationId
	 , intOwnershipType				= ISNULL(SHIPPEDITEMS.intOwnershipType,0)
	 , intCostTypeId				= SHIPPEDITEMS.intCostTypeId
	 , intMarginById				= SHIPPEDITEMS.intMarginById
	 , intCommentTypeId				= SHIPPEDITEMS.intCommentTypeId
	 , dblMargin					= SHIPPEDITEMS.dblMargin
	 , dblRecipeQuantity			= SHIPPEDITEMS.dblRecipeQuantity
	 , intStorageScheduleTypeId		= SHIPPEDITEMS.intStorageScheduleTypeId
	 , intDestinationGradeId		= ISNULL(SHIPPEDITEMS.intDestinationGradeId, CUSTOMERCONTRACT.intDestinationGradeId)
	 , strDestinationGrade			= ISNULL(DESTINATIONGRADE.strDestinationGrade, CUSTOMERCONTRACT.strDestinationGrade)
	 , intDestinationWeightId		= ISNULL(SHIPPEDITEMS.intDestinationWeightId, CUSTOMERCONTRACT.intDestinationWeightId)
	 , strDestinationWeight			= ISNULL(DESTINATIONWEIGHT.strDestinationWeight, CUSTOMERCONTRACT.strDestinationWeight)
	 , intCurrencyExchangeRateTypeId= SHIPPEDITEMS.intCurrencyExchangeRateTypeId
	 , strCurrencyExchangeRateType	= CURRENCYERT.strCurrencyExchangeRateType
	 , intCurrencyExchangeRateId	= SHIPPEDITEMS.intCurrencyExchangeRateId
	 , dblCurrencyExchangeRate		= SHIPPEDITEMS.dblCurrencyExchangeRate
	 , intSubCurrencyId				= SHIPPEDITEMS.intSubCurrencyId
	 , dblSubCurrencyRate			= ISNULL(ISNULL(SHIPPEDITEMS.dblSubCurrencyRate, CAST(CURRENCY.intCent AS NUMERIC(18,6))), 1.000000)
	 , strSubCurrency				= CURRENCY.strCurrency
	 , intBookId					= SHIPPEDITEMS.intBookId
	 , intSubBookId					= SHIPPEDITEMS.intSubBookId
	 , strBook						= BOOK.strBook
	 , strSubBook					= SUBBOOK.strSubBook
	 , ysnShowForShipment			= isnull(SCALETICKET.ysnShowForShipment, 1)
FROM (
	--IS FROM SO
	SELECT strTransactionType				= 'Inventory Shipment' COLLATE Latin1_General_CI_AS
		 , strTransactionNumber				= SHP.strShipmentNumber
		 , strShippedItemId					= 'icis:' + CAST(SHP.intInventoryShipmentId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
		 , intEntityCustomerId				= SO.intEntityCustomerId
		 , intCurrencyId					= ISNULL(SHP.intCurrencyId, SO.intCurrencyId)
		 , intSalesOrderId					= SO.intSalesOrderId
		 , intSalesOrderDetailId			= SOD.intSalesOrderDetailId
		 , strSalesOrderNumber				= SO.strSalesOrderNumber
		 , dtmProcessDate					= SHP.dtmShipDate
		 , intInventoryShipmentId			= SHP.intInventoryShipmentId
		 , intInventoryShipmentItemId		= SHP.intInventoryShipmentItemId
		 , intInventoryShipmentChargeId		= NULL
		 , strInventoryShipmentNumber		= SHP.strShipmentNumber
		 , intShipmentId					= NULL
		 , strShipmentNumber				= NULL
		 , intLoadId						= NULL	
		 , intLoadDetailId					= NULL
		 , intLotId							= NULL
		 , strLoadNumber					= NULL
		 , intRecipeItemId					= NULL
		 , intContractHeaderId				= SOD.intContractHeaderId
		 , intContractDetailId				= SOD.intContractDetailId
		 , intCompanyLocationId				= SHP.intShipFromLocationId
		 , intShipToLocationId				= SO.intShipToLocationId
		 , intFreightTermId					= SHP.intFreightTermId
		 , intItemId						= SOD.intItemId	
		 , strItemDescription				= SOD.strItemDescription
		 , intItemUOMId						= SHP.intItemUOMId
		 , intPriceUOMId					= SOD.intPriceUOMId
		 , intOrderUOMId					= SOD.intItemUOMId
		 , intShipmentItemUOMId				= SHP.intItemUOMId
		 , intWeightUOMId					= SHP.intWeightUOMId
		 , dblWeight						= dbo.fnCalculateQtyBetweenUOM(SHP.intWeightUOMId, SHP.intItemUOMId, 1)
		 , dblQtyShipped					= SHP.dblQuantity
		 , dblQtyOrdered					= SOD.dblQtyOrdered 
		 , dblShipmentQuantity				= SHP.dblQuantity	
		 , dblShipmentQtyShippedTotal		= SHP.dblQuantity
		 , dblQtyRemaining					= SHP.dblQuantity - ISNULL(INVOICEDETAIL.dblQtyShipped, 0)
		 , dblPriceUOMQuantity				= SOD.dblUnitQuantity
		 , dblDiscount						= SOD.dblDiscount 
		 , dblPrice							= (CASE WHEN SHP.intItemUOMId != SOD.intItemUOMId THEN dbo.fnCalculateQtyBetweenUOM(SHP.intItemUOMId, SOD.intItemUOMId, 1) ELSE 1 END) * CAST(SOD.dblPrice AS DECIMAL(18,6))
		 , dblUnitPrice						= (CASE WHEN SHP.intItemUOMId != SOD.intItemUOMId THEN dbo.fnCalculateQtyBetweenUOM(SHP.intItemUOMId, SOD.intItemUOMId, 1) ELSE 1 END) * CAST(SOD.dblPrice AS DECIMAL(18,6))
		 , dblShipmentUnitPrice				= (CASE WHEN SHP.intItemUOMId != SOD.intItemUOMId THEN dbo.fnCalculateQtyBetweenUOM(SHP.intItemUOMId, SOD.intItemUOMId, 1) ELSE 1 END) * CAST(SOD.dblPrice AS DECIMAL(18,6))
		 , strPricing						= SOD.strPricing
		 , strVFDDocumentNumber				= SOD.strVFDDocumentNumber
		 , dblTotalTax						= SOD.dblTotalTax
		 , dblTotal							= SOD.dblTotal
		 , intStorageLocationId				= ISNULL(SHP.intStorageLocationId, SOD.intStorageLocationId)
		 , intTermId						= SO.intTermId
		 , intEntityShipViaId				= SO.intShipViaId
		 , intTicketId						= SHP.intSourceId
		 , intTaxGroupId					= SOD.intTaxGroupId
		 , dblGrossWt						= ISISIL.dblGrossWeight 
		 , dblTareWt						= ISISIL.dblTareWeight 
		 , dblNetWt							= ISISIL.dblNetWeight
		 , strPONumber						= SO.strPONumber
		 , strBOLNumber						= SO.strBOLNumber
		 , intSplitId						= SO.intSplitId
		 , intEntitySalespersonId			= SO.intEntitySalespersonId
		 , ysnBlended						= SOD.ysnBlended
		 , intRecipeId						= SOD.intRecipeId
		 , intSubLocationId					= ISNULL(SHP.intSubLocationId, SOD.intSubLocationId)
		 , intOwnershipType					= SHP.intOwnershipType
		 , intCostTypeId					= SOD.intCostTypeId
		 , intMarginById					= SOD.intMarginById
		 , intCommentTypeId					= SOD.intCommentTypeId
		 , dblMargin						= SOD.dblMargin
		 , dblRecipeQuantity				= SOD.dblRecipeQuantity
		 , intStorageScheduleTypeId			= SOD.intStorageScheduleTypeId
		 , intDestinationGradeId			= SHP.intDestinationGradeId
		 , intDestinationWeightId			= SHP.intDestinationWeightId
		 , intCurrencyExchangeRateTypeId	= ISNULL(SHP.intForexRateTypeId, SOD.intCurrencyExchangeRateTypeId)
		 , intCurrencyExchangeRateId		= NULL
		 , dblCurrencyExchangeRate			= SHP.dblForexRate
		 , intSubCurrencyId					= SOD.intSubCurrencyId
		 , dblSubCurrencyRate				= SOD.dblSubCurrencyRate
		 , intBookId						= NULL
		 , intSubBookId						= NULL
	FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
	INNER JOIN (
		SELECT *
		FROM dbo.tblSOSalesOrderDetail
	) SOD ON SO.intSalesOrderId = SOD.intSalesOrderId
	CROSS APPLY (
		SELECT ISI.intInventoryShipmentItemId
			 , ISH.strShipmentNumber
			 , ISH.intInventoryShipmentId
			 , ISI.intLineNo
			 , ISI.intItemId
			 , ISI.dblQuantity
			 , ISI.intItemUOMId
			 , ISI.intPriceUOMId
			 , ISI.dblUnitPrice
			 , ISI.intSourceId
			 , dbo.fnCalculateQtyBetweenUOM(ISI.intItemUOMId, SOD.intItemUOMId, SUM(ISNULL(ISI.dblQuantity,0))) dblSOShipped
			 , SUM(ISNULL(ISI.dblQuantity,0)) dblShipped
			 , ISH.intShipFromLocationId
			 , ISH.dtmShipDate
			 , ISH.intFreightTermId
			 , ISI.intWeightUOMId
			 , ISI.intSubLocationId
			 , ISI.intStorageLocationId
			 , ISI.intDestinationGradeId
			 , ISI.intDestinationWeightId
			 , ISH.intCurrencyId
			 , ISI.intForexRateTypeId
			 , ISI.dblForexRate
			 , ISI.intOwnershipType
		FROM dbo.tblICInventoryShipmentItem ISI WITH (NOLOCK)
		INNER JOIN (
			 SELECT intInventoryShipmentId
				  , intShipFromLocationId
				  , strShipmentNumber
				  , dtmShipDate
				  , intFreightTermId
				  , intCurrencyId		
			 FROM dbo.tblICInventoryShipment WITH (NOLOCK)
			 WHERE ysnPosted = 1
		) ISH ON ISI.intInventoryShipmentId = ISH.intInventoryShipmentId
		WHERE ISI.intLineNo = SOD.intSalesOrderDetailId
		GROUP BY ISI.intInventoryShipmentItemId
			   , ISH.strShipmentNumber
			   , ISH.intInventoryShipmentId
			   , ISI.intLineNo
			   , ISI.intItemId
			   , ISI.dblQuantity
			   , ISI.intItemUOMId
			   , ISI.intPriceUOMId
			   , ISI.dblUnitPrice
			   , ISI.intSourceId
			   , ISH.intShipFromLocationId
			   , ISH.dtmShipDate
			   , ISH.intFreightTermId
			   , ISI.intWeightUOMId
			   , ISI.intSubLocationId
			   , ISI.intStorageLocationId
			   , ISI.intDestinationGradeId
			   , ISI.intDestinationWeightId
			   , ISH.intCurrencyId
			   , ISI.intForexRateTypeId
			   , ISI.dblForexRate
			   , ISI.intOwnershipType
	) SHP
	LEFT OUTER JOIN (
		SELECT intInventoryShipmentItemId
			 , dblGrossWeight	= SUM(dblGrossWeight) 
			 , dblTareWeight	= SUM(dblTareWeight)
			 , dblNetWeight		= SUM(dblGrossWeight - dblTareWeight)
		FROM dbo.tblICInventoryShipmentItemLot WITH (NOLOCK)
		GROUP BY intInventoryShipmentItemId
	) ISISIL ON SHP.intInventoryShipmentItemId = ISISIL.intInventoryShipmentItemId
	LEFT OUTER JOIN (SELECT intInventoryShipmentItemId
						  , dblQtyShipped 
					FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
					WHERE ISNULL(intInventoryShipmentItemId, 0) <> 0
	) INVOICEDETAIL ON SHP.intInventoryShipmentItemId = INVOICEDETAIL.intInventoryShipmentItemId
	WHERE SO.strTransactionType = 'Order' 
	  AND SO.strOrderStatus <> 'Cancelled'
	  AND SHP.dblQuantity - ISNULL(INVOICEDETAIL.dblQtyShipped, 0) <> 0

	UNION ALL

	--DIRECT IS
	SELECT strTransactionType				= 'Inventory Shipment' COLLATE Latin1_General_CI_AS
	     , strTransactionNumber				= ICIS.strShipmentNumber
	     , strShippedItemId					= 'icis:' + CAST(ICIS.intInventoryShipmentId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	     , intEntityCustomerId				= ICIS.intEntityCustomerId
	     , intCurrencyId					= ISNULL(ICIS.intCurrencyId, ARCC.intCurrencyId)
	     , intSalesOrderId					= NULL
	     , intSalesOrderDetailId			= NULL
	     , strSalesOrderNumber				= ''
	     , dtmProcessDate					= ICIS.dtmShipDate
	     , intInventoryShipmentId			= ICIS.intInventoryShipmentId
	     , intInventoryShipmentItemId		= ICISI.intInventoryShipmentItemId
	     , intInventoryShipmentChargeId		= NULL
	     , strInventoryShipmentNumber		= ICIS.strShipmentNumber
	     , intShipmentId					= LGICSHIPMENT.intShipmentId
	     , strShipmentNumber				= NULL
	     , intLoadId						= NULL	
	     , intLoadDetailId					= NULL
	     , intLotId							= NULL
	     , strLoadNumber					= NULL
	     , intRecipeItemId					= NULL
	     , intContractHeaderId				= ISNULL(ARCC.intContractHeaderId, LGICSHIPMENT.intContractHeaderId)
	     , intContractDetailId				= ISNULL(ARCC.intContractDetailId, LGICSHIPMENT.intContractDetailId)
	     , intCompanyLocationId				= ICIS.intShipFromLocationId
	     , intShipToLocationId				= ICIS.intShipToLocationId
	     , intFreightTermId					= ICIS.intFreightTermId
	     , intItemId						= ICISI.intItemId
	     , strItemDescription				= NULL
	     , intItemUOMId						= ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId) --CASE WHEN ISNULL(LGICSHIPMENT.intShipmentId,0) <> 0 THEN ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId) ELSE ICISI.intItemUOMId END
		 , intPriceUOMId					= CASE WHEN ARCC.intContractDetailId IS NOT NULL THEN ARCC.intPriceItemUOMId ELSE ICISI.intPriceUOMId END
	     , intOrderUOMId					= CASE WHEN ARCC.intContractDetailId IS NOT NULL THEN ARCC.intOrderUOMId ELSE ICISI.intItemUOMId END
	     , intShipmentItemUOMId				= ICISI.intItemUOMId
		 , intWeightUOMId					= ICISI.intWeightUOMId
		 , dblWeight						= CASE WHEN ISNULL(LGICSHIPMENT.intShipmentId,0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), 1) ELSE 1 END
	     , dblQtyShipped					= (CASE WHEN ICISI.dblDestinationQuantity IS NOT NULL AND ISNULL(ICISI.ysnDestinationWeightsAndGrades, 0) = 1
		 										    	THEN dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblDestinationQuantity,0))
													ELSE
														dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblQuantity,0))
												END)
	     , dblQtyOrdered					= CASE WHEN ARCC.intContractDetailId IS NOT NULL THEN ARCC.dblDetailQuantity ELSE 0 END
	     , dblShipmentQuantity				= (CASE WHEN ICISI.dblDestinationQuantity IS NOT NULL AND ISNULL(ICISI.ysnDestinationWeightsAndGrades, 0) = 1
														THEN dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblDestinationQuantity,0))
													ELSE
														dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblQuantity,0))
												END)     
	     , dblShipmentQtyShippedTotal		= (CASE WHEN ICISI.dblDestinationQuantity IS NOT NULL AND ISNULL(ICISI.ysnDestinationWeightsAndGrades, 0) = 1
		 												THEN dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblDestinationQuantity,0))
													ELSE
														dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblQuantity,0))
												END)	     
	     , dblQtyRemaining					= (CASE WHEN ICISI.dblDestinationQuantity IS NOT NULL AND ISNULL(ICISI.ysnDestinationWeightsAndGrades, 0) = 1
		 												THEN dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblDestinationQuantity,0)) - ISNULL(ID.dblQtyShipped, 0)
													ELSE
														dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), (ISNULL(ICISI.dblQuantity,0) - ISNULL(ID.dblQtyShipped, 0)))
												END)																							
		 , dblPriceUOMQuantity				= CASE WHEN ARCC.intContractDetailId IS NOT NULL THEN ARCC.dblPriceUOMQuantity ELSE (CASE WHEN ISNULL(LGICSHIPMENT.intShipmentId,0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblQuantity,0)) ELSE  ISNULL(ICISI.dblQuantity,0) END) END
	     , dblDiscount						= 0.000000 
	     , dblPrice							= CAST((CASE WHEN ISNULL(LGICSHIPMENT.intShipmentId,0) <> 0 OR ARCC.intContractDetailId IS NOT NULL THEN ISNULL(ARCC.dblCashPrice, ARCC.dblUnitPrice) ELSE ICISI.dblConvertedPrice END) AS DECIMAL(18,6))
		 , dblUnitPrice						= CAST((CASE WHEN ISNULL(LGICSHIPMENT.intShipmentId,0) <> 0 OR ARCC.intContractDetailId IS NOT NULL THEN ISNULL(ARCC.dblUnitPrice, ARCC.dblCashPrice) ELSE ICISI.dblUnitPrice END) AS DECIMAL(18,6))
	     , dblShipmentUnitPrice				= CAST((CASE WHEN ISNULL(LGICSHIPMENT.intShipmentId,0) <> 0 OR ARCC.intContractDetailId IS NOT NULL THEN ISNULL(ARCC.dblOrderPrice,ISNULL(ARCC.dblUnitPrice, ARCC.dblCashPrice)) ELSE ICISI.dblConvertedPrice END) AS DECIMAL(18,6))
	     , strPricing						= ''	     
	     , strVFDDocumentNumber				= NULL
	     , dblTotalTax						= 0.000000
	     , dblTotal							= CASE WHEN ISNULL(LGICSHIPMENT.intShipmentId,0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblQuantity,0)) * ISNULL(ARCC.dblCashPrice, ICISI.dblConvertedPrice) ELSE ISNULL(ICISI.dblQuantity,0) * ICISI.dblConvertedPrice END
	     , intStorageLocationId				= ICISI.intStorageLocationId
	     , intTermId						= NULL
	     , intEntityShipViaId				= NULL
	     , intTicketId						= ICISI.intSourceId
	     , intTaxGroupId					= NULL
	     , dblGrossWt						= ISISIL.dblGrossWeight 
	     , dblTareWt						= ISISIL.dblTareWeight 
	     , dblNetWt							= ISISIL.dblNetWeight
	     , strPONumber						= ''
	     , strBOLNumber						= ''
	     , intSplitId						= NULL
	     , intEntitySalespersonId			= NULL
	     , ysnBlended						= NULL
	     , intRecipeId						= NULL
	     , intSubLocationId					= ICISI.intSubLocationId
		 , intOwnershipType					= ICISI.intOwnershipType
	     , intCostTypeId					= NULL
	     , intMarginById					= NULL
	     , intCommentTypeId					= NULL
	     , dblMargin						= NULL
	     , dblRecipeQuantity				= NULL
	     , intStorageScheduleTypeId			= NULL
	     , intDestinationGradeId			= ICISI.intDestinationGradeId
	     , intDestinationWeightId			= ICISI.intDestinationWeightId
	     , intCurrencyExchangeRateTypeId	= ICISI.intForexRateTypeId
	     , intCurrencyExchangeRateId		= NULL
	     , dblCurrencyExchangeRate			= ICISI.dblForexRate
	     , intSubCurrencyId					= NULL
	     , dblSubCurrencyRate				= 1
		 , intBookId						= NULL
		 , intSubBookId						= NULL
	FROM (
		SELECT 
			dblForexRate,
			intDestinationGradeId,
			intDestinationWeightId,
			intSubLocationId,
			intSourceId,
			intStorageLocationId,
			intInventoryShipmentId,
			intInventoryShipmentItemId,
			intForexRateTypeId,
			intLineNo,
			intItemId,
			intItemUOMId,
			dblQuantity,
			intWeightUOMId,
			intPriceUOMId,
			dblUnitPrice,
			dblConvertedPrice = dblUnitPrice * isnull(dbo.fnARCalculateQtyBetweenUOM(intItemUOMId, intPriceUOMId, 1, intItemId, null) , 1),
			dblDestinationQuantity,
			dblNet = dblGross - dblTare,
			intOwnershipType,
			ysnAllowInvoice,
			ysnDestinationWeightsAndGrades
		FROM dbo.tblICInventoryShipmentItem WITH (NOLOCK)
		WHERE 
			ISNULL(ysnDestinationWeightsAndGrades, 0) = 0
			OR
			(	ISNULL(ysnDestinationWeightsAndGrades, 0) = 1 
				AND 
				dblDestinationQuantity IS NOT NULL
			)
	) ICISI 
	INNER JOIN (
		SELECT intInventoryShipmentId
			 , intShipFromLocationId
			 , strShipmentNumber
			 , dtmShipDate
			 , intFreightTermId
			 , intOrderType
			 , intEntityCustomerId
			 , intShipToLocationId
			 , intCurrencyId	= ISNULL(IIS.intCurrencyId, SHIPMENTCURRENCY.intCurrencyId)
			 , intSourceType
		FROM dbo.tblICInventoryShipment IIS WITH (NOLOCK)
		OUTER APPLY (
			SELECT TOP 1 intCurrencyId 
			FROM dbo.tblICInventoryShipmentCharge WITH (NOLOCK) 
			WHERE IIS.intInventoryShipmentId = intInventoryShipmentId 
			  AND intCurrencyId IS NOT NULL
		) SHIPMENTCURRENCY
		WHERE intOrderType <> 2 
		  AND ysnPosted = 1 
	) ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
	LEFT OUTER JOIN (
		SELECT intInventoryShipmentItemId
			 , dblGrossWeight	= SUM(dblGrossWeight)
			 , dblTareWeight	= SUM(dblTareWeight) 
			 , dblNetWeight		= SUM(dblGrossWeight - dblTareWeight) 
		FROM dbo.tblICInventoryShipmentItemLot WITH (NOLOCK)
		GROUP BY intInventoryShipmentItemId
	) ISISIL ON ICISI.intInventoryShipmentItemId = ISISIL.intInventoryShipmentItemId
	LEFT OUTER JOIN (
		SELECT TOP 1
			  LGSD.intShipmentId
			, LGSD.intTrackingNumber
			, ICISI1.intInventoryShipmentItemId
			, LGSD.intContractDetailId
			, LGSD.strContractNumber
			, LGSD.intContractHeaderId
			, LGSD.intContractSeq
		FROM ( 
			SELECT intInventoryShipmentItemId 
			FROM dbo.tblICInventoryShipmentItem WITH (NOLOCK)
		) ICISI1
		INNER JOIN (
			SELECT intInventoryShipmentItemId
				 , intLotId
			FROM dbo.tblICInventoryShipmentItemLot WITH (NOLOCK)
		) ICISIL1 ON ICISI1.intInventoryShipmentItemId = ICISIL1.intInventoryShipmentItemId
		INNER JOIN (
			SELECT intLotId
				 , intTransactionDetailId
			FROM dbo.tblICInventoryLot  WITH (NOLOCK)
			WHERE ysnIsUnposted = 0
		) ICIL1 ON ICISIL1.intLotId = ICIL1.intLotId
		INNER JOIN (
			SELECT intInventoryReceiptItemId
				 , intLineNo
			FROM dbo.tblICInventoryReceiptItem WITH (NOLOCK)
		) ICIRI1 ON ICIL1.intTransactionDetailId = ICIRI1.intInventoryReceiptItemId
		INNER JOIN (
			SELECT intContractDetailId
				 , intShipmentId
				 , intTrackingNumber
				 , strContractNumber
				 , intContractHeaderId
				 , intContractSeq
		FROM dbo.vyuLGShipmentContainerPurchaseContracts WITH (NOLOCK)
		) LGSD ON ICIRI1.intLineNo = LGSD.intContractDetailId
	) LGICSHIPMENT ON ICISI.intInventoryShipmentItemId = LGICSHIPMENT.intInventoryShipmentItemId
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
			 , intItemUOMId
			 , intPriceItemUOMId
			 , strOrderUnitMeasure
			 , intItemWeightUOMId
			 , dblCashPrice
			 , dblUnitPrice
			 , dblOrderPrice
			 , dblDetailQuantity
			 , intFreightTermId
			 , dblShipQuantity
			 , dblOrderQuantity
			 , dblSubCurrencyRate
			 , intCurrencyExchangeRateTypeId
			 , strCurrencyExchangeRateType
			 , intCurrencyExchangeRateId
			 , dblCurrencyExchangeRate
			 , dblPriceUOMQuantity
			 , intBookId
			 , intSubBookId
		 FROM dbo.vyuCTCustomerContract WITH (NOLOCK)
	) ARCC ON ICISI.intLineNo = ARCC.intContractDetailId 
		  AND ICIS.intOrderType = 1
	LEFT OUTER JOIN (
		SELECT intInventoryShipmentItemId
		FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		WHERE ISNULL(intInventoryShipmentItemId, 0) = 0
	) ARID ON ICISI.intInventoryShipmentItemId = ARID.intInventoryShipmentItemId
	LEFT OUTER JOIN (SELECT intInventoryShipmentItemId
						  , dblQtyShipped = SUM(dblQtyShipped)
						  , strDocumentNumber 
					 FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
					 GROUP BY intInventoryShipmentItemId, strDocumentNumber
	) ID ON ICISI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId 
		AND ICIS.strShipmentNumber = ID.strDocumentNumber
	WHERE ISNULL(ARID.intInventoryShipmentItemId,0) = 0
	  AND (
			(dbo.fnCalculateQtyBetweenUOM(ICISI.intItemUOMId, ISNULL(ARCC.intItemUOMId, ICISI.intItemUOMId), ISNULL(ICISI.dblQuantity,0))) - ISNULL(ID.dblQtyShipped, 0) > 0
			OR
			ISNULL(LGICSHIPMENT.intShipmentId,0) = 0
			)
		AND ((ISNULL(ICISI.ysnAllowInvoice, 1) = 1 AND ICIS.intSourceType = 1)
			OR
			ICIS.intSourceType <> 1
			)

	UNION ALL

	--IS CHARGES
	SELECT strTransactionType				= 'Inventory Shipment' COLLATE Latin1_General_CI_AS
		 , strTransactionNumber				= ICIS.strShipmentNumber
		 , strShippedItemId					= 'icis:' + CAST(ICIS.intInventoryShipmentId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
		 , intEntityCustomerId				= ICIS.intEntityCustomerId
		 , intCurrencyId					= ICISC.intCurrencyId
		 , intSalesOrderId					= NULL
		 , intSalesOrderDetailId			= NULL
		 , strSalesOrderNumber				= ''
		 , dtmProcessDate					= ICIS.dtmShipDate
		 , intInventoryShipmentId			= ICIS.intInventoryShipmentId
		 , intInventoryShipmentItemId		= NULL
		 , intInventoryShipmentChargeId		= ICISC.intInventoryShipmentChargeId
		 , strInventoryShipmentNumber		= ICIS.strShipmentNumber
		 , intShipmentId					= NULL
		 , strShipmentNumber				= NULL
		 , intLoadId						= NULL	
		 , intLoadDetailId					= NULL
		 , intLotId							= NULL
		 , strLoadNumber					= NULL
		 , intRecipeItemId					= NULL
		 , intContractHeaderId				= ICISC.intContractId
		 , intContractDetailId				= ICISC.intContractDetailId
		 , intCompanyLocationId				= ICIS.intShipFromLocationId
		 , intShipToLocationId				= ICIS.intShipToLocationId
		 , intFreightTermId					= ICIS.intFreightTermId
		 , intItemId						= ICISC.intChargeId
		 , strItemDescription				= NULL
		 , intItemUOMId						= ICISC.intCostUOMId
		 , intPriceUOMId					= NULL
		 , intOrderUOMId					= NULL		
		 , intShipmentItemUOMId				= ICISC.intCostUOMId
		 , intWeightUOMId					= NULL
		 , dblWeight						= NULL
		 , dblQtyShipped					= (CASE WHEN ICISC.strCostMethod IN ('Amount', 'Percentage') THEN 1 ELSE ISNULL(ICISC.dblQuantity,1) END)
		 , dblQtyOrdered					= 0 
		 , dblShipmentQuantity				= (CASE WHEN ICISC.strCostMethod IN ('Amount', 'Percentage') THEN 1 ELSE ISNULL(ICISC.dblQuantity,1) END)
		 , dblShipmentQtyShippedTotal		= (CASE WHEN ICISC.strCostMethod IN ('Amount', 'Percentage') THEN 1 ELSE ISNULL(ICISC.dblQuantity,1) END)
		 , dblQtyRemaining					= (CASE WHEN ICISC.strCostMethod IN ('Amount', 'Percentage') THEN 1  ELSE ISNULL(ICISC.dblQuantity,1) END) -    CASE WHEN ARIDCHARGE.intInventoryShipmentChargeId IS NOT NULL THEN ISNULL(ARIDCHARGE.dblQtyShipped,1) ELSE ISNULL(ID.dblQtyShipped, 0) END 
		 , dblPriceUOMQuantity				= (CASE WHEN ICISC.strCostMethod IN ('Amount', 'Percentage') THEN 1 ELSE ISNULL(ICISC.dblQuantity,1) END)
		 , dblDiscount						= 0 
		 , dblPrice							= CAST((CASE WHEN ICISC.strCostMethod IN ('Amount', 'Percentage') THEN ISNULL(ICISC.dblAmount,0.000000) ELSE ISNULL(ICISC.dblRate, 0.000000) END) AS DECIMAL(18,6))
		 , dblUnitPrice						= CAST((CASE WHEN ICISC.strCostMethod IN ('Amount', 'Percentage') THEN ISNULL(ICISC.dblAmount,0.000000) ELSE ISNULL(ICISC.dblRate, 0.000000) END) AS DECIMAL(18,6))
		 , dblShipmentUnitPrice				= CAST((CASE WHEN ICISC.strCostMethod IN ('Amount', 'Percentage') THEN ISNULL(ICISC.dblAmount,0.000000) ELSE ISNULL(ICISC.dblRate, 0.000000) END) AS DECIMAL(18,6))
		 , strPricing						= ''
		 , strVFDDocumentNumber				= NULL
		 , dblTotalTax						= 0
		 , dblTotal							= ICISC.dblQuantity  * ICISC.dblAmount
		 , intStorageLocationId				= NULL
		 , intTermId						= NULL
		 , intEntityShipViaId				= NULL
		 , intTicketId						= ICISI.intSourceId
		 , intTaxGroupId					= NULL
		 , dblGrossWt						= 0
		 , dblTareWt						= 0
		 , dblNetWt							= 0
		 , strPONumber						= ''
		 , strBOLNumber						= ''
		 , intSplitId						= NULL
		 , intEntitySalespersonId			= NULL
		 , ysnBlended						= NULL
		 , intRecipeId						= NULL
		 , intSubLocationId					= NULL
		 , intOwnershipType					= NULL
		 , intCostTypeId					= NULL
		 , intMarginById					= NULL
		 , intCommentTypeId					= NULL
		 , dblMargin						= NULL
		 , dblRecipeQuantity				= NULL
		 , intStorageScheduleTypeId			= NULL
		 , intDestinationGradeId			= NULL
		 , intDestinationWeightId			= NULL
		 , intCurrencyExchangeRateTypeId	= ICISC.intForexRateTypeId
		 , intCurrencyExchangeRateId		= NULL
		 , dblCurrencyExchangeRate			= ICISC.dblForexRate
		 , intSubCurrencyId					= NULL
		 , dblSubCurrencyRate				= 1
		 , intBookId						= NULL
		 , intSubBookId						= NULL
	FROM dbo.tblICInventoryShipmentCharge ICISC WITH (NOLOCK)
	INNER JOIN (
		SELECT intInventoryShipmentId
			 , intShipFromLocationId
			 , strShipmentNumber
			 , dtmShipDate
			 , intFreightTermId
			 , intOrderType
			 , intEntityCustomerId
			 , intShipToLocationId
			 , intSourceType
		FROM dbo.tblICInventoryShipment WITH (NOLOCK)
		WHERE ysnPosted = 1
	) ICIS ON ICISC.intInventoryShipmentId = ICIS.intInventoryShipmentId
	OUTER APPLY (
		SELECT TOP 1 intSourceId
			 	   , intInventoryShipmentItemId
		FROM dbo.tblICInventoryShipmentItem ICISI WITH (NOLOCK)
		WHERE ISNULL(ICISI.strChargesLink, '') = ICISC.strChargesLink
		  AND ICIS.intInventoryShipmentId = ICISI.intInventoryShipmentId
	) ICISI
	LEFT OUTER JOIN (
		SELECT intInventoryShipmentChargeId
		FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		WHERE ISNULL(intInventoryShipmentChargeId, 0) = 0
	) ARID ON ICISC.intInventoryShipmentChargeId = ARID.intInventoryShipmentChargeId
	LEFT JOIN (
		SELECT intInventoryShipmentChargeId
			 , dblQtyShipped
		FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		WHERE ISNULL(intInventoryShipmentChargeId, 0) <> 0
	) ARIDCHARGE ON ICISC.intInventoryShipmentChargeId = ARIDCHARGE.intInventoryShipmentChargeId
	LEFT OUTER JOIN (
		SELECT intInventoryShipmentItemId
			 , dblQtyShipped = SUM(dblQtyShipped)
			 , strDocumentNumber 
		FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		GROUP BY intInventoryShipmentItemId, strDocumentNumber
	) ID ON ICISI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId 
		AND ICIS.strShipmentNumber = ID.strDocumentNumber
	WHERE ISNULL(ARID.intInventoryShipmentChargeId, 0) = 0
	  AND ICISC.intEntityVendorId IS NULL
	  AND ISNULL(ICISC.ysnPrice, 0) = 1
	  AND ((ISNULL(ICISC.ysnAllowInvoice, 1) = 1 AND ICIS.intSourceType = 1)
			OR
			ICIS.intSourceType <> 1
			)

	UNION ALL

	--SO WITH MFG
	SELECT strTransactionType				= 'Sales Order' COLLATE Latin1_General_CI_AS
		 , strTransactionNumber				= SO.strSalesOrderNumber
		 , strShippedItemId					= 'arso:' + CAST(SO.intSalesOrderId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
		 , intEntityCustomerId				= SO.intEntityCustomerId
		 , intCurrencyId					= SO.intCurrencyId
		 , intSalesOrderId					= SO.intSalesOrderId
		 , intSalesOrderDetailId			= NULL
		 , strSalesOrderNumber				= SO.strSalesOrderNumber
		 , dtmProcessDate					= SO.dtmDate
		 , intInventoryShipmentId			= NULL
		 , intInventoryShipmentItemId		= NULL
		 , intInventoryShipmentChargeId		= NULL
		 , strInventoryShipmentNumber		= ''	
		 , intShipmentId					= NULL
		 , strShipmentNumber				= NULL
		 , intLoadId						= NULL	
		 , intLoadDetailId					= NULL
		 , intLotId							= NULL
		 , strLoadNumber					= NULL
		 , intRecipeItemId					= MFG.intRecipeItemId
		 , intContractHeaderId				= NULL
		 , intContractDetailId				= NULL
		 , intCompanyLocationId				= SO.intCompanyLocationId
		 , intShipToLocationId				= SO.intShipToLocationId
		 , intFreightTermId					= SO.intFreightTermId
		 , intItemId						= MFG.intItemId
		 , strItemDescription				= NULL
		 , intItemUOMId						= MFG.intItemUOMId
		 , intPriceUOMId					= MFG.intItemUOMId
		 , intOrderUOMId					= MFG.intItemUOMId
		 , intShipmentItemUOMId				= MFG.intItemUOMId
		 , intWeightUOMId					= NULL
		 , dblWeight						= NULL
		 , dblQtyShipped					= MFG.dblQuantity
		 , dblQtyOrdered					= MFG.dblQuantity
		 , dblShipmentQuantity				= MFG.dblQuantity
		 , dblShipmentQtyShippedTotal		= MFG.dblQuantity
		 , dblQtyRemaining					= MFG.dblQuantity
		 , dblPriceUOMQuantity				= MFG.dblQuantity
		 , dblDiscount						= 0.00
		 , dblPrice							= CAST(MFG.dblPrice AS DECIMAL(18,6))
		 , dblUnitPrice						= CAST(MFG.dblPrice AS DECIMAL(18,6))
		 , dblShipmentUnitPrice				= CAST(MFG.dblPrice AS DECIMAL(18,6))
		 , strPricing						= ''
		 , strVFDDocumentNumber				= NULL
		 , dblTotalTax						= 0.00
		 , dblTotal							= MFG.[dblLineTotal]
		 , intStorageLocationId				= NULL
		 , intTermId						= SO.intTermId
		 , intEntityShipViaId				= SO.intShipViaId
		 , intTicketId						= NULL
		 , intTaxGroupId					= NULL
		 , dblGrossWt						= 0.00
		 , dblTareWt						= 0.00
		 , dblNetWt							= 0.00
		 , strPONumber						= SO.strPONumber
		 , strBOLNumber						= SO.strBOLNumber
		 , intSplitId						= SO.intSplitId
		 , intEntitySalespersonId			= SO.intEntitySalespersonId
		 , ysnBlended						= NULL
		 , intRecipeId						= MFR.intRecipeId
		 , intSubLocationId					= NULL
		 , intOwnershipType					= NULL
		 , intCostTypeId					= NULL
		 , intMarginById					= NULL
		 , intCommentTypeId					= NULL
		 , dblMargin						= NULL
		 , dblRecipeQuantity				= NULL
		 , intStorageScheduleTypeId			= NULL
		 , intDestinationGradeId			= NULL
		 , intDestinationWeightId			= NULL
		 , intCurrencyExchangeRateTypeId	= ARID.intCurrencyExchangeRateTypeId
		 , intCurrencyExchangeRateId		= ARID.intCurrencyExchangeRateId
		 , dblCurrencyExchangeRate			= ARID.dblCurrencyExchangeRate
		 , intSubCurrencyId					= NULL
		 , dblSubCurrencyRate				= 1
		 , intBookId						= NULL
		 , intSubBookId						= NULL
	FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
	CROSS APPLY dbo.fnMFGetInvoiceChargesByShipment(0, SO.intSalesOrderId) MFG
	LEFT OUTER JOIN (
		SELECT intInventoryShipmentItemId
			 , intRecipeItemId
			 , intCurrencyExchangeRateTypeId
			 , intCurrencyExchangeRateId
			 , dblCurrencyExchangeRate
		FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		WHERE (ISNULL(intRecipeItemId, 0) = 0)
	) ARID ON MFG.intRecipeItemId = ARID.intRecipeItemId
	LEFT OUTER JOIN (
		SELECT intRecipeItemId
			 , intRecipeId
		FROM dbo.tblMFRecipeItem WITH (NOLOCK)
	) MFR ON MFG.intRecipeItemId = MFR.intRecipeItemId
	LEFT OUTER JOIN (
		SELECT intOrderId
			 , D.intInventoryShipmentId
		FROM dbo.tblICInventoryShipmentItem D WITH (NOLOCK)		
		INNER JOIN (
			SELECT intInventoryShipmentId
			FROM dbo.tblICInventoryShipment WITH (NOLOCK)
			WHERE intOrderType = 2
		) H ON H.intInventoryShipmentId = D.intInventoryShipmentId
		WHERE ISNULL(intOrderId, 0) = 0
	) ISD ON SO.intSalesOrderId = ISD.intOrderId
	WHERE SO.strTransactionType = 'Order' 
	  AND SO.strOrderStatus NOT IN ('Cancelled', 'Closed', 'Short Closed')

	UNION ALL

	--IS WITH MFG
	SELECT DISTINCT
		   strTransactionType				= 'Inventory Shipment' COLLATE Latin1_General_CI_AS
		 , strTransactionNumber				= ICIS.strShipmentNumber
		 , strShippedItemId					= 'icis:' + CAST(ICIS.intInventoryShipmentId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
		 , intEntityCustomerId				= ICIS.intEntityCustomerId
		 , intCurrencyId					= ICISI.intCurrencyId
		 , intSalesOrderId					= NULL
		 , intSalesOrderDetailId			= NULL
		 , strSalesOrderNumber				= ''
		 , dtmProcessDate					= ICIS.dtmShipDate
		 , intInventoryShipmentId			= ICIS.intInventoryShipmentId
		 , intInventoryShipmentItemId		= NULL
		 , intInventoryShipmentChargeId		= NULL
		 , strInventoryShipmentNumber		= ICIS.strShipmentNumber
		 , intShipmentId					= NULL
		 , strShipmentNumber				= NULL
		 , intLoadId						= NULL	
		 , intLoadDetailId					= NULL
		 , intLotId							= NULL
		 , strLoadNumber					= NULL
		 , intRecipeItemId					= MFG.intRecipeItemId
		 , intContractHeaderId				= NULL
		 , intContractDetailId				= NULL
		 , intCompanyLocationId				= ICIS.intShipFromLocationId
		 , intShipToLocationId				= ICIS.intShipToLocationId
		 , intFreightTermId					= ICIS.intFreightTermId
		 , intItemId						= MFG.intItemId	
		 , strItemDescription				= NULL
		 , intItemUOMId						= MFG.intItemUOMId
		 , intPriceUOMId					= MFG.intItemUOMId
		 , intOrderUOMId					= NULL		
		 , intShipmentItemUOMId				= MFG.intItemUOMId
		 , intWeightUOMId					= NULL
		 , dblWeight						= NULL
		 , dblQtyShipped					= MFG.dblQuantity 	
		 , dblQtyOrdered					= 0
		 , dblShipmentQuantity				= MFG.dblQuantity
		 , dblShipmentQtyShippedTotal		= MFG.dblQuantity
		 , dblQtyRemaining					= MFG.dblQuantity
		 , dblPriceUOMQuantity				= MFG.dblQuantity
		 , dblDiscount						= 0 
		 , dblPrice							= CAST(MFG.dblPrice AS DECIMAL(18,6))
		 , dblUnitPrice						= CAST(MFG.dblPrice AS DECIMAL(18,6))
		 , dblShipmentUnitPrice				= CAST(MFG.dblPrice AS DECIMAL(18,6))
		 , strPricing						= ''
		 , strVFDDocumentNumber				= NULL
		 , dblTotalTax						= 0
		 , dblTotal							= MFG.dblLineTotal
		 , intStorageLocationId				= NULL
		 , intTermId						= NULL
		 , intEntityShipViaId				= NULL
		 , intTicketId						= NULL
		 , intTaxGroupId					= NULL
		 , dblGrossWt						= 0
		 , dblTareWt						= 0
		 , dblNetWt							= 0
		 , strPONumber						= ''
		 , strBOLNumber						= ''
		 , intSplitId						= NULL
		 , intEntitySalespersonId			= NULL
		 , ysnBlended						= NULL
		 , intRecipeId						= NULL
		 , intSubLocationId					= NULL
		 , intOwnershipType					= ICISI.intOwnershipType
		 , intCostTypeId					= NULL
		 , intMarginById					= NULL
		 , intCommentTypeId					= NULL
		 , dblMargin						= NULL
		 , dblRecipeQuantity				= NULL
		 , intStorageScheduleTypeId			= NULL
		 , intDestinationGradeId			= ICISI.intDestinationGradeId
		 , intDestinationWeightId			= ICISI.intDestinationWeightId
		 , intCurrencyExchangeRateTypeId	= ICISI.intForexRateTypeId
		 , intCurrencyExchangeRateId		= NULL
		 , dblCurrencyExchangeRate			= ICISI.dblForexRate
		 , intSubCurrencyId					= ICISI.intCurrencyId
		 , dblSubCurrencyRate				= NULL
		 , intBookId						= NULL
		 , intSubBookId						= NULL
	FROM dbo.tblICInventoryShipmentItem ICISI WITH (NOLOCK)
	CROSS APPLY dbo.fnMFGetInvoiceChargesByShipment(ICISI.intInventoryShipmentItemId, 0) MFG	
	INNER JOIN (
		SELECT intInventoryShipmentId
			 , intEntityCustomerId
			 , strShipmentNumber
			 , intShipFromLocationId
			 , dtmShipDate
			 , intShipToLocationId
			 , intFreightTermId
		FROM dbo.tblICInventoryShipment WITH (NOLOCK)
		WHERE ysnPosted = 1
	) ICIS ON ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId
	LEFT OUTER JOIN (
		SELECT intInventoryShipmentItemId
			 , intRecipeItemId
			 , strShipmentNumber
		 FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		 WHERE ISNULL(intRecipeItemId, 0) = 0
	) ARID ON MFG.intRecipeItemId = ARID.intRecipeItemId
		  AND ICIS.strShipmentNumber = ARID.strShipmentNumber
	LEFT OUTER JOIN (
		SELECT intRecipeItemId
			 , intRecipeId
		FROM tblMFRecipeItem WITH(NOLOCK)
	) MFI ON MFG.intRecipeItemId = MFI.intRecipeItemId
	WHERE ISNULL(ICISI.ysnDestinationWeightsAndGrades, 0) = 0

	UNION ALL 

	SELECT strTransactionType				= strTransactionType COLLATE Latin1_General_CI_AS
	     , strTransactionNumber				= strTransactionNumber
	     , strShippedItemId					= strShippedItemId COLLATE Latin1_General_CI_AS
	     , intEntityCustomerId				= intEntityCustomerId
	     , intCurrencyId					= intCurrencyId
	     , intSalesOrderId					= intSalesOrderId
	     , intSalesOrderDetailId			= intSalesOrderDetailId
	     , strSalesOrderNumber				= strSalesOrderNumber
	     , dtmProcessDate					= dtmProcessDate
	     , intInventoryShipmentId			= intInventoryShipmentId
	     , intInventoryShipmentItemId		= intInventoryShipmentItemId
	     , intInventoryShipmentChargeId		= intInventoryShipmentChargeId
	     , strInventoryShipmentNumber		= strInventoryShipmentNumber
	     , intShipmentId					= intShipmentId
	     , strShipmentNumber				= strShipmentNumber
	     , intLoadId						= intLoadId
	     , intLoadDetailId					= intLoadDetailId
	     , intLotId							= intLotId
	     , strLoadNumber					= strLoadNumber
	     , intRecipeItemId					= intRecipeItemId
	     , intContractHeaderId				= intContractHeaderId
	     , intContractDetailId				= intContractDetailId
	     , intCompanyLocationId				= intCompanyLocationId
	     , intShipToLocationId				= intShipToLocationId
	     , intFreightTermId					= intFreightTermId
	     , intItemId						= intItemId
	     , strItemDescription				= strItemDescription
	     , intItemUOMId						= intItemUOMId
		 , intPriceUOMId					= intPriceUOMId
	     , intOrderUOMId					= intOrderUOMId
	     , intShipmentItemUOMId				= intShipmentItemUOMId
		 , intWeightUOMId					= intItemUOMId
		 , dblWeight						= dblWeight
		 , dblQtyShipped					= dblQtyShipped
		 , dblQtyOrdered					= dblQtyOrdered
		 , dblShipmentQuantity				= dblShipmentQuantity
		 , dblShipmentQtyShippedTotal		= dblShipmentQtyShippedTotal
		 , dblQtyRemaining					= dblQtyRemaining
		 , dblPriceUOMQuantity				= dblNetWt
	     , dblDiscount						= dblDiscount
	     , dblPrice							= CAST(dblPrice AS DECIMAL(18,6))
		 , dblUnitPrice						= CAST(dblPrice AS DECIMAL(18,6))
	     , dblShipmentUnitPrice				= CAST(dblShipmentUnitPrice AS DECIMAL(18,6))
	     , strPricing						= strPricing
	     , strVFDDocumentNumber				= strVFDDocumentNumber
	     , dblTotalTax						= dblTotalTax
	     , dblTotal							= dblTotal
	     , intStorageLocationId				= intStorageLocationId
	     , intTermId						= intTermId
	     , intEntityShipViaId				= intEntityShipViaId
	     , intTicketId						= intTicketId
	     , intTaxGroupId					= intTaxGroupId
	     , dblGrossWt						= dbo.fnCalculateQtyBetweenUOM(intWeightUOMId, intItemUOMId, dblGrossWt)
	     , dblTareWt						= dbo.fnCalculateQtyBetweenUOM(intWeightUOMId, intItemUOMId, dblTareWt)
	     , dblNetWt							= dbo.fnCalculateQtyBetweenUOM(intWeightUOMId, intItemUOMId, dblNetWt)
	     , strPONumber						= strPONumber
	     , strBOLNumber						= strBOLNumber
	     , intSplitId						= intSplitId
	     , intEntitySalespersonId			= intEntitySalespersonId
	     , ysnBlended						= ysnBlended
	     , intRecipeId						= intRecipeId
	     , intSubLocationId					= intSubLocationId
		 , intOwnershipType					= NULL --intOwnershipType
	     , intCostTypeId					= intCostTypeId
	     , intMarginById					= intMarginById
	     , intCommentTypeId					= intCommentTypeId
	     , dblMargin						= dblMargin
	     , dblRecipeQuantity				= dblRecipeQuantity
	     , intStorageScheduleTypeId			= intStorageScheduleTypeId
	     , intDestinationGradeId			= intDestinationGradeId
	     , intDestinationWeightId			= intDestinationWeightId
	     , intCurrencyExchangeRateTypeId	= intCurrencyExchangeRateTypeId
	     , intCurrencyExchangeRateId		= intCurrencyExchangeRateId
	     , dblCurrencyExchangeRate			= dblCurrencyExchangeRate
	     , intSubCurrencyId					= intSubCurrencyId
	     , dblSubCurrencyRate				= dblSubCurrencyRate
		 , intBookId						= intBookId
		 , intSubBookId						= intSubBookId
	FROM 
		vyuLGLoadScheduleForInvoice
	 
	UNION ALL
		
	SELECT strTransactionType				= 'Load Schedule' COLLATE Latin1_General_CI_AS
	     , strTransactionNumber				= strLoadNumber
	     , strShippedItemId					= 'lgis:' + CAST(LWS.intLoadDetailId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	     , intEntityCustomerId				= intEntityCustomerId
	     , intCurrencyId					= LWS.intCurrencyId
	     , intSalesOrderId					= NULL
	     , intSalesOrderDetailId			= NULL
	     , strSalesOrderNumber				= ''
	     , dtmProcessDate					= dtmProcessDate
	     , intInventoryShipmentId			= NULL
	     , intInventoryShipmentItemId		= NULL
	     , intInventoryShipmentChargeId		= NULL
	     , strInventoryShipmentNumber		= NULL
	     , intShipmentId					= NULL
	     , strShipmentNumber				= NULL
	     , intLoadId						= intLoadId
	     , intLoadDetailId					= LWS.intLoadDetailId
	     , intLotId							= NULL
	     , strLoadNumber					= strLoadNumber
	     , intRecipeItemId					= NULL
	     , intContractHeaderId				= LWS.intContractHeaderId
	     , intContractDetailId				= LWS.intContractDetailId
	     , intCompanyLocationId				= intCompanyLocationId
	     , intShipToLocationId				= NULL
	     , intFreightTermId					= NULL
	     , intItemId						= LWS.intItemId
	     , strItemDescription				= LWS.strItemDescription
	     , intItemUOMId						= NULL
		 , intPriceUOMId					= NULL
	     , intOrderUOMId					= NULL
	     , intShipmentItemUOMId				= NULL
		 , intWeightUOMId					= NULL
		 , dblWeight						= NULL
	     , dblQtyShipped					= 1
	     , dblQtyOrdered					= 1
	     , dblShipmentQuantity				= 1 
	     , dblShipmentQtyShippedTotal		= 1
	     , dblQtyRemaining					= 1
		 , dblPriceUOMQuantity				= 1
	     , dblDiscount						= 0
	     , dblPrice							= CAST(LWS.dblPrice AS DECIMAL(18,6))
		 , dblUnitPrice						= CAST(dblShipmentUnitPrice AS DECIMAL(18,6))
	     , dblShipmentUnitPrice				= CAST(dblShipmentUnitPrice AS DECIMAL(18,6))
	     , strPricing						= ''
	     , strVFDDocumentNumber				= NULL
	     , dblTotalTax						= 0
	     , dblTotal							= LWS.dblTotal
	     , intStorageLocationId				= NULL
	     , intTermId						= NULL
	     , intEntityShipViaId				= NULL
	     , intTicketId						= NULL
	     , intTaxGroupId					= NULL 
	     , dblGrossWt						= 1
	     , dblTareWt						= 1
	     , dblNetWt							= 1
	     , strPONumber						= ''
	     , strBOLNumber						= ''
	     , intSplitId						= NULL
	     , intEntitySalespersonId			= NULL
	     , ysnBlended						= NULL
	     , intRecipeId						= NULL
	     , intSubLocationId					= NULL
		 , intOwnershipType					= NULL --intOwnershipType
	     , intCostTypeId					= NULL
	     , intMarginById					= NULL
	     , intCommentTypeId					= NULL
	     , dblMargin						= NULL
	     , dblRecipeQuantity				= NULL
	     , intStorageScheduleTypeId			= NULL
	     , intDestinationGradeId			= ARID.intDestinationGradeId
	     , intDestinationWeightId			= ARID.intDestinationWeightId
	     , intCurrencyExchangeRateTypeId	= ARID.intCurrencyExchangeRateTypeId
	     , intCurrencyExchangeRateId		= ARID.intCurrencyExchangeRateId
	     , dblCurrencyExchangeRate			= ARID.dblCurrencyExchangeRate
	     , intSubCurrencyId					= LWS.intCurrencyId
	     , dblSubCurrencyRate				= NULL
		 , intBookId						= NULL
		 , intSubBookId						= NULL
	FROM (
		SELECT intLoadDetailId
			 , intCurrencyId
			 , strLoadNumber
			 , intEntityCustomerId
			 , strCustomerName
			 , dtmProcessDate
			 , intLoadId
			 , intContractHeaderId
			 , strContractNumber
			 , intContractDetailId
			 , intContractSeq
			 , intCompanyLocationId
			 , strLocationName
			 , intItemId
			 , strItemNo
			 , strItemDescription
			 , dblPrice
			 , dblShipmentUnitPrice
			 , dblTotal
			 , ysnPosted
		FROM vyuLGLoadWarehouseServicesForInvoice WITH (NOLOCK)
		WHERE ysnPosted = 1 
		 AND ISNULL(intItemId, 0) <> 0
	) LWS
	LEFT OUTER JOIN (
		SELECT intInventoryShipmentItemId
			 , intRecipeItemId
			 , strShipmentNumber
			 , intDestinationGradeId
			 , intLoadDetailId
			 , intDestinationWeightId
			 , intCurrencyExchangeRateTypeId
			 , intCurrencyExchangeRateId
			 , dblCurrencyExchangeRate
		FROM tblARInvoiceDetail WITH (NOLOCK)
		WHERE ISNULL(intLoadDetailId, 0) <> 0
	) ARID ON ARID.intLoadDetailId = LWS.intLoadDetailId

	UNION ALL

	SELECT strTransactionType				= 'Load Schedule' COLLATE Latin1_General_CI_AS
	     , strTransactionNumber				= strLoadNumber
	     , strShippedItemId					= 'lgis:' + CAST(LC.intLoadDetailId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
	     , intEntityCustomerId				= intEntityCustomerId
	     , intCurrencyId					= LC.intCurrencyId
	     , intSalesOrderId					= NULL
	     , intSalesOrderDetailId			= NULL
	     , strSalesOrderNumber				= ''
	     , dtmProcessDate					= dtmProcessDate
	     , intInventoryShipmentId			= NULL
	     , intInventoryShipmentItemId		= NULL
	     , intInventoryShipmentChargeId		= NULL
	     , strInventoryShipmentNumber		= NULL
	     , intShipmentId					= NULL
	     , strShipmentNumber				= NULL
	     , intLoadId						= LC.intLoadId
	     , intLoadDetailId					= LC.intLoadDetailId
	     , intLotId							= NULL
	     , strLoadNumber					= strLoadNumber
	     , intRecipeItemId					= NULL
	     , intContractHeaderId				= LC.intContractHeaderId
	     , intContractDetailId				= LC.intContractDetailId
	     , intCompanyLocationId				= intCompanyLocationId
	     , intShipToLocationId				= NULL
	     , intFreightTermId					= NULL
	     , intItemId						= LC.intItemId
	     , strItemDescription				= LC.strItemDescription
	     , intItemUOMId						= LC.intPriceItemUOMId
		 , intPriceUOMId					= LC.intPriceItemUOMId
	     , intOrderUOMId					= LC.intPriceItemUOMId
	     , intShipmentItemUOMId				= NULL
		 , intWeightUOMId					= LC.intPriceItemUOMId
		 , dblWeight						= NULL
	     , dblQtyShipped					= 1
	     , dblQtyOrdered					= 1
	     , dblShipmentQuantity				= 1 
	     , dblShipmentQtyShippedTotal		= 1
	     , dblQtyRemaining					= 1
		 , dblPriceUOMQuantity				= 1
	     , dblDiscount						= 0
	     , dblPrice							= CAST(LC.dblPrice AS DECIMAL(18,6))
		 , dblPrice							= CAST(dblShipmentUnitPrice AS DECIMAL(18,6))
	     , dblShipmentUnitPrice				= CAST(dblShipmentUnitPrice AS DECIMAL(18,6))
	     , strPricing						= ''
	     , strVFDDocumentNumber				= NULL
	     , dblTotalTax						= 0
	     , dblTotal							= LC.dblTotal
	     , intStorageLocationId				= NULL
	     , intTermId						= NULL
	     , intEntityShipViaId				= NULL
	     , intTicketId						= NULL
	     , intTaxGroupId					= NULL 
	     , dblGrossWt						= 1
	     , dblTareWt						= 1
	     , dblNetWt							= 1
	     , strPONumber						= ''
	     , strBOLNumber						= ''
	     , intSplitId						= NULL
	     , intEntitySalespersonId			= NULL
	     , ysnBlended						= NULL
	     , intRecipeId						= NULL
	     , intSubLocationId					= NULL
		 , intOwnershipType					= NULL --intOwnershipType
	     , intCostTypeId					= NULL
	     , intMarginById					= NULL
	     , intCommentTypeId					= NULL
	     , dblMargin						= NULL
	     , dblRecipeQuantity				= NULL
	     , intStorageScheduleTypeId			= NULL
	     , intDestinationGradeId			= ARID.intDestinationGradeId
	     , intDestinationWeightId			= ARID.intDestinationWeightId
	     , intCurrencyExchangeRateTypeId	= ARID.intCurrencyExchangeRateTypeId
	     , intCurrencyExchangeRateId		= ARID.intCurrencyExchangeRateId
	     , dblCurrencyExchangeRate			= ARID.dblCurrencyExchangeRate
	     , intSubCurrencyId					= LC.intCurrencyId
	     , dblSubCurrencyRate				= NULL
		 , intBookId						= NULL
		 , intSubBookId						= NULL
	FROM (
		SELECT intLoadId
		     , intLoadDetailId
		     , intCurrencyId
		     , strLoadNumber
		     , intEntityCustomerId
		     , strCustomerName
		     , intContractHeaderId
		     , strContractNumber
		     , dtmProcessDate
		     , intContractDetailId
		     , intContractSeq
		     , intCompanyLocationId
		     , strLocationName
		     , intItemId
		     , strItemNo 
		     , strItemDescription
		     , dblPrice
		     , dblShipmentUnitPrice
		     , dblTotal
			 , intPriceItemUOMId
		     , ysnPosted
		FROM vyuLGLoadCostForCustomer WITH (NOLOCK) 
		WHERE [ysnPosted] = 1
	) LC
	LEFT OUTER JOIN (
		SELECT intLoadDetailId
			 , intDestinationGradeId
			 , intDestinationWeightId
			 , intCurrencyExchangeRateTypeId
			 , intCurrencyExchangeRateId
			 , dblCurrencyExchangeRate
		FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		WHERE ISNULL(intLoadDetailId, 0) = 0
	) ARID ON ARID.intLoadDetailId = LC.intLoadDetailId

	UNION ALL

	SELECT strTransactionType				= 'Load Schedule' COLLATE Latin1_General_CI_AS
		 , strTransactionNumber				= strLoadNumber
		 , strShippedItemId					= 'lgis:' + CAST(LC.intLoadDetailId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
		 , intEntityCustomerId				= intEntityCustomerId
		 , intCurrencyId					= LC.intCurrencyId
		 , intSalesOrderId					= NULL
		 , intSalesOrderDetailId			= NULL
		 , strSalesOrderNumber				= ''
		 , dtmProcessDate					= dtmProcessDate
		 , intInventoryShipmentId			= NULL
		 , intInventoryShipmentItemId		= NULL
		 , intInventoryShipmentChargeId		= NULL
		 , strInventoryShipmentNumber		= NULL
		 , intShipmentId					= NULL
		 , strShipmentNumber				= NULL
		 , intLoadId						= LC.intLoadId
		 , intLoadDetailId					= LC.intLoadDetailId
		 , intLotId							= NULL
		 , strLoadNumber					= strLoadNumber
		 , intRecipeItemId					= NULL
		 , intContractHeaderId				= LC.intContractHeaderId
		 , intContractDetailId				= LC.intContractDetailId
		 , intCompanyLocationId				= intCompanyLocationId
		 , intShipToLocationId				= NULL
		 , intFreightTermId					= NULL
		 , intItemId						= LC.intItemId
		 , strItemDescription				= LC.strItemDescription
		 , intItemUOMId						= NULL
		 , intPriceUOMId					= NULL
		 , intOrderUOMId					= NULL
		 , intShipmentItemUOMId				= NULL
		 , intWeightUOMId					= NULL
		 , dblWeight						= NULL
		 , dblQtyShipped					= 1
		 , dblQtyOrdered					= 1
		 , dblShipmentQuantity				= 1 
		 , dblShipmentQtyShippedTotal		= 1
		 , dblQtyRemaining					= 1
		 , dblPriceUOMQuantity				= 1
		 , dblDiscount						= 0
		 , dblPrice							= CAST(LC.dblPrice AS DECIMAL(18,6))
		 , dblPrice							= CAST(dblShipmentUnitPrice AS DECIMAL(18,6))
		 , dblShipmentUnitPrice				= CAST(dblShipmentUnitPrice AS DECIMAL(18,6))
		 , strPricing						= ''
		 , strVFDDocumentNumber				= NULL
		 , dblTotalTax						= 0
		 , dblTotal							= LC.dblTotal
		 , intStorageLocationId				= NULL
		 , intTermId						= NULL
		 , intEntityShipViaId				= NULL
		 , intTicketId						= NULL
		 , intTaxGroupId					= NULL 
		 , dblGrossWt						= 1
		 , dblTareWt						= 1
		 , dblNetWt							= 1
		 , strPONumber						= ''
		 , strBOLNumber						= ''
		 , intSplitId						= NULL
		 , intEntitySalespersonId			= NULL
		 , ysnBlended						= NULL
		 , intRecipeId						= NULL
		 , intSubLocationId					= NULL
		 , intOwnershipType					= NULL --intOwnershipType
		 , intCostTypeId					= NULL
		 , intMarginById					= NULL
		 , intCommentTypeId					= NULL
		 , dblMargin						= NULL
		 , dblRecipeQuantity				= NULL
		 , intStorageScheduleTypeId			= NULL
		 , intDestinationGradeId			= ARID.intDestinationGradeId
		 , intDestinationWeightId			= ARID.intDestinationWeightId
		 , intCurrencyExchangeRateTypeId	= ARID.intCurrencyExchangeRateTypeId
		 , intCurrencyExchangeRateId		= ARID.intCurrencyExchangeRateId
		 , dblCurrencyExchangeRate			= ARID.dblCurrencyExchangeRate
		 , intSubCurrencyId					= LC.intCurrencyId
		 , dblSubCurrencyRate				= NULL
		 , intBookId						= NULL
		 , intSubBookId						= NULL
	FROM (
		SELECT intLoadId
			 , intLoadDetailId
			 , intCurrencyId
			 , strLoadNumber 
			 , intEntityCustomerId
			 , strCustomerName
			 , intContractHeaderId
			 , strContractNumber
			 , dtmProcessDate
			 , intContractDetailId
			 , intContractSeq
			 , intCompanyLocationId
			 , strLocationName
			 , intItemId
			 , strItemNo 
			 , strItemDescription
			 , dblPrice
			 , dblShipmentUnitPrice
			 , dblTotal
			 , ysnPosted
		FROM vyuLGLoadStorageCostForInvoice WITH (NOLOCK)
		WHERE ysnPosted = 1
	) LC
	LEFT OUTER JOIN (
		SELECT intLoadDetailId
			 , intDestinationGradeId
			 , intDestinationWeightId
			 , intCurrencyExchangeRateTypeId
			 , intCurrencyExchangeRateId
			 , dblCurrencyExchangeRate
		FROM tblARInvoiceDetail WITH (NOLOCK)
		WHERE ISNULL(intLoadDetailId, 0) = 0
	) ARID ON ARID.intLoadDetailId = LC.intLoadDetailId
) SHIPPEDITEMS
INNER JOIN (
	SELECT intEntityId
		 , intCurrencyId
		 , strName		 
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) CUSTOMER ON SHIPPEDITEMS.intEntityCustomerId = CUSTOMER.intEntityId
LEFT OUTER JOIN ( 
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) SALESPERSON ON SHIPPEDITEMS.intEntitySalespersonId = SALESPERSON.intEntityId
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
		 , intItemUOMId
		 , strOrderUnitMeasure
		 , intItemWeightUOMId
		 , intPricingTypeId
		 , dblCashPrice
		 , dblDetailQuantity
		 , intFreightTermId
		 , dblShipQuantity
		 , dblOrderQuantity
		 , dblSubCurrencyRate
		 , intCurrencyExchangeRateTypeId
		 , strCurrencyExchangeRateType
		 , intCurrencyExchangeRateId
		 , dblCurrencyExchangeRate
	 FROM dbo.vyuCTCustomerContract WITH (NOLOCK)
) CUSTOMERCONTRACT ON SHIPPEDITEMS.intContractHeaderId = CUSTOMERCONTRACT.intContractHeaderId 
				  AND SHIPPEDITEMS.intContractDetailId = CUSTOMERCONTRACT.intContractDetailId
LEFT OUTER JOIN (
	SELECT intItemId
		 , strItemNo
		 , strDescription
		 , strLotTracking
	FROM dbo.tblICItem WITH (NOLOCK)
	WHERE ISNULL(strBundleType, '') <> 'Option'
) ITEM ON SHIPPEDITEMS.intItemId = ITEM.intItemId
LEFT OUTER JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , IU.intUnitMeasureId
		 , UM.strUnitMeasure
	FROM dbo.tblICItemUOM IU WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
) ITEMUOM ON SHIPPEDITEMS.intItemUOMId = ITEMUOM.intItemUOMId
LEFT OUTER JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , IU.intUnitMeasureId
		 , UM.strUnitMeasure
	FROM dbo.tblICItemUOM IU WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
) ITEMORDERUOM ON SHIPPEDITEMS.intOrderUOMId = ITEMORDERUOM.intItemUOMId
LEFT OUTER JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , IU.intUnitMeasureId
		 , UM.strUnitMeasure
	FROM dbo.tblICItemUOM IU WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
) ITEMPRICEUOM ON SHIPPEDITEMS.intPriceUOMId = ITEMPRICEUOM.intItemUOMId
LEFT OUTER JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , IU.intUnitMeasureId
		 , UM.strUnitMeasure		 
	FROM dbo.tblICItemUOM IU WITH (NOLOCK)
	INNER JOIN (
		SELECT intUnitMeasureId
			 , strUnitMeasure
		FROM dbo.tblICUnitMeasure WITH (NOLOCK)
	) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
) WEIGHTUOM ON SHIPPEDITEMS.intWeightUOMId = WEIGHTUOM.intItemUOMId
		   AND SHIPPEDITEMS.intItemId = WEIGHTUOM.intItemId
LEFT OUTER JOIN (
	SELECT intTicketId
		 , strTicketNumber
		 , strCustomerReference
		 , ysnShowForShipment = case when 
		 								intTicketTypeId = 2 and 
										intStorageScheduleTypeId = -6 
											then 0
		 						else 1 end
	FROM dbo.tblSCTicket WITH (NOLOCK)
) SCALETICKET ON SHIPPEDITEMS.intTicketId = SCALETICKET.intTicketId
LEFT OUTER JOIN (
	SELECT intWeightGradeId		= intWeightGradeId
		 , strDestinationGrade  = strWeightGradeDesc
	FROM dbo.tblCTWeightGrade WITH (NOLOCK)
) DESTINATIONGRADE ON SHIPPEDITEMS.intDestinationGradeId = DESTINATIONGRADE.intWeightGradeId
LEFT OUTER JOIN (
	SELECT intWeightGradeId		= intWeightGradeId
		 , strDestinationWeight	= strWeightGradeDesc
	FROM dbo.tblCTWeightGrade WITH (NOLOCK)
) DESTINATIONWEIGHT ON SHIPPEDITEMS.intDestinationWeightId = DESTINATIONWEIGHT.intWeightGradeId
LEFT OUTER JOIN (
	SELECT intTaxGroupId
		 , strTaxGroup
	FROM dbo.tblSMTaxGroup WITH (NOLOCK)
) TAXGROUP ON SHIPPEDITEMS.intTaxGroupId = TAXGROUP.intTaxGroupId
LEFT OUTER JOIN (
	SELECT intTermID
		 , strTerm
	FROM dbo.tblSMTerm WITH (NOLOCK)
) TERM ON SHIPPEDITEMS.intTermId = TERM.intTermID
LEFT OUTER JOIN (
	SELECT intEntityId
		 , strShipVia
	FROM dbo.tblSMShipVia WITH (NOLOCK)
) SHIPVIA ON SHIPPEDITEMS.intEntityShipViaId = SHIPVIA.intEntityId
LEFT OUTER JOIN (
	SELECT intStorageLocationId
		 , strName = CAST(ISNULL(strName, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	FROM dbo.tblICStorageLocation WITH (NOLOCK)
) STORAGELOCATION ON SHIPPEDITEMS.intStorageLocationId = STORAGELOCATION.intStorageLocationId
LEFT OUTER JOIN (
	SELECT intCompanyLocationSubLocationId
		 , strSubLocationName = CAST(ISNULL(strSubLocationName, '') AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	FROM dbo.tblSMCompanyLocationSubLocation WITH (NOLOCK)
) SUBLOCATION ON SHIPPEDITEMS.intSubLocationId = SUBLOCATION.intCompanyLocationSubLocationId
LEFT OUTER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName
	FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
) COMPANYLOCATION ON SHIPPEDITEMS.intCompanyLocationId = COMPANYLOCATION.intCompanyLocationId
LEFT OUTER JOIN (
	SELECT intCurrencyID
		 , intCent
		 , strCurrency
	FROM dbo.tblSMCurrency WITH (NOLOCK)
) CURRENCY ON SHIPPEDITEMS.intSubCurrencyId = CURRENCY.intCurrencyID
LEFT OUTER JOIN (
	SELECT *
	FROM dbo.tblSMCurrencyExchangeRateType WITH (NOLOCK)
) CURRENCYERT ON SHIPPEDITEMS.intCurrencyExchangeRateTypeId = CURRENCYERT.intCurrencyExchangeRateTypeId
LEFT OUTER JOIN (
	SELECT intBookId
		 , strBook 
	FROM dbo.tblCTBook WITH (NOLOCK)
) BOOK ON BOOK.intBookId = SHIPPEDITEMS.intBookId
LEFT OUTER JOIN (
	SELECT intSubBookId
		 , strSubBook
	FROM dbo.tblCTSubBook WITH (NOLOCK)
) SUBBOOK ON SUBBOOK.intSubBookId = SHIPPEDITEMS.intSubBookId
OUTER APPLY (
	SELECT TOP 1 intDefaultCurrencyId 
	FROM dbo.tblSMCompanyPreference WITH (NOLOCK) 
	WHERE intDefaultCurrencyId IS NOT NULL 
	  AND intDefaultCurrencyId <> 0
) DEFAULTCURRENCY
GO