CREATE PROCEDURE [dbo].[uspSTReportCheckoutDepartmentSaleRecap]
	@intCheckoutId INT 
	
AS

BEGIN TRY
	
   DECLARE @ErrMsg NVARCHAR(MAX)

   select B.strCategoryCode,B.strDescription ,A.intTotalSalesCount, A.dblTotalSalesAmount,
   A.dblRegisterSalesAmount , SUM(A.dblTotalSalesAmount) OVER ()  as CategoryTotalSale,
   C.dblTotalTax TotalTax, D.dblAmount  as TotalPayment,
   E.dblAmount  as TotalCustomerCharges, F.dblAmount  as TotalCustomerPayments,
   (SUM (A.dblTotalSalesAmount) over() + (C.dblTotalTax) - (D.dblAmount)  -
   (E.dblAmount) + (F.dblAmount))  as TotalToDeposit,
   G.dblTotalDeposit As TotalDeposits, ((G.dblTotalDeposit)  - 
   (SUM (A.dblTotalSalesAmount) over() + (C.dblTotalTax) 
   -(D.dblAmount) - (E.dblAmount)  + (F.dblAmount))) as CashOverShort
   from tblSTCheckoutDepartmetTotals A  JOIN tblICCategory B ON A.intCategoryId = B.intCategoryId 
   JOIN (select intCheckoutId , SUM(dblTotalTax) as dblTotalTax from tblSTCheckoutSalesTaxTotals 
   group by intCheckoutId) C ON A.intCheckoutId = C.intCheckoutId 
   JOIN (select intCheckoutId , SUM(dblAmount) as dblAmount from tblSTCheckoutPaymentOptions 
   group by intCheckoutId) D  ON A.intCheckoutId = D.intCheckoutId 
   JOIN (select intCheckoutId , SUM(dblAmount) as dblAmount from tblSTCheckoutCustomerCharges 
   group by intCheckoutId) E  ON A.intCheckoutId = E.intCheckoutId 
   JOIN (select intCheckoutId , SUM(dblAmount) as dblAmount from tblSTCheckoutCustomerPayments 
   group by intCheckoutId) F  ON A.intCheckoutId = F.intCheckoutId 
   JOIN (select intCheckoutId , SUM(dblTotalDeposit) as dblTotalDeposit from tblSTCheckoutDeposits 
   group by intCheckoutId) G ON A.intCheckoutId =G.intCheckoutId 
   where A.intCheckoutId = @intCheckoutId 
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH


