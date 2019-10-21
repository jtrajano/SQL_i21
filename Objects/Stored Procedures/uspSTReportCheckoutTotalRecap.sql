CREATE PROCEDURE [dbo].[uspSTReportCheckoutTotalRecap]
	@intCheckoutId INT 
	
AS

BEGIN TRY
	
   DECLARE @ErrMsg NVARCHAR(MAX)

   SELECT DISTINCT
        ISNULL(SUM(deptTotals.dblTotalSalesAmountComputed) OVER (), 0)	AS CategoryTotalSale
		, ISNULL(taxTotals.dblTotalTax, 0)								AS TotalTax
		, ISNULL(paymentOp.dblAmount, 0)								AS TotalPayment
		, ISNULL(customerChange.dblAmount, 0)							AS TotalCustomerCharges
		, ISNULL(customerPayments.dblAmount, 0)							AS TotalCustomerPayments
		, (ISNULL(SUM (deptTotals.dblTotalSalesAmountComputed) OVER(), 0) + ISNULL(taxTotals.dblTotalTax,0) - ISNULL(paymentOp.dblAmount,0) - ISNULL(customerChange.dblAmount,0) + ISNULL(customerPayments.dblAmount,0)) AS TotalToDeposit
		, ISNULL(deposits.dblTotalDeposit, 0) AS TotalDeposits
		, (ISNULL(deposits.dblTotalDeposit, 0) - (ISNULL(SUM (deptTotals.dblTotalSalesAmountComputed) OVER(),0) + ISNULL(taxTotals.dblTotalTax,0) - ISNULL(paymentOp.dblAmount,0) - ISNULL(customerChange.dblAmount,0) + ISNULL(customerPayments.dblAmount,0))) AS CashOverShort
   FROM tblSTCheckoutDepartmetTotals deptTotals  
   LEFT OUTER JOIN tblICCategory cat 
		ON deptTotals.intCategoryId = cat.intCategoryId 
   LEFT OUTER JOIN (
					SELECT intCheckoutId, SUM(dblTotalTax) AS dblTotalTax 
					FROM tblSTCheckoutSalesTaxTotals 
					GROUP BY intCheckoutId
				   ) taxTotals ON deptTotals.intCheckoutId = taxTotals.intCheckoutId 
   LEFT OUTER JOIN (
					SELECT a.intCheckoutId, (SUM(a.dblAmount) + b.dblChangeFundIncreaseDecrease) AS dblAmount 
					FROM tblSTCheckoutPaymentOptions a
					INNER JOIN tblSTCheckoutHeader b
						ON a.intCheckoutId = b.intCheckoutId
					GROUP BY a.intCheckoutId,
							b.dblChangeFundIncreaseDecrease
				   ) paymentOp ON deptTotals.intCheckoutId = paymentOp.intCheckoutId 
   LEFT OUTER JOIN (
					SELECT intCheckoutId, SUM(dblAmount) AS dblAmount 
					FROM tblSTCheckoutCustomerCharges 
					GROUP BY intCheckoutId
				   ) customerChange ON deptTotals.intCheckoutId = customerChange.intCheckoutId 
   LEFT OUTER JOIN (
					SELECT intCheckoutId, SUM(dblPaymentAmount) AS dblAmount 
					FROM tblSTCheckoutCustomerPayments 
					GROUP BY intCheckoutId
				   ) customerPayments ON deptTotals.intCheckoutId = customerPayments.intCheckoutId 
   LEFT OUTER JOIN (
					SELECT intCheckoutId, SUM(dblTotalDeposit) AS dblTotalDeposit 
					FROM tblSTCheckoutDeposits 
					GROUP BY intCheckoutId
				   ) deposits ON deptTotals.intCheckoutId = deposits.intCheckoutId 
   WHERE deptTotals.intCheckoutId = @intCheckoutId 
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH