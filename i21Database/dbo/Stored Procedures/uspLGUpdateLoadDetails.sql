CREATE PROCEDURE [dbo].[uspLGUpdateLoadDetails]
	 @intLoadId INT
	,@ysnInProgress BIT = NULL
	,@intTicketId INT  = NULL
	,@dtmDeliveredDate DATETIME  = NULL
	,@dblDeliveredQuantity DECIMAL(18, 6)  = 0
AS
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @dblQuantity DECIMAL(18, 6) = 0
DECLARE @intContractDetailId INT

BEGIN TRY
	IF NOT EXISTS(SELECT 1 FROM tblSCTicket WHERE intTicketId=@intTicketId) AND @intTicketId IS NOT NULL
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM tblTRTransportLoad WHERE intTransportLoadId=@intTicketId) AND @intTicketId IS NOT NULL
		BEGIN
			RAISERROR('Invalid Ticket/TransportId', 16, 1)
		END
	END

	IF EXISTS(SELECT 1 FROM tblSCTicket WHERE intTicketId=@intTicketId)
	BEGIN
		UPDATE tblLGLoad SET 
			intTicketId=@intTicketId
		WHERE intLoadId=@intLoadId
	END
	IF EXISTS(SELECT 1 FROM tblTRTransportLoad WHERE intTransportLoadId=@intTicketId)
	BEGIN
		UPDATE tblLGLoad SET 
			intTransportLoadId=@intTicketId
		WHERE intLoadId=@intLoadId
	END

	UPDATE tblLGLoad SET 
		ysnInProgress=@ysnInProgress,
		dtmDeliveredDate=@dtmDeliveredDate,
		dblDeliveredQuantity=@dblDeliveredQuantity,
		intConcurrencyId	=	intConcurrencyId + 1
	WHERE intLoadId=@intLoadId
	
--	IF @dblDeliveredQuantity > 0
--	BEGIN
--		SET @dblQuantity = -1
--		SELECT @intContractDetailId = intContractDetailId, @dblQuantity = @dblQuantity * dblQuantity from tblLGLoad WHERE intLoadId=@intLoadId
--		exec uspCTUpdateScheduleQuantity @intContractDetailId, @dblQuantity
--	END
END TRY

BEGIN CATCH
SET @ErrMsg = ERROR_MESSAGE()
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
