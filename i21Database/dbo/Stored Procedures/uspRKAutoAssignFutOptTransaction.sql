﻿CREATE PROC uspRKAutoAssignFutOptTransaction   
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
  
                     IF (SELECT ISNULL(SUM(ISNULL(dblHedgedLots,0) + ISNULL(dblAssignedLots,0)),0) FROM  tblRKAssignFuturesToContractSummary   
                                                                                  WHERE intFutOptTransactionId in(@intLFutOptTransactionId,@intSFutOptTransactionId))  <   
                     (SELECT ISNULL(SUM(dblNoOfContract),0) FROM  tblRKFutOptTransaction where intFutOptTransactionId in(@intLFutOptTransactionId,@intSFutOptTransactionId))  
                     BEGIN  
                           DECLARE @intAssignFuturesToContractHeaderId int=null  
						   declare @ysnMultiplePriceFixation bit = null
                           IF (SELECT ISNULL(SUM(dblHedgedLots),0) FROM  tblRKAssignFuturesToContractSummary where intFutOptTransactionId = @intLFutOptTransactionId AND ysnIsHedged = 1) <  
                           (SELECT ISNULL(SUM(dblNoOfContract),0) FROM  tblRKFutOptTransaction where intFutOptTransactionId in(@intLFutOptTransactionId))  
                           BEGIN                        
                
                                  INSERT INTO tblRKAssignFuturesToContractSummaryHeader (intConcurrencyId)
								  VALUES(1)
                                  SET @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY()  

										     SELECT TOP 1 @ysnMultiplePriceFixation= case when isnull(intContractHeaderId,0) =0 then 1 else 0 end FROM tblRKMatchFuturesPSDetail ps  
                           JOIN tblRKAssignFuturesToContractSummary s on ps.intSFutOptTransactionId=intFutOptTransactionId  
                           WHERE intMatchFuturesPSHeaderId= @intMatchFuturesPSHeaderId  and intLFutOptTransactionId=@intLFutOptTransactionId  

              
					   


						IF(@ysnMultiplePriceFixation=0)
						BEGIN
				-- 		   INSERT INTO tblRKAssignFuturesToContractSummary   
                        --    SELECT TOP 1 @intAssignFuturesToContractHeaderId,  
                        --                  1,  
                        --                  null,  
                        --                  cd.intContractDetailId,  
                        --                  GETDATE(),@intLFutOptTransactionId,dblMatchQty,0,0,null FROM tblRKMatchFuturesPSDetail ps  
                        --    JOIN tblRKAssignFuturesToContractSummary s on ps.intSFutOptTransactionId=intFutOptTransactionId                             
                        --    join tblCTContractDetail cd on cd.intContractDetailId = s.intContractDetailId 
                        --    WHERE intMatchFuturesPSHeaderId= @intMatchFuturesPSHeaderId  and intLFutOptTransactionId=@intLFutOptTransactionId  
                        --           AND cd.intContractDetailId    
                        --           NOT IN(SELECT   intContractDetailId   
                        --                  FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId=@intLFutOptTransactionId)  
                        --                  AND ISNULL(cd.intContractDetailId,0)  <> 0  
							INSERT INTO tblRKAssignFuturesToContractSummary   
							SELECT TOP 1 @intAssignFuturesToContractHeaderId,  
								1,  
								s.intContractHeaderId,
								NULL,   
								GETDATE(),@intLFutOptTransactionId,dblMatchQty,0,0,null FROM tblRKMatchFuturesPSDetail ps  
							JOIN tblRKAssignFuturesToContractSummary s on ps.intSFutOptTransactionId=intFutOptTransactionId   
							WHERE intMatchFuturesPSHeaderId= @intMatchFuturesPSHeaderId  and intLFutOptTransactionId=@intLFutOptTransactionId  
							AND s.intContractHeaderId    
							IN(SELECT   intContractHeaderId   
								FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId=@intSFutOptTransactionId)  
								AND ISNULL(s.intContractHeaderId,0)  <> 0
                             
							END
							ELSE
							BEGIN
				-- 			       INSERT INTO tblRKAssignFuturesToContractSummary   
				-- 			 SELECT TOP 1 @intAssignFuturesToContractHeaderId,  
                        --                  1,  
                        --                  s.intContractHeaderId,  
                        --                 null,  
                        --                  GETDATE(),@intLFutOptTransactionId,dblMatchQty,0,0,null FROM tblRKMatchFuturesPSDetail ps  
                        --    JOIN tblRKAssignFuturesToContractSummary s on ps.intSFutOptTransactionId=intFutOptTransactionId   
                        --    WHERE intMatchFuturesPSHeaderId= @intMatchFuturesPSHeaderId  and intLFutOptTransactionId=@intLFutOptTransactionId  
                        --           AND s.intContractHeaderId    
                        --           NOT IN(SELECT   intContractHeaderId   
                        --                  FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId=@intLFutOptTransactionId)  
                        --                  AND ISNULL(s.intContractHeaderId,0)  <> 0  
                                          INSERT INTO tblRKAssignFuturesToContractSummary   
							SELECT TOP 1 @intAssignFuturesToContractHeaderId,  
								1,  
								NULL,
								s.intContractDetailId,   
								GETDATE(),@intLFutOptTransactionId,dblMatchQty,0,0,null FROM tblRKMatchFuturesPSDetail ps  
							JOIN tblRKAssignFuturesToContractSummary s on ps.intSFutOptTransactionId=intFutOptTransactionId   
							WHERE intMatchFuturesPSHeaderId= @intMatchFuturesPSHeaderId  and intLFutOptTransactionId=@intLFutOptTransactionId  
							AND s.intContractDetailId    
							IN(SELECT   intContractDetailId   
								FROM tblRKAssignFuturesToContractSummary WHERE intFutOptTransactionId=@intSFutOptTransactionId)  
								AND ISNULL(s.intContractDetailId,0)  <> 0
							END
					END


                           IF (SELECT ISNULL(SUM(ISNULL(dblHedgedLots,0) + ISNULL(dblAssignedLots,0)),0) FROM  tblRKAssignFuturesToContractSummary   
                                                                                                       WHERE intFutOptTransactionId = @intSFutOptTransactionId)<  
                           (SELECT ISNULL(SUM(dblNoOfContract),0) FROM  tblRKFutOptTransaction where intFutOptTransactionId in(@intSFutOptTransactionId))  
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