CREATE PROCEDURE uspRKFutOptAssignedSave	
	@intContractDetailId int, 
	@dtmMatchDate datetime,
	@intFutOptTransactionId int,
	@intAssignedLots int
	
AS
  
BEGIN TRY

DECLARE @ErrMsg nvarchar(max)   
DECLARE @intAssignFuturesToContractHeaderId int    
declare @intContractHeaderId int

IF EXISTS (SELECT * FROM tblCTContractDetail where intContractDetailId=@intContractDetailId)
BEGIN
SELECT @intContractHeaderId=intContractHeaderId FROM tblCTContractDetail where intContractDetailId=@intContractDetailId
END

declare @BalanceLot int
SELECT @BalanceLot= isnull(dblAvailableLot,0)  FROM
(SELECT cd.intContractDetailId,
		isnull(SUM(cd.dblNoOfLots),0) as dblAvailableLot	 
FROM vyuCTContractDetailView cd
WHERE cd.intFutureMarketId IS NOT NULL AND cd.intFutureMonthId IS NOT NULL AND cd.intContractDetailId=@intContractDetailId and cd.intContractStatusId <> 3
GROUP BY strContractNumber,cd.intContractDetailId,intContractSeq,cd.intFutureMarketId,cd.intFutureMonthId,cd.strContractType)t  

BEGIN TRANSACTION     
-- Header Save
	INSERT INTO tblRKAssignFuturesToContractSummaryHeader (intConcurrencyId) VALUES (1)        
	SELECT @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY();   
--- Header Save End
--- Transaction save
IF EXISTS(SELECT * FROM tblRKAssignFuturesToContractSummary  where intFutOptAssignedId= @intFutOptTransactionId)
BEGIN
	DELETE FROM tblRKAssignFuturesToContractSummary WHERE intFutOptAssignedId= @intFutOptTransactionId
END

INSERT INTO tblRKAssignFuturesToContractSummary    
  (     
 	intAssignFuturesToContractHeaderId,
	intConcurrencyId,
	intContractHeaderId,
	intContractDetailId,
	dtmMatchDate,
	intFutOptTransactionId,
	dblAssignedLots,
	intHedgedLots,
	ysnIsHedged,  
	intFutOptAssignedId
  )      
    
 SELECT      
	 @intAssignFuturesToContractHeaderId,    
	 1,  
	@intContractHeaderId,
	@intContractDetailId,
	@dtmMatchDate,
	@intFutOptTransactionId,
	@intAssignedLots,
	0,
	0,
	@intFutOptTransactionId  
	
--- Transaction save End

	COMMIT TRAN    


END TRY                
BEGIN CATCH         
 SET @ErrMsg = ERROR_MESSAGE()    
 IF XACT_STATE() != 0 ROLLBACK TRANSACTION    
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
END CATCH 