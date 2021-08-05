CREATE VIEW [dbo].[vyuAGWorkOrderForInvoice]  
AS  
SELECT intWorkOrderId					= WO.intWorkOrderId
	 , strTransactionType				= 'Agronomy' COLLATE Latin1_General_CI_AS
	 , strTransactionNumber				= WO.strOrderNumber COLLATE Latin1_General_CI_AS    
	 , intEntityCustomerId				= WO.intEntityCustomerId  
	 , intCurrencyId					= ICSHIP.intCurrencyId
	 , dtmProcessDate					= CAST(GETDATE() AS DATE)
	 , intInventoryShipmentId			= ICSHIP.intInventoryShipmentId  
	 , intInventoryShipmentItemId		= SHIPITEM.intInventoryShipmentItemId  
	 , intInventoryShipmentChargeId		= NULL  
	 , strShipmentNumber				= ICSHIP.strShipmentNumber
	 , intSalespersonId					= WO.intEntitySalesRepId
	 , intContractHeaderId				= CH.intContractHeaderId
	 , intContractDetailId				= CD.intContractDetailId
	 , intCompanyLocationId				= WO.intCompanyLocationId
	 , intShipToLocationId				= ICSHIP.intShipToLocationId
	 , intFreightTermId					= ICSHIP.intFreightTermId
	 , intItemId						= SHIPITEM.intItemId
	 , strItemDescription				= ICITEM.strDescription
	 , intItemUOMId						= SHIPITEM.intItemUOMId
	 , intOrderUOMId					= SHIPITEM.intItemUOMId
	 , intShipmentItemUOMId				= SHIPITEM.intItemUOMId  
	 , intWeightUOMId					= SHIPITEM.intItemUOMId
	 , dblQtyShipped					= ISNULL(WOD.dblQtyShipped,0)  
	 , dblQtyOrdered					= ISNULL(WOD.dblQtyOrdered,0)  
	 , dblShipmentQuantity				= ISNULL(WOD.dblQtyShipped,0)  
	 , dblShipmentQtyShippedTotal		= ISNULL(WOD.dblQtyOrdered,0)  
	 , dblQtyRemaining					= (CASE WHEN (WOD.dblQtyOrdered - ISNULL(WOD.dblQtyShipped,0)) > 0   
                                                    THEN ((WOD.dblQtyOrdered  - ISNULL(WOD.dblQtyShipped,0)))   
                                                    ELSE 0 END)  
	 , dblDiscount						= WOD.dblDiscount  
     , dblPrice							= WOD.dblPrice  
     , intPriceUOMId					= WOD.intPriceUOMId  
     , intStorageLocationId				= SHIPITEM.intStorageLocationId
	 , intSubLocationId					= SHIPITEM.intSubLocationId
     , intTicketId						= SC.intTicketId    
     , intEntitySalespersonId			= WO.intEntitySalesRepId  
     , intDestinationGradeId			= CH.intGradeId    
     , intDestinationWeightId			= CH.intWeightId    
     , intCurrencyExchangeRateTypeId	= CD.intRateTypeId    
     , intCurrencyExchangeRateId		= CD.intCurrencyExchangeRateId    
     , dblCurrencyExchangeRate			= CD.dblRate    
     , intSubCurrencyId					= WOD.intSubCurrencyId  
     , intBookId						= CH.intBookId  
     , intSubBookId						= CH.intSubBookId
	 , intSplitId						= WO.intSplitId
FROM tblAGWorkOrder WO  
INNER JOIN tblAGWorkOrderDetail WOD WITH (NOLOCK) ON WOD.intWorkOrderId = WO.intWorkOrderId  
INNER JOIN tblICInventoryShipment ICSHIP WITH (NOLOCK) ON ICSHIP.strReferenceNumber = WO.strOrderNumber COLLATE Latin1_General_CI_AS
INNER JOIN tblICInventoryShipmentItem SHIPITEM WITH (NOLOCK) ON SHIPITEM.intInventoryShipmentId = ICSHIP.intInventoryShipmentId
INNER JOIN tblICItem ICITEM WITH (NOLOCK) ON WOD.intItemId = ICITEM.intItemId
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = WOD.intContractDetailId    
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId    
LEFT JOIN tblSCTicket SC ON SC.intTicketId = SHIPITEM.intSourceId