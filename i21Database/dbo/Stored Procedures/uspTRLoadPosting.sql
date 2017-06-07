CREATE PROCEDURE [dbo].[uspTRLoadPosting]
	 @intLoadHeaderId AS INT
	,@intUserId AS INT	
	,@ysnRecap AS BIT
	,@ysnPostOrUnPost AS BIT
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

if @ysnPostOrUnPost = 0 and @ysnRecap = 0
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
	    if @ysnPostOrUnPost = 1
		BEGIN
	         EXEC uspSMAuditLog 
                  @keyValue = @intLoadHeaderId,                          -- Primary Key Value
                  @screenName = 'Transports.view.TransportLoads',        -- Screen Namespace
                  @entityId = @intEntityId,                              -- Entity Id.
                  @actionType = 'Processed',                             -- Action Type
                  @changeDescription = 'Posted',                         -- Description
                  @fromValue = '',                                       -- Previous Value
                  @toValue = ''                                          -- New Value
         END
         EXEC uspTRLoadPostingValidation @intLoadHeaderId, @ysnPostOrUnPost, @intUserId
         EXEC uspTRLoadProcessToInventoryReceipt @intLoadHeaderId, @intUserId, @ysnRecap, @ysnPostOrUnPost, @BatchId
         EXEC uspTRLoadProcessToInventoryTransfer @intLoadHeaderId, @intUserId, @ysnRecap, @ysnPostOrUnPost, @BatchId
         EXEC uspTRLoadProcessToInvoice @intLoadHeaderId, @intUserId, @ysnRecap, @ysnPostOrUnPost, @BatchId
    END
if @ysnRecap = 0 
BEGIN
   EXEC uspTRLoadProcessTransportLoad @intLoadHeaderId,@ysnPostOrUnPost
END

END TRY
BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrorMessage = ERROR_MESSAGE()
	RAISERROR (	@ErrorMessage,16,1,'WITH NOWAIT')

END CATCH