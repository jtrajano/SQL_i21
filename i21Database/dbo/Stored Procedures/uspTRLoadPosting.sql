CREATE PROCEDURE [dbo].[uspTRLoadPosting]  
  @intLoadHeaderId AS INT  
 ,@intUserId AS INT   
 ,@ysnRecap AS BIT  
 ,@ysnPostOrUnPost AS BIT
 ,@ysnForcePost AS BIT = 0
 ,@BatchId NVARCHAR(20) = NULL  
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
DECLARE @ErrorMessage NVARCHAR(4000);  
DECLARE @ErrorSeverity INT;  
DECLARE @ErrorState INT;  
DECLARE @intEntityId int;  
BEGIN TRY  
  
 SELECT	@intEntityId = intEntityId --this is a hiccup
 FROM	tblSMUserSecurity 
 WHERE	intEntityId = @intUserId --this also
  
 BEGIN TRANSACTION  
  
 -- Call Starting number for Receipt Detail Update to prevent deadlocks.   
 BEGIN  
  DECLARE @strNewStartingNumber AS NVARCHAR(50)  
  EXEC dbo.uspSMGetStartingNumber 155, @strNewStartingNumber OUTPUT  
 END     
  
 IF @ysnPostOrUnPost = 0 AND @ysnRecap = 0  
 BEGIN  
  EXEC uspSMAuditLog   
    @keyValue = @intLoadHeaderId,                         -- Primary Key Value  
    @screenName = 'Transports.view.TransportLoads',       -- Screen Namespace  
    @entityId = @intEntityId,                             -- Entity Id.  
    @actionType = 'Processed',                            -- Action Type  
    @changeDescription = 'UnPosted',                      -- Description  
    @fromValue = '',                                      -- Previous Value  
    @toValue = ''                                         -- New Value  
  EXEC uspTRLoadProcessToInvoice @intLoadHeaderId,@intUserId,@ysnRecap,@ysnPostOrUnPost  
  EXEC uspTRLoadProcessToInventoryTransfer @intLoadHeaderId,@intUserId,@ysnRecap,@ysnPostOrUnPost  
  EXEC uspTRLoadProcessToInventoryReceipt @intLoadHeaderId,@intUserId,@ysnRecap,@ysnPostOrUnPost  
 END  
 ELSE  
 BEGIN  
  IF @ysnPostOrUnPost = 1  
  BEGIN  
   DECLARE @strChangeDesc NVARCHAR(100) = NULL  
   SET @strChangeDesc = CASE WHEN @BatchId IS NOT NULL THEN 'Posted - ' + @BatchId ELSE 'Posted' END  
   EXEC uspSMAuditLog   
    @keyValue = @intLoadHeaderId,                          -- Primary Key Value  
    @screenName = 'Transports.view.TransportLoads',        -- Screen Namespace  
    @entityId = @intEntityId,                              -- Entity Id.  
    @actionType = 'Processed',                             -- Action Type  
    @changeDescription = @strChangeDesc,                         -- Description  
    @fromValue = '',                                       -- Previous Value  
    @toValue = ''                                          -- New Value  
  END  
  EXEC uspTRLoadPostingValidation @intLoadHeaderId, @ysnPostOrUnPost, @intUserId, @ysnForcePost
  EXEC uspTRLoadProcessToInventoryReceipt @intLoadHeaderId, @intUserId, @ysnRecap, @ysnPostOrUnPost, @BatchId  
  EXEC uspTRLoadProcessToInventoryTransfer @intLoadHeaderId, @intUserId, @ysnRecap, @ysnPostOrUnPost, @BatchId  
  EXEC uspTRLoadProcessToInvoice @intLoadHeaderId, @intUserId, @ysnRecap, @ysnPostOrUnPost, @BatchId  
  EXEC uspTRUpdateCostOnTransportLoad @intLoadHeaderId  
 END  
  
 IF @ysnRecap = 0   
 BEGIN  
    EXEC uspTRLoadProcessTransportLoad @intLoadHeaderId,@ysnPostOrUnPost, @intUserId
 END  
  
 IF(@@TRANCOUNT > 0)  
 BEGIN  
  COMMIT TRANSACTION  
 END  
  
END TRY  
BEGIN CATCH  
 SELECT   
  @ErrorMessage = ERROR_MESSAGE(),  
  @ErrorSeverity = ERROR_SEVERITY(),  
  @ErrorState = ERROR_STATE();  
   
 IF(@@TRANCOUNT > 0)  
 BEGIN  
  ROLLBACK TRANSACTION  
 END  
 -- Use RAISERROR inside the CATCH block to return error  
 -- information about the original error that caused  
 -- execution to jump to the CATCH block.  
 RAISERROR (  
  @ErrorMessage, -- Message text.  
  @ErrorSeverity, -- Severity.  
  @ErrorState -- State.  
 );  
END CATCH