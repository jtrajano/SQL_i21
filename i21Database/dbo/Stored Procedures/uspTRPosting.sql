CREATE PROCEDURE [dbo].[uspTRPosting]
	 @intTransportLoadId AS INT
	,@intUserId AS INT	
	,@ysnRecap AS BIT
	,@ysnPostOrUnPost AS BIT
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

SELECT	@intEntityId = intEntityId
FROM	dbo.tblSMUserSecurity 
WHERE	intUserSecurityID = @intUserId

if @ysnPostOrUnPost = 0 and @ysnRecap = 0
    BEGIN
	    EXEC uspSMAuditLog 
              @keyValue = @intTransportLoadId,                         -- Primary Key Value
              @screenName = 'Transports.view.TransportLoad',           -- Screen Namespace
              @entityId = @intEntityId,                                -- Entity Id.
              @actionType = 'Processed',                               -- Action Type
              @changeDescription = 'UnPosted',                        -- Description
              @fromValue = '',                                        -- Previous Value
              @toValue = ''                                           -- New Value
        EXEC uspTRProcessToInvoice @intTransportLoadId,@intUserId,@ysnRecap,@ysnPostOrUnPost
	    EXEC uspTRProcessToInventoryTransfer @intTransportLoadId,@intUserId,@ysnRecap,@ysnPostOrUnPost
	    EXEC uspTRProcessToInventoryReceipt @intTransportLoadId,@intUserId,@ysnRecap,@ysnPostOrUnPost
    END
ELSE
    BEGIN
	    if @ysnPostOrUnPost = 1
		BEGIN
	         EXEC uspSMAuditLog 
                  @keyValue = @intTransportLoadId,                          -- Primary Key Value
                  @screenName = 'Transports.view.TransportLoad',            -- Screen Namespace
                  @entityId = @intEntityId,                                   -- Entity Id.
                  @actionType = 'Processed',                                -- Action Type
                  @changeDescription = 'Posted',             -- Description
                  @fromValue = '',                                         -- Previous Value
                  @toValue = ''                                            -- New Value
         END
         EXEC uspTRPostingValidation @intTransportLoadId,@ysnPostOrUnPost
         EXEC uspTRProcessToInventoryReceipt @intTransportLoadId,@intUserId,@ysnRecap,@ysnPostOrUnPost
         EXEC uspTRProcessToInventoryTransfer @intTransportLoadId,@intUserId,@ysnRecap,@ysnPostOrUnPost
         EXEC uspTRProcessToInvoice @intTransportLoadId,@intUserId,@ysnRecap,@ysnPostOrUnPost
    END
if @ysnRecap = 0
BEGIN
   EXEC uspTRProcessTransportLoad @intTransportLoadId,@ysnPostOrUnPost
END

END TRY
BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrorMessage = ERROR_MESSAGE()
	RAISERROR (	@ErrorMessage,16,1,'WITH NOWAIT')

END CATCH