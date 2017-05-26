CREATE PROCEDURE [dbo].[uspRKAssignFuturesToContractSummarySave]      
  @strXml nVarchar(Max)    
AS      
    
BEGIN TRY      
      
SET QUOTED_IDENTIFIER OFF      
SET ANSI_NULLS ON      
SET NOCOUNT ON      
SET XACT_ABORT ON      
SET ANSI_WARNINGS OFF      
      
DECLARE @idoc int       
Declare @intAssignFuturesToContractHeaderId int           
DECLARE @ErrMsg nvarchar(max)       
    
EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml        
      
 BEGIN TRANSACTION      
     
 ------------------------- Delete Matched ---------------------    
DECLARE @tblMatchedDelete table            
  (       
  intAssignFuturesToContractSummaryId int,    
  ysnDeleted Bit     
  )      
    
INSERT INTO @tblMatchedDelete    
SELECT      
 intAssignFuturesToContractSummaryId,    
 ysnDeleted    
  FROM OPENXML(@idoc,'root/DeleteMatched', 2)          
 WITH        
 (      
 intAssignFuturesToContractSummaryId INT,    
 [ysnDeleted] Bit    
 )    
 if Exists(
 select * from tblCTPriceFixationDetail where intFutOptTransactionId in(
 SELECT intFutOptTransactionId FROM tblRKAssignFuturesToContractSummary where intAssignFuturesToContractSummaryId in(select intAssignFuturesToContractSummaryId from @tblMatchedDelete)
 ))
 begin
 raiserror('The transaction already assigned. Cannot delete the transaction.',16,1)
 END
 
	UPDATE tblRKFutOptTransaction set intContractDetailId = null WHERE intFutOptTransactionId in(SELECT intFutOptTransactionId FROM tblRKAssignFuturesToContractSummary    
	WHERE intAssignFuturesToContractSummaryId in(SELECT intAssignFuturesToContractSummaryId from @tblMatchedDelete) )
       
IF EXISTS(SELECT * FROM @tblMatchedDelete)    
BEGIN    
DELETE FROM tblRKAssignFuturesToContractSummary    
  WHERE intAssignFuturesToContractSummaryId in( SELECT intAssignFuturesToContractSummaryId from @tblMatchedDelete)    
END    
  ----------------------- END Delete Matched ---------------------    
          
 ---------------Header Record Insert ----------------    
 INSERT INTO tblRKAssignFuturesToContractSummaryHeader     
  (    
   intConcurrencyId    
  )    
 VALUES    
  (    
     1      
   )    
    
SELECT @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY();      
---------------Matched Record Insert ----------------    

print 1
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
	ysnIsHedged  
  )      
    
 SELECT      
	 @intAssignFuturesToContractHeaderId,    
	 1,  
	case when isnull(intContractHeaderId,0) = 0 then null else intContractHeaderId end intContractHeaderId,
	case when isnull(intContractDetailId,0) = 0 then null else intContractDetailId end intContractDetailId,
	dtmMatchDate,
	intFutOptTransactionId,
	dblAssignedLots,
	intHedgedLots,
	ysnIsHedged  
       
  FROM OPENXML(@idoc,'root/Transaction', 2)          
 WITH        
 (     
 	intContractHeaderId int,
	intContractDetailId int,
	dtmMatchDate datetime,
	intFutOptTransactionId int,
	dblAssignedLots numeric(16,10),
	intHedgedLots numeric(16,10),
	ysnIsHedged bit 
 )          
       
COMMIT TRAN      
      
EXEC sp_xml_removedocument @idoc       
      
END TRY        
        
BEGIN CATCH    
     
 SET @ErrMsg = ERROR_MESSAGE()    
 IF XACT_STATE() != 0 ROLLBACK TRANSACTION    
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc    
 If @ErrMsg != ''     
 BEGIN    
  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
 END    
     
END CATCH 
