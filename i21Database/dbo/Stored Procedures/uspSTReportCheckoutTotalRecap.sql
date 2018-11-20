CREATE PROCEDURE [dbo].[uspSTReportCheckoutTotalRecap]
	@intCheckoutId INT 
	
AS

BEGIN TRY
	
   DECLARE @ErrMsg NVARCHAR(MAX)

   SELECT ISNULL(SUM(A.dblTotalSalesAmountComputed) OVER (),0) AS CategoryTotalSale
		, ISNULL(C.dblTotalTax ,0) AS TotalTax
		, ISNULL(D.dblAmount,0) AS TotalPayment
		, ISNULL(E.dblAmount,0) AS TotalCustomerCharges
		, ISNULL(F.dblAmount,0) AS TotalCustomerPayments
		, (ISNULL(SUM (A.dblTotalSalesAmountComputed) OVER(),0) + ISNULL(C.dblTotalTax,0) - ISNULL(D.dblAmount,0) - ISNULL(E.dblAmount,0) + ISNULL(F.dblAmount,0)) AS TotalToDeposit
		, ISNULL(G.dblTotalDeposit,0) AS TotalDeposits
		, (ISNULL(G.dblTotalDeposit,0) - (ISNULL(SUM (A.dblTotalSalesAmountComputed) OVER(),0) + ISNULL(C.dblTotalTax,0) - ISNULL(D.dblAmount,0) - ISNULL(E.dblAmount,0) + ISNULL(F.dblAmount,0))) AS CashOverShort
   FROM tblSTCheckoutDepartmetTotals A  
   LEFT OUTER JOIN tblICCategory B 
		ON A.intCategoryId = B.intCategoryId 
   LEFT OUTER JOIN (
					SELECT intCheckoutId, SUM(dblTotalTax) AS dblTotalTax 
					FROM tblSTCheckoutSalesTaxTotals 
					GROUP BY intCheckoutId
				   ) C ON A.intCheckoutId = C.intCheckoutId 
   LEFT OUTER JOIN (
					SELECT intCheckoutId, SUM(dblAmount) AS dblAmount 
					FROM tblSTCheckoutPaymentOptions 
					GROUP BY intCheckoutId
				   ) D ON A.intCheckoutId = D.intCheckoutId 
   LEFT OUTER JOIN (
					SELECT intCheckoutId, SUM(dblAmount) AS dblAmount 
					FROM tblSTCheckoutCustomerCharges 
					GROUP BY intCheckoutId
				   ) E ON A.intCheckoutId = E.intCheckoutId 
   LEFT OUTER JOIN (
					SELECT intCheckoutId, SUM(dblPaymentAmount) AS dblAmount 
					FROM tblSTCheckoutCustomerPayments 
					GROUP BY intCheckoutId
				   ) F ON A.intCheckoutId = F.intCheckoutId 
   LEFT OUTER JOIN (
					SELECT intCheckoutId, SUM(dblTotalDeposit) AS dblTotalDeposit 
					FROM tblSTCheckoutDeposits 
					GROUP BY intCheckoutId
				   ) G ON A.intCheckoutId =G.intCheckoutId 
   WHERE A.intCheckoutId = @intCheckoutId 
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH