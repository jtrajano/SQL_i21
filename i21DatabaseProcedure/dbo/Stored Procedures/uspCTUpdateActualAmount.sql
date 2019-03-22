CREATE PROCEDURE [dbo].[uspCTUpdateActualAmount]
	@ContractCostId AS Id  READONLY
AS
BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	UPDATE  CC
	SET     CC.dblActualAmount = ISNULL(tblBilled.dblTotal,0)
	FROM tblCTContractCost CC
	JOIN ( 
	   SELECT intContractCostId,SUM(dblTotal) dblTotal 
	   FROM tblAPBillDetail 
	   WHERE intContractCostId > 0 
	   GROUP BY intContractCostId
	) tblBilled ON tblBilled.intContractCostId = CC.intContractCostId
	JOIN @ContractCostId t ON t.intId = CC.intContractCostId
	WHERE  ISNULL(CC.dblActualAmount,0) <> ISNULL(tblBilled.dblTotal,0)
	

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH