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
			AND intTransUsedBy = 2
	END
	IF EXISTS(SELECT 1 FROM tblTRLoadHeader WHERE intLoadHeaderId=@intTicketId)
	BEGIN
		UPDATE tblLGLoad SET 
			intLoadHeaderId=@intTicketId
		WHERE intLoadId=@intLoadId
			AND intTransUsedBy = 3
	END

	/*If Used By Transport Load*/
	IF EXISTS(SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND intTransUsedBy = 3)
	BEGIN
		UPDATE L
		SET intShipmentStatus = CASE WHEN (TL.ysnPosted = 1) THEN 
										CASE WHEN (L.intPurchaseSale = 1) THEN 4 ELSE 6 END
									ELSE 
										CASE WHEN (L.intLoadHeaderId IS NOT NULL) THEN 3
											 WHEN L.ysnDispatched = 1 THEN 2
											 ELSE 1 END
									END
			,ysnInProgress = CASE WHEN (L.intLoadHeaderId IS NOT NULL AND ISNULL(TL.ysnPosted, 0) = 0) THEN 1 ELSE 0 END
			,ysnPosted = ISNULL(TL.ysnPosted, 0)
		FROM tblLGLoad L
		LEFT JOIN tblTRLoadHeader TL ON TL.intLoadHeaderId = L.intLoadHeaderId
		WHERE L.intLoadId = @intLoadId AND intTransUsedBy = 3

		UPDATE LD
		SET dblDeliveredQuantity = TLDD.dblUnits
			,dblDeliveredGross = TLDD.dblDistributionGrossSalesUnits
			,dblDeliveredTare = TLDD.dblDistributionNetSalesUnits - TLDD.dblDistributionGrossSalesUnits
			,dblDeliveredNet = TLDD.dblDistributionNetSalesUnits
		FROM tblLGLoadDetail LD
		INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblTRLoadDistributionDetail TLDD ON TLDD.intLoadDetailId = LD.intLoadDetailId
		WHERE LD.intLoadId = @intLoadId AND L.intTransUsedBy = 3
	END
	ELSE
	BEGIN
		UPDATE tblLGLoad SET 
			ysnInProgress=@ysnInProgress,
			dtmDeliveredDate=@dtmDeliveredDate,
			intConcurrencyId	=	intConcurrencyId + 1
		WHERE intLoadId=@intLoadId

		IF (ISNULL(@dblDeliveredQuantity, 0) <> 0)
		BEGIN
			UPDATE tblLGLoadDetail SET 
				dblDeliveredQuantity=@dblDeliveredQuantity,
				intConcurrencyId	=	intConcurrencyId + 1
			WHERE intLoadDetailId=@intLoadDetailId
		END
	END

END TRY

BEGIN CATCH
SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH
