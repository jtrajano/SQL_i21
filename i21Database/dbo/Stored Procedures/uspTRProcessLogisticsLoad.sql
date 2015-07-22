CREATE PROCEDURE [dbo].[uspTRProcessLogisticsLoad]
	 @intTransportLoadId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

BEGIN TRY

--Update the Logistics Load for InProgress 
	declare @intTicketId int,@intInboundLoadId int,@intOutboundLoadId int;
	       

	select @intTicketId = TL.intTransportLoadId ,@intInboundLoadId = LG.intLoadId,@intOutboundLoadId = LG.intOutboundLoadId from tblTRTransportLoad TL
	            join vyuTRDispatchedLoad LG on isNull(TL.intLoadId,0) = isNull(LG.intLoadId,0)
			    where TL.intTransportLoadId = @intTransportLoadId
    IF (isNull(@intInboundLoadId,0) != 0)
	BEGIN
        Exec dbo.uspLGUpdateLoadDetails @intInboundLoadId,1,@intTicketId,null,null
	END
	IF (isNull(@intOutboundLoadId,0) != 0 and isNull(@intInboundLoadId,0) != isNull(@intOutboundLoadId,0))
	BEGIN
	    Exec dbo.uspLGUpdateLoadDetails @intOutboundLoadId,1,@intTicketId,null,null
    END
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH