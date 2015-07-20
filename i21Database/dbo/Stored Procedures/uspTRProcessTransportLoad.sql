CREATE PROCEDURE [dbo].[uspTRProcessTransportLoad]
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

--Update the Transport Load as Posted
	UPDATE	TransportLoad
	      SET	TransportLoad.ysnPosted = 1
		  FROM	dbo.tblTRTransportLoad TransportLoad 
		  WHERE	TransportLoad.intTransportLoadId = @intTransportLoadId

--Update the Logistics Load 
	declare @intTicketId int,@intInboundLoadId int,@intOutboundLoadId int,
	        @dtmDeliveredDate DATETIME,@dblDeliveredQuantity DECIMAL(18, 6);

	select @intTicketId = TL.intTransportLoadId ,@intInboundLoadId = LG.intLoadId,@intOutboundLoadId = LG.intOutboundLoadId,@dtmDeliveredDate = TL.dtmLoadDateTime,
	       @dblDeliveredQuantity = (select top 1 dblGross from tblTRTransportReceipt TR where TR.intTransportLoadId = TL.intTransportLoadId) from tblTRTransportLoad TL
	            join vyuTRDispatchedLoad LG on isNull(TL.intLoadId,0) = isNull(LG.intLoadId,0)
			    where TL.intTransportLoadId = @intTransportLoadId
    IF (isNull(@intInboundLoadId,0) != 0)
	BEGIN
        Exec dbo.uspLGUpdateLoadDetails @intInboundLoadId,0,@intTicketId,@dtmDeliveredDate,@dblDeliveredQuantity
	END
	IF (isNull(@intOutboundLoadId,0) != 0 and isNull(@intInboundLoadId,0) != isNull(@intOutboundLoadId,0))
	BEGIN
	    Exec dbo.uspLGUpdateLoadDetails @intOutboundLoadId,0,@intTicketId,@dtmDeliveredDate,@dblDeliveredQuantity
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