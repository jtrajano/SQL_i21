CREATE PROCEDURE [dbo].[uspSTReportCheckoutCategoryFuelSaleRecap]
		@intCheckoutId INT 
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
   select  B.strCategoryCode,B.strDescription, (A.dblTotalSalesAmount + A.dblPromotionalDiscountAmount + A.dblManagerDiscountAmount) 
   As GrossAmount, (A.dblPromotionalDiscountAmount + A.dblManagerDiscountAmount) AS DiscontAmount, A.dblTotalSalesAmount 
   as NetAmount, C.dblAmount as PumpTotal, ( C.dblAmount - A.dblTotalSalesAmount ) as Variance, SUM ( C.dblAmount - A.dblTotalSalesAmount ) 
   over() as TotalVariance from tblSTCheckoutDepartmetTotals A JOIN tblICCategory B ON A.intCategoryId = B.intCategoryId 
   JOIN (select intCategoryId , SUM(dblAmount) as dblAmount from tblSTCheckoutPumpTotals where intCheckoutId = @intCheckoutId 
   group by intCategoryId) C ON A.intCategoryId = C.intCategoryId  where A.intCheckoutId = @intCheckoutId  
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH