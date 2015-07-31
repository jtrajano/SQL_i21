CREATE PROCEDURE [dbo].[uspTRProcessLoadContracts]
	 @strTransaction AS nvarchar(50)
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
        @InboundQuantity as decimal(18,6),
        @OutboundQuantity as decimal(18,6);
BEGIN TRY
  select @intTransportLoadId = intTransportLoadId from tblTRTransportLoad where strTransaction = @strTransaction

--Update the Logistics Load for actual Qantity from transports
	declare @intTicketId int,@intInboundLoadId int,@intOutboundLoadId int;
	       

	select @intTicketId = TL.intTransportLoadId ,@intInboundLoadId = LG.intLoadId,@intOutboundLoadId = LG.intOutboundLoadId from tblTRTransportLoad TL
	            join vyuTRDispatchedLoad LG on isNull(TL.intLoadId,0) = isNull(LG.intLoadId,0)
			    where TL.intTransportLoadId = @intTransportLoadId
    IF (isNull(@intInboundLoadId,0) != 0)
	BEGIN
	  
		select top 1 @InboundQuantity =CASE 
		                          WHEN SP.strGrossOrNet = 'Gross'
								       THEN TR.dblGross
								  WHEN SP.strGrossOrNet = 'Net'
								       THEN TR.dblNet
								  END,
					@intContractDetailId = TR.intContractDetailId 
				 from tblTRTransportLoad TL
		              join tblTRTransportReceipt TR on TL.intTransportLoadId = TR.intTransportLoadId
					  join tblTRSupplyPoint SP on SP.intSupplyPointId = TR.intSupplyPointId
		              
		            
		IF (isNull(@intContractDetailId,0) != 0)
		  Begin	      
	       UPDATE tblLGLoad SET 
			dblQuantity = @InboundQuantity,
			intConcurrencyId	=	intConcurrencyId + 1
		  WHERE intLoadId=@intInboundLoadId
	   END
	END
	IF (isNull(@intOutboundLoadId,0) != 0 and isNull(@intInboundLoadId,0) != isNull(@intOutboundLoadId,0))
	BEGIN

	select top 1 @OutboundQuantity = DD.dblUnits, 
					@intContractDetailId = TR.intContractDetailId 
				 from tblTRTransportLoad TL
		              join tblTRTransportReceipt TR on TL.intTransportLoadId = TR.intTransportLoadId					
					  join tblTRDistributionHeader DH on DH.intTransportReceiptId = TR.intTransportReceiptId
					  join tblTRDistributionDetail DD on DD.intDistributionHeaderId = DH.intDistributionHeaderId
	  
	IF (isNull(@intContractDetailId,0) != 0)  
	   BEGIN
	      UPDATE tblLGLoad SET 
			dblQuantity = @OutboundQuantity,
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