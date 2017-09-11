CREATE PROC uspRKReconciledValidation
	@intFutureMarketId int =null,
	@intBrokerageAccountId int = null,
	@intCommodityId int = null,
	@intEntityId int = null,
	@dtmFilledDate datetime= null,
	@ErrMsg nvarchar output
AS

BEGIN TRY
DECLARE @ErrMsg1 nvarchar(Max)  
  
IF EXISTS
(SELECT 1 FROM  tblRKReconciliationBrokerStatementHeader t
					WHERE t.intFutureMarketId=@intFutureMarketId
						AND t.intBrokerageAccountId=@intBrokerageAccountId
						AND t.intCommodityId=@intCommodityId
						AND t.intEntityId=@intEntityId AND ysnFreezed = 1
						AND CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmFilledDate,110),110) =
							CONVERT(DATETIME,CONVERT(VARCHAR(10),@dtmFilledDate,110),110) 	
)
BEGIN
RAISERROR('The selected filled date already reconciled.',16,1)
END
END TRY

BEGIN CATCH  
   
 SET @ErrMsg1 = ERROR_MESSAGE()  
 If @ErrMsg1 != ''   
 BEGIN  
  RAISERROR(@ErrMsg1, 16, 1, 'WITH NOWAIT')  
 END  
   
END CATCH 