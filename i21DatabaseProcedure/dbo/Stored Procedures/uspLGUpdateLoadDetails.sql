CREATE PROCEDURE [dbo].[uspLGUpdateLoadDetails]
	 @intLoadDetailId INT
	,@ysnInProgress BIT = NULL
	,@intTicketId INT  = NULL
	,@dtmDeliveredDate DATETIME  = NULL
	,@dblDeliveredQuantity DECIMAL(18, 6)  = 0
AS
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @dblQuantity DECIMAL(18, 6) = 0
DECLARE @intContractDetailId INT
DECLARE @intLoadId INT

BEGIN TRY

	SELECT @intLoadId = intLoadId FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoadDetailId

	IF NOT EXISTS(SELECT 1 FROM tblSCTicket WHERE intTicketId=@intTicketId) AND @intTicketId IS NOT NULL
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM tblTRLoadHeader WHERE intLoadHeaderId=@intTicketId) AND @intTicketId IS NOT NULL
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
	IF EXISTS(SELECT 1 FROM tblTRLoadHeader WHERE intLoadHeaderId=@intTicketId)
	BEGIN
		UPDATE tblLGLoad SET 
			intLoadHeaderId=@intTicketId
		WHERE intLoadId=@intLoadId
	END

	UPDATE tblLGLoad SET 
		ysnInProgress=@ysnInProgress,
		dtmDeliveredDate=@dtmDeliveredDate,
		intConcurrencyId	=	intConcurrencyId + 1
	WHERE intLoadId=@intLoadId

	UPDATE tblLGLoadDetail SET 
		dblDeliveredQuantity=@dblDeliveredQuantity,
		intConcurrencyId	=	intConcurrencyId + 1
	WHERE intLoadDetailId=@intLoadDetailId
END TRY

BEGIN CATCH
SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
