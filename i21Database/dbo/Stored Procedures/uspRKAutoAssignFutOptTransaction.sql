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

			IF (SELECT ISNULL(SUM(ISNULL(intHedgedLots,0) + ISNULL(dblAssignedLots,0)),0) FROM  tblRKAssignFuturesToContractSummary 
												WHERE intFutOptTransactionId in(@intLFutOptTransactionId,@intSFutOptTransactionId))  < 
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
						1,
						CASE WHEN ysnMultiplePriceFixation=1 then ch.intContractHeaderId else null end,
						CASE WHEN isnull(ysnMultiplePriceFixation,0)=0 then cd.intContractDetailId else null end,
						GETDATE(),@intLFutOptTransactionId,dblMatchQty,0,0,null FROM tblRKMatchFuturesPSDetail ps
				JOIN tblRKAssignFuturesToContractSummary s on ps.intSFutOptTransactionId=intFutOptTransactionId
				LEFT join tblCTContractHeader ch on ch.intContractHeaderId = case when isnull(ysnMultiplePriceFixation,1)= 1 then s.intContractHeaderId else ch.intContractHeaderId end
				LEFT join tblCTContractDetail cd on cd.intContractDetailId = case when isnull(ysnMultiplePriceFixation,0)= 0 then s.intContractDetailId else cd.intContractDetailId end
				WHERE intMatchFuturesPSHeaderId= @intMatchFuturesPSHeaderId  and intLFutOptTransactionId=@intLFutOptTransactionId
					AND case when isnull(ysnMultiplePriceFixation,0)= 1 then ch.intContractHeaderId else cd.intContractDetailId end 
					NOT IN(SELECT 
						case when isnull(ysnMultiplePriceFixation,0)= 1 then intContractHeaderId else intContractDetailId end
						FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId=@intLFutOptTransactionId)
						AND case when isnull(ysnMultiplePriceFixation,0) = 1 then  ISNULL(ch.intContractHeaderId,0)  else ISNULL(cd.intContractDetailId,0) end <> 0
				END

				IF (SELECT ISNULL(SUM(ISNULL(intHedgedLots,0) + ISNULL(dblAssignedLots,0)),0) FROM  tblRKAssignFuturesToContractSummary 
															WHERE intFutOptTransactionId = @intSFutOptTransactionId)<
				(SELECT ISNULL(SUM(intNoOfContract),0) FROM  tblRKFutOptTransaction where intFutOptTransactionId in(@intSFutOptTransactionId))
				BEGIN			
						SELECT TOP 1 @intAssignFuturesToContractHeaderId,
						1,
						CASE WHEN ysnMultiplePriceFixation=1 then s.intContractHeaderId else null end,
						CASE WHEN isnull(ysnMultiplePriceFixation,0)=0 then s.intContractDetailId else null end,
						GETDATE(),@intSFutOptTransactionId,dblMatchQty,0,0,null FROM tblRKMatchFuturesPSDetail ps
						JOIN tblRKAssignFuturesToContractSummary s on ps.intLFutOptTransactionId=intFutOptTransactionId
						LEFT join tblCTContractHeader ch on ch.intContractHeaderId = case when isnull(ysnMultiplePriceFixation,1)= 1 then s.intContractHeaderId else ch.intContractHeaderId end
						LEFT join tblCTContractDetail cd on cd.intContractHeaderId = case when isnull(ysnMultiplePriceFixation,0)= 0 then s.intContractDetailId else cd.intContractDetailId end
						WHERE intMatchFuturesPSHeaderId= @intMatchFuturesPSHeaderId  and intSFutOptTransactionId=@intSFutOptTransactionId
						AND case when isnull(ysnMultiplePriceFixation,0)= 1 then ch.intContractHeaderId else cd.intContractDetailId end not in(SELECT 
												case when isnull(ysnMultiplePriceFixation,0)= 1 then intContractHeaderId else intContractDetailId end
											FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId=@intSFutOptTransactionId)	
						AND case when isnull(ysnMultiplePriceFixation,0) = 1 then  ISNULL(ch.intContractHeaderId,0)  else ISNULL(cd.intContractDetailId,0) end <> 0

				END
			END
		END

	SELECT @mRowNumber = MIN(RowNumber) FROM @tblExercisedAssignedDetail WHERE RowNumber>@mRowNumber   
	END
END