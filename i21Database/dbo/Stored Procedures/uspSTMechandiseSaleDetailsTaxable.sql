CREATE PROCEDURE  [dbo].[uspSTMechandiseSaleDetailsTaxable]                
 @dtmFromDate AS DATETIME,      
 @dtmToDate AS DATETIME      
AS                
              
SET QUOTED_IDENTIFIER OFF                        
SET ANSI_NULLS ON                        
SET NOCOUNT ON                        
SET XACT_ABORT ON                     
      
BEGIN          
        
    SELECT T0.intStoreId, T2.intStoreNo, T2.strDescription AS    
    strStoreName, T5.intCategoryId, T5.strDescription, ISNULL (SUM    
    (T1.dblTotalSalesAmountRaw), 0) AS dblTotalSalesAmountRaw, SUM    
    (T1.intItemsSold) AS intItemsSold, T4.ysnUseTaxFlag2 FROM    
    tblSTCheckoutHeader T0     
    INNER JOIN tblSTCheckoutDepartmetTotals T1 ON T0.intCheckoutId = T1.intCheckoutId     
    INNER JOIN tblSTStore T2 ON T0.intStoreId = T2.intStoreId     
    INNER JOIN tblICItem T3 ON T1.intItemId = T3.intItemId     
    INNER JOIN tblICCategoryLocation T4 ON T3.intCategoryId = T4.intCategoryId     
    INNER JOIN tblICCategory T5 ON T4.intCategoryId = T5.intCategoryId     
    WHERE ISNULL(T4.ysnUseTaxFlag2, 0) <> 0 AND ISNULL (T0.intInvoiceId,0) <> 0      
    AND T0.dtmCheckoutDate BETWEEN @dtmFromDate AND @dtmToDate      
    GROUP BY T0.intStoreId, T2.intStoreNo,    
    T2.strDescription, T5.intCategoryId, T5.strDescription,T4.ysnUseTaxFlag2     
    ORDER BY T4.ysnUseTaxFlag2, T0.intStoreId    
      
END