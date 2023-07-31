CREATE VIEW vyuTRGetFreightCommissionFreight      

AS
      
SELECT       
    aid.intItemId,    
    ai.intInvoiceId,    
    ii.intCategoryId,    
    aid.intLoadDistributionDetailId,    
    aid.strItemDescription,    
    aid.strBOLNumberDetail,    
    aid.dblQtyShipped,    
    dblFreightRate = CASE WHEN ldd.intLoadDistributionDetailId IS NULL THEN ISNULL(aid.dblBasePrice, 0) ELSE ISNULL(ldd.dblFreightRate, 0) END,    
    aid.dblTotal,    
    lh.dtmLoadDateTime,  
    distributionDetailRL = ldd.strReceiptLink,
    ldd.dblDistSurcharge,
    dblMainUnit = aid.dblQtyShipped
    
FROM tblARInvoiceDetail aid      
    LEFT JOIN tblARInvoice ai on ai.intInvoiceId = aid.intInvoiceId    
    LEFT JOIN tblICItem ii on ii.intItemId = aid.intItemId    
    LEFT JOIN tblTRLoadDistributionDetail ldd on ldd.intLoadDistributionDetailId = aid.intLoadDistributionDetailId    
    LEFT JOIN tblTRLoadHeader lh on lh.strTransaction = ai.strActualCostId    
     
WHERE 
(ai.strType = 'Transport Delivery' OR ai.strType = 'Tank Delivery')    
    AND strDocumentNumber LIKE 'TR%'      