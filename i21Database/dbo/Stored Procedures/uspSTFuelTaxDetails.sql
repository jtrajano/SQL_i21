CREATE PROCEDURE  [dbo].[uspSTFuelTaxDetails]            
 @dtmFromDate AS DATETIME,  
 @dtmToDate AS DATETIME  
AS            
          
SET QUOTED_IDENTIFIER OFF                    
SET ANSI_NULLS ON                    
SET NOCOUNT ON                    
SET XACT_ABORT ON                 
  
BEGIN      
    
     SELECT T0.intStoreId, T3.intItemId,  
     T4.strDescription AS strStoreName, T6.intTaxCodeId,  
     T6.strDescription, T5.dblRate, SUM (T5.dblTax) AS dblTax   
     FROM tblSTCheckoutHeader T0   
     INNER JOIN tblSTCheckoutPumpTotals T1 ON T0.intCheckoutId = T1.intCheckoutId   
     INNER JOIN tblICItemUOM T2 ON T1.intPumpCardCouponId = T2.intItemUOMId   
     INNER JOIN tblICItem T3 ON T2.intItemId = T3.intItemId   
     INNER JOIN tblSTStore T4 ON T0.intStoreId = T4.intStoreId   
     INNER JOIN vyuARInvoiceTaxDetail T5 ON T0.intInvoiceId = T5.intInvoiceId AND T3.intItemId = T5.intItemId   
     INNER JOIN tblSMTaxCode T6 ON T5.intTaxCodeId = T6.intTaxCodeId   
     WHERE ISNULL (T0.intInvoiceId, 0) <> 0 AND T5.ysnTaxExempt = 0 AND T0.dtmCheckoutDate BETWEEN @dtmFromDate AND @dtmToDate  
     GROUP BY  
     T0.intStoreId, T3.intItemId,  
     T4.strDescription, T6.intTaxCodeId, T6.strDescription,  
     T5.dblRate   
     ORDER BY intStoreId  
  
END  