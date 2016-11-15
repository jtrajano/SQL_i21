CREATE VIEW [dbo].[vyuETBEExportContract]  
AS 
	SELECT
		account= strEntityNo 
		,productCode= strItemNo
		,preBuyPrice= CAST(ISNULL(dblCashPrice,0.0) AS NUMERIC(18,4))
		,preBuyQty= CAST(ROUND(ISNULL(dblBalance,0.0),0) AS INT)
		,contractPrice= CAST(0.0 AS NUMERIC(18,4))
		,contractQty= CAST(0 AS INT)
	FROM vyuETBEContract
GO