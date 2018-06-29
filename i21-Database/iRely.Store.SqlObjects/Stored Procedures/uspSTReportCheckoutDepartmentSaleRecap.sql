CREATE PROCEDURE [dbo].[uspSTReportCheckoutDepartmentSaleRecap]
	@intCheckoutId INT 
	
AS

BEGIN TRY
	
   DECLARE @ErrMsg NVARCHAR(MAX)

   select B.strCategoryCode,B.strDescription ,A.intTotalSalesCount, A.dblTotalSalesAmount,
   A.dblRegisterSalesAmount , ISNULL(SUM(A.dblTotalSalesAmount) OVER (),0)  as CategoryTotalSale,
   ISNULL(C.dblTotalTax,0) as TotalTax, ISNULL(D.dblAmount,0)  as TotalPayment,
   ISNULL(E.dblAmount,0)  as TotalCustomerCharges, ISNULL(F.dblAmount,0)  as TotalCustomerPayments,
   (ISNULL(SUM (A.dblTotalSalesAmount) over(),0) + ISNULL(C.dblTotalTax,0) - ISNULL(D.dblAmount,0)  -
   ISNULL(E.dblAmount,0) + ISNULL(F.dblAmount,0))  as TotalToDeposit,
   ISNULL(G.dblTotalDeposit,0) As TotalDeposits, (ISNULL(G.dblTotalDeposit,0)  - 
   (ISNULL(SUM (A.dblTotalSalesAmount) over(),0) + ISNULL(C.dblTotalTax,0) 
   -ISNULL(D.dblAmount,0) - ISNULL(E.dblAmount,0)  + ISNULL(F.dblAmount,0))) as CashOverShort
   from tblSTCheckoutDepartmetTotals A  LEFT OUTER JOIN tblICCategory B ON A.intCategoryId = B.intCategoryId 
   LEFT OUTER JOIN (select intCheckoutId , SUM(dblTotalTax) as dblTotalTax from tblSTCheckoutSalesTaxTotals 
   group by intCheckoutId) C ON A.intCheckoutId = C.intCheckoutId 
   LEFT OUTER JOIN (select intCheckoutId , SUM(dblAmount) as dblAmount from tblSTCheckoutPaymentOptions 
   group by intCheckoutId) D  ON A.intCheckoutId = D.intCheckoutId 
   LEFT OUTER JOIN (select intCheckoutId , SUM(dblAmount) as dblAmount from tblSTCheckoutCustomerCharges 
   group by intCheckoutId) E  ON A.intCheckoutId = E.intCheckoutId 
   LEFT OUTER JOIN (select intCheckoutId , SUM(dblAmount) as dblAmount from tblSTCheckoutCustomerPayments 
   group by intCheckoutId) F  ON A.intCheckoutId = F.intCheckoutId 
   LEFT OUTER JOIN (select intCheckoutId , SUM(dblTotalDeposit) as dblTotalDeposit from tblSTCheckoutDeposits 
   group by intCheckoutId) G ON A.intCheckoutId =G.intCheckoutId 
   where A.intCheckoutId = @intCheckoutId 
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH