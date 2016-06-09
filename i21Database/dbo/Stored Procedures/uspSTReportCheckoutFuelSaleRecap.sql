CREATE PROCEDURE [dbo].[uspSTReportCheckoutFuelSaleRecap]
	@intCheckoutId INT  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
  
   select A.intCheckoutId , B.strLongUPCCode, C.strCategoryCode, A.dblPrice, A.dblQuantity, A.dblAmount,
   SUM(A.dblQuantity) OVER() as TotalQty, SUM(A.dblAmount) OVER() as TotalPump$Amount 
   from tblSTCheckoutPumpTotals A JOIN tblICItemUOM B ON A.intPumpCardCouponId = B.intItemUOMId 
   JOIN tblICCategory C ON A.intCategoryId = C.intCategoryId
   where intCheckoutId = @intCheckoutId
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH