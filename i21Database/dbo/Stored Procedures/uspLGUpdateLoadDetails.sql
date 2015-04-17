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
		RAISERROR('Invalid TicketId', 16, 1)
	END

	UPDATE tblLGLoad SET 
		ysnInProgress=@ysnInProgress,
		intTicketId=@intTicketId,
		dtmDeliveredDate=@dtmDeliveredDate,
		dblDeliveredQuantity=@dblDeliveredQuantity,
		intConcurrencyId	=	intConcurrencyId + 1
	WHERE intLoadId=@intLoadId
	
	IF @dblDeliveredQuantity > 0
	BEGIN
		SET @dblQuantity = -1
		SELECT @intContractDetailId = intContractDetailId, @dblQuantity = @dblQuantity * dblQuantity from tblLGLoad WHERE intLoadId=@intLoadId
		exec uspCTUpdateScheduleQuantity @intContractDetailId, @dblQuantity
	END
END TRY

BEGIN CATCH
SET @ErrMsg = ERROR_MESSAGE()
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
