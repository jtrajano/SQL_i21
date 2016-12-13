CREATE PROC uspRKAutoAssignFutOptTransaction 
	@intMatchFuturesPSHeaderId int 

AS

DECLARE @strBuySell nvarchar(90)
DECLARE @ysnIsAutoAssign bit

SELECT top 1 @ysnIsAutoAssign=ysnIsAutoAssign FROM tblRKCompanyPreference 

if isnull(@ysnIsAutoAssign,0) = 1
BEGIN
	DECLARE @tblExercisedAssignedDetail table          
	  (     
	  RowNumber int IDENTITY(1,1),   
	  intLFutOptTransactionId int,  
	  intSFutOptTransactionId int
	  )    

	INSERT INTO @tblExercisedAssignedDetail
	SELECT intLFutOptTransactionId,intSFutOptTransactionId FROM tblRKMatchFuturesPSDetail WHERE intMatchFuturesPSHeaderId= @intMatchFuturesPSHeaderId

	DECLARE @mRowNumber int
	SELECT @mRowNumber=MIN(RowNumber) FROM @tblExercisedAssignedDetail    
	WHILE @mRowNumber IS NOT NULL  
	BEGIN  

		DECLARE @intLFutOptTransactionId int = NULL  
		DECLARE @intSFutOptTransactionId int = NULL

		SELECT @intLFutOptTransactionId=intLFutOptTransactionId,@intSFutOptTransactionId=intSFutOptTransactionId 
		FROM @tblExercisedAssignedDetail WHERE RowNumber=@mRowNumber


		IF EXISTS(SELECT * FROM  tblRKAssignFuturesToContractSummary where intFutOptTransactionId in(@intLFutOptTransactionId,@intSFutOptTransactionId) AND ysnIsHedged = 1 )
		BEGIN

			IF (SELECT ISNULL(SUM(ISNULL(intHedgedLots,0) + ISNULL(dblAssignedLots,0)),0) FROM  tblRKAssignFuturesToContractSummary where intFutOptTransactionId in(@intLFutOptTransactionId,@intSFutOptTransactionId))  < 
			 (SELECT ISNULL(SUM(intNoOfContract),0) FROM  tblRKFutOptTransaction where intFutOptTransactionId in(@intLFutOptTransactionId,@intSFutOptTransactionId))
			BEGIN
		
				DECLARE @intAssignFuturesToContractHeaderId int=null
				IF (SELECT ISNULL(SUM(intHedgedLots),0) FROM  tblRKAssignFuturesToContractSummary where intFutOptTransactionId = @intLFutOptTransactionId AND ysnIsHedged = 1) <
				(SELECT ISNULL(SUM(intNoOfContract),0) FROM  tblRKFutOptTransaction where intFutOptTransactionId in(@intLFutOptTransactionId))
				BEGIN							
					INSERT INTO tblRKAssignFuturesToContractSummaryHeader
					SELECT 1 
					SET @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY()
				
					INSERT INTO tblRKAssignFuturesToContractSummary 
					SELECT TOP 1 @intAssignFuturesToContractHeaderId,
							1,intContractHeaderId,intContractDetailId,getdate(),@intLFutOptTransactionId,dblMatchQty,0,0,null
					 from vyuCTAssociatedFutOptTransaction where intLongFutOptTransactionId=@intLFutOptTransactionId AND strDirectAssociation = 'Short'
					 AND intContractDetailId NOT IN (SELECT intContractDetailId FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId=@intLFutOptTransactionId)
					 ORDER BY intShortFutOptTransactionId dESC
				END
		
				IF (SELECT ISNULL(SUM(ISNULL(intHedgedLots,0) + ISNULL(dblAssignedLots,0)),0) FROM  tblRKAssignFuturesToContractSummary where intFutOptTransactionId = @intSFutOptTransactionId)<
				(SELECT ISNULL(SUM(intNoOfContract),0) FROM  tblRKFutOptTransaction where intFutOptTransactionId in(@intSFutOptTransactionId))
				BEGIN				
					INSERT INTO tblRKAssignFuturesToContractSummaryHeader
					SELECT 1
					SET @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY()
								
					INSERT INTO tblRKAssignFuturesToContractSummary 
					SELECT TOP 1  @intAssignFuturesToContractHeaderId,
							1,intContractHeaderId,intContractDetailId,getdate(),@intSFutOptTransactionId,dblMatchQty,0,0,null
					 from vyuCTAssociatedFutOptTransaction where intShortFutOptTransactionId=@intSFutOptTransactionId AND strDirectAssociation = 'Long'
					 AND intContractDetailId NOT IN (SELECT intContractDetailId FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId=@intSFutOptTransactionId)
					 ORDER BY intLongFutOptTransactionId dESC	 			
				END
			END
		END

	SELECT @mRowNumber = MIN(RowNumber) FROM @tblExercisedAssignedDetail WHERE RowNumber>@mRowNumber   
	END
END