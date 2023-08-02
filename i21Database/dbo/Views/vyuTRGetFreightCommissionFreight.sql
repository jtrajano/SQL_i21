﻿create view vyuTRGetFreightCommissionFreight    
as    
    
select     
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
 distributionDetailRL = ldd.strReceiptLink
  
from tblARInvoiceDetail aid    
 left join tblARInvoice ai on ai.intInvoiceId = aid.intInvoiceId  
 left join tblICItem ii on ii.intItemId = aid.intItemId  
 left join tblTRLoadDistributionDetail ldd on ldd.intLoadDistributionDetailId = aid.intLoadDistributionDetailId  
 left join tblTRLoadHeader lh on lh.strTransaction = ai.strActualCostId  
   
WHERE 
(ai.strType = 'Transport Delivery' OR ai.strType = 'Tank Delivery')
and strDocumentNumber like 'TR%'    
  
  