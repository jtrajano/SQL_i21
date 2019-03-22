CREATE VIEW [dbo].[vyuAPRptVoucherCheckOffCommodity]

AS
SELECT	DISTINCT	 
			 SUM(A.dblTotal) + SUM(A.dblTax) AS dblCommodityTotal
			,A.strDescription
	FROM	vyuAPRptVoucherCheckOff A  
	GROUP BY A.strDescription
GO
