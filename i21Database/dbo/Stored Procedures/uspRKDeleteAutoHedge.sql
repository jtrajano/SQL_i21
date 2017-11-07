CREATE PROCEDURE uspRKDeleteAutoHedge 
      @intFutOptTransactionId int
AS
DECLARE @TransId int = 0
DECLARE @ErrMsg nvarchar(max)
BEGIN TRY
IF EXISTS(SELECT * FROM tblRKMatchFuturesPSDetail WHERE intLFutOptTransactionId=@intFutOptTransactionId)
BEGIN
SET @TransId = 1
END

IF EXISTS(SELECT * FROM tblRKMatchFuturesPSDetail WHERE intSFutOptTransactionId=@intFutOptTransactionId)
BEGIN
      SET @TransId = 1
END

--IF (@TransId = 1)
--BEGIN
--      RAISERROR('The selected transaction is used for match PnS. Cannot delete this transaction.',16,1)
--END

IF EXISTS
(SELECT 1 FROM  tblRKFutOptTransaction t WHERE intFutOptTransactionId=@intFutOptTransactionId  AND ISNULL(ysnFreezed,0) = 1)
BEGIN
RAISERROR('The selected transaction is already reconciled. Cannot delete this transaction.',16,1)
END
	  DELETE FROM tblRKMatchFuturesPSDetail WHERE @intFutOptTransactionId IN (intLFutOptTransactionId,intSFutOptTransactionId)
      DELETE FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId=@intFutOptTransactionId 
      DELETE FROM tblRKFutOptTransaction WHERE intFutOptTransactionId=@intFutOptTransactionId 


END TRY
BEGIN CATCH
      SET @ErrMsg = ERROR_MESSAGE()    
       IF XACT_STATE() != 0 ROLLBACK TRANSACTION    
       IF @ErrMsg != ''     
       BEGIN    
            RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
       END    
END CATCH