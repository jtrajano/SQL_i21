CREATE PROCEDURE [dbo].[uspCTUpdateActualAmount]
AS
BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	UPDATE  CC
	SET     CC.dblActualAmount = tblBilled.dblTotal
	FROM tblCTContractCost CC
	JOIN ( 
	   SELECT intContractCostId,SUM(dblTotal) dblTotal 
	   FROM tblAPBillDetail 
	   WHERE intContractCostId > 0 
	   GROUP BY intContractCostId
	) tblBilled ON tblBilled.intContractCostId = CC.intContractCostId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH