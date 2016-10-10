CREATE VIEW [dbo].[vyuETBEExportContract]  
AS 
	SELECT
		account= strEntityNo 
		,productCode= strItemNo
		,preBuyPrice= CAST(ISNULL(dblCashPrice,0.0) AS NUMERIC(18,4))
		,preBuyQty= CAST(ISNULL(dblBalance,0.0) AS NUMERIC(18,2))
		,contractPrice= CAST(0.0 AS NUMERIC(18,4))
		,contractQty= CAST(0.0 AS NUMERIC(18,2))
	FROM vyuETBEContract
GO