CREATE PROCEDURE [dbo].[uspTRProcessLogisticsLoad]
	 @strTransaction AS nvarchar(50),
	 @action as nvarchar(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE  @intTransportLoadId AS INT;
DECLARE @intContractDetailId as int,
        @dblQuantity as float;
BEGIN TRY
  select @intTransportLoadId = intTransportLoadId from tblTRTransportLoad where strTransaction = @strTransaction

--Update the Logistics Load for InProgress 
	declare @intTicketId int,@intInboundLoadId int,@intOutboundLoadId int;
	       

	select @intTicketId = TL.intTransportLoadId ,@intInboundLoadId = LG.intLoadId,@intOutboundLoadId = LG.intOutboundLoadId from tblTRTransportLoad TL
	            join vyuTRDispatchedLoad LG on isNull(TL.intLoadId,0) = isNull(LG.intLoadId,0)
			    where TL.intTransportLoadId = @intTransportLoadId
    IF (isNull(@intInboundLoadId,0) != 0)
	BEGIN
	   if (@action = 'Added')
	   BEGIN
        Exec dbo.uspLGUpdateLoadDetails @intInboundLoadId,1,@intTicketId,null,null
       END
		SELECT @intContractDetailId = intContractDetailId, @dblQuantity = dblQuantity from tblLGLoad WHERE intLoadId=@intInboundLoadId
		IF (isNull(@intContractDetailId,0) != 0)
		  Begin
		     if (@action = 'Added')
		     BEGIN
		       set @dblQuantity = @dblQuantity * -1
             END 
		     exec uspCTUpdateScheduleQuantity @intContractDetailId, @dblQuantity
		  END
	   if (@action = 'Delete')
	   BEGIN
	      UPDATE tblLGLoad SET 
			intTransportLoadId=null,
			ysnInProgress = 0,
			intConcurrencyId	=	intConcurrencyId + 1
		  WHERE intLoadId=@intInboundLoadId
	   END
	END
	IF (isNull(@intOutboundLoadId,0) != 0 and isNull(@intInboundLoadId,0) != isNull(@intOutboundLoadId,0))
	BEGIN
	    if (@action = 'Added')
		BEGIN
	         Exec dbo.uspLGUpdateLoadDetails @intOutboundLoadId,1,@intTicketId,null,null
		END
		SELECT @intContractDetailId = intContractDetailId, @dblQuantity = dblQuantity from tblLGLoad WHERE intLoadId=@intOutboundLoadId
		IF (isNull(@intContractDetailId,0) != 0)
		  Begin
		    if (@action = 'Added')
		    BEGIN
		        set @dblQuantity = @dblQuantity * -1
		    END
		    exec uspCTUpdateScheduleQuantity @intContractDetailId, @dblQuantity
		  END
	   if (@action = 'Delete')
	   BEGIN
	      UPDATE tblLGLoad SET 
			intTransportLoadId=null,
			ysnInProgress = 0,
			intConcurrencyId	=	intConcurrencyId + 1
		  WHERE intLoadId=@intOutboundLoadId
	   END
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