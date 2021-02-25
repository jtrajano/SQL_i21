CREATE VIEW [dbo].[vyuAGWorkOrderForInvoice]  
AS  
  
SELECT strTransactionType   =  'Inventory Shipment' COLLATE Latin1_General_CI_AS  --'AG Work Order' COLLATE Latin1_General_CI_AS    
--,ICSHIP.strShipmentNumber  
   ,strTransactionNumber  =  WO.strOrderNumber COLLATE Latin1_General_CI_AS    
   ,strShippedItemId     =  'agwo:'  + CAST(WO.intWorkOrderId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS  
   ,intEntityCustomerId = WO.intEntityCustomerId  
   ,intCurrencyId  = DEFAULTCURRENCY.intDefaultCurrencyId  
   ,intSalesOrderId  = NULL  
   ,intSalesOrderDetailId = NULL  
   ,strSalesOrderNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS  
   ,dtmProcessDate  = GETDATE()  
   ,intInventoryShipmentId = ICSHIP.intInventoryShipmentId  
   ,intInventoryShipmentItemId = NULL  
   ,intInventoryShipmentChargeId = NULL  
   ,strInventoryShipmentNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS   
   ,intShipmentId   = NULL  
   ,strShipmentNumber  = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS    
   ,intLoadId    = NULL  
   ,intLoadDetailId   = NULL  
   ,intLotId     = NULL  
   ,strLoadNumber   = NULL  
   ,intRecipeItemId   = NULL  
   ,intContractHeaderId  = CH.intContractHeaderId  
   ,intContractDetailId  = CD.intContractDetailId  
   ,intCompanyLocationId  = WO.intCompanyLocationId  
   ,intShipToLocationId  = WO.intCompanyLocationId  
   ,intFreightTermId   = NULL  
   ,intItemId    = WOD.intItemId  
   ,strItemDescription  = ICITEM.strDescription  
   ,intItemUOMId    = WOD.intItemUOMId  
   ,intOrderUOMId   = WOD.intItemUOMId  
   ,intShipmentItemUOMId  = NULL  
   ,intWeightUOMId   = NULL  
   ,dblWeight    = NULL  
   ,dblQtyShipped   = ISNULL(WOD.dblQtyShipped,0)  
   ,dblQtyOrdered   = ISNULL(WOD.dblQtyOrdered,0)  
   ,dblShipmentQuantity  = ISNULL(WOD.dblQtyShipped,0)  
   ,dblShipmentQtyShippedTotal = ISNULL(WOD.dblQtyOrdered,0)  
   ,dblQtyRemaining   = (CASE WHEN (WOD.dblQtyOrdered - ISNULL(WOD.dblQtyShipped,0)) > 0   
                                                    THEN ((WOD.dblQtyOrdered  - ISNULL(WOD.dblQtyShipped,0)))   
                                                    ELSE 0 END)  
   ,dblDiscount    = WOD.dblDiscount  
   ,dblPrice     = WOD.dblPrice  
   ,dblShipmentUnitPrice  = 0  
   ,intPriceUOMId   = WOD.intPriceUOMId  
   ,strPricing    = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS  
   ,strVFDDocumentNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS    
   ,dblTotalTax     = 0.000000     
   ,dblTotal      = WOD.dblTotal  
   ,intStorageLocationId   = NULL  
   ,intTermId     = NULL    
   ,intEntityShipViaId   = NULL    
   ,intTicketId     = NULL    
   ,intTaxGroupId    = NULL    
   ,dblGrossWt     = NULL  
   ,dblTareWt     = NULL  
   ,dblNetWt      = NULL  
   ,strPONumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS    
   ,strBOLNumber = CAST('' AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS   
   ,intSplitId     = NULL    
   ,intEntitySalespersonId  = WO.intEntitySalesRepId  
   ,ysnBlended = CAST(0 AS BIT)    
   ,intRecipeId     = NULL    
   ,intSubLocationId    = NULL    
   ,intCostTypeId    = NULL    
   ,intMarginById    = NULL    
   ,intCommentTypeId    = NULL    
   ,dblMargin      = NULL    
   ,dblRecipeQuantity   = NULL    
   ,intStorageScheduleTypeId   = NULL      
   ,intDestinationGradeId =  CH.intGradeId    
   ,intDestinationWeightId =  CH.intWeightId    
   ,intCurrencyExchangeRateTypeId = CD.intRateTypeId    
   ,intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId    
   ,dblCurrencyExchangeRate   = CD.dblRate    
   ,intSubCurrencyId    = WOD.intSubCurrencyId  
   ,dblSubCurrencyRate   = NULL  
   ,intBookId     = CH.intBookId  
   ,intSubBookId     = CH.intSubBookId  
      
  
    FROM tblAGWorkOrder WO  
 INNER JOIN  
  (  
   SELECT * FROM  
    tblAGWorkOrderDetail WITH (NOLOCK)  
  ) WOD ON WOD.intWorkOrderId = WO.intWorkOrderId  
INNER JOIN (  
 SELECT intInventoryShipmentId  
  ,strReferenceNumber  
  ,strShipmentNumber  
 FROM tblICInventoryShipment WITH (NOLOCK)   
) ICSHIP   
ON --ICSHIP.intInventoryShipmentId = WO.intWorkOrderId    
  ICSHIP.strReferenceNumber = WO.strOrderNumber COLLATE Latin1_General_CI_AS    
  
INNER JOIN (    
 SELECT [intItemId]    
  ,[strItemNo]    
  ,[strDescription]    
 FROM tblICItem WITH (NOLOCK)    
 ) ICITEM ON WOD.[intItemId] = ICITEM.[intItemId]    
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = WOD.intContractDetailId    
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId    
OUTER APPLY (  
  SELECT TOP 1 intDefaultCurrencyId   
  FROM dbo.tblSMCompanyPreference WITH (NOLOCK)   
  WHERE intDefaultCurrencyId IS NOT NULL   
    AND intDefaultCurrencyId <> 0  
) DEFAULTCURRENCY