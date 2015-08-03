﻿CREATE PROCEDURE [dbo].[uspRKAssignFuturesToContractSummarySave]      
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

Declare @intContractHeaderId int     
Declare @intContractDetailId  int      
Declare @dtmMatchDate datetime      
Declare @intFutOptTransactionId int      
Declare @dblAssignedLots int     
Declare @dblHedgedLots int
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
    
IF EXISTS(select * from @tblMatchedDelete)    
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
   INSERT INTO tblRKAssignFuturesToContractSummary    
  (     
 	intAssignFuturesToContractHeaderId,
	intConcurrencyId,
	intContractHeaderId,
	intContractDetailId,
	dtmMatchDate,
	intFutOptTransactionId,
	intAssignedLots,
	intHedgedLots,
	ysnIsHedged  
  )      
    
 SELECT      
	 @intAssignFuturesToContractHeaderId,    
	 1,  
	intContractHeaderId,
	intContractDetailId,
	dtmMatchDate,
	intFutOptTransactionId,
	intAssignedLots,
	intHedgedLots,
	ysnIsHedged  
       
  FROM OPENXML(@idoc,'root/Transaction', 2)          
 WITH        
 (     
 	intContractHeaderId int,
	intContractDetailId int,
	dtmMatchDate datetime,
	intFutOptTransactionId int,
	intAssignedLots int,
	intHedgedLots int,
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