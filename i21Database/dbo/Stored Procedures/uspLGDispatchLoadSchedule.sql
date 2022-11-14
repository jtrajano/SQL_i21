CREATE PROCEDURE [dbo].[uspLGDispatchLoadSchedule]
	 @intLoadId INT
	,@ysnDispatch BIT = 1
	,@intEntityUserSecurityId INT = NULL
AS
BEGIN TRY
	DECLARE @intTransactionId INT
			,@intShipmentType INT
			,@intTransactionType INT
			,@ysnDispatched BIT
			,@intTransUsedBy INT
			,@ysnCancelled BIT
			,@ErrMsg NVARCHAR(MAX)

	SELECT @intTransactionId = intLoadId
		,@intShipmentType = intShipmentType
		,@intTransactionType = intPurchaseSale
		,@ysnDispatched = ISNULL(ysnDispatched, 0)
		,@intTransUsedBy = intTransUsedBy
		,@ysnCancelled = ISNULL(ysnCancelled, 0)
	FROM tblLGLoad 
	WHERE intLoadId = @intLoadId 

	/* Validations */
	IF (@intShipmentType = 2)
	BEGIN
		RAISERROR('Cannot dispatch Shipping Instruction.', 16, 1)
	END

	IF (@ysnCancelled = 1)
	BEGIN
		RAISERROR('Cannot dispatch cancelled transaction.', 16, 1)
	END

	IF (@intTransUsedBy = 1)
	BEGIN
		RAISERROR('Only Transactions Used By ''Scale Ticket'' or ''Transport Load'' can be Dispatched.', 16, 1)
	END

	IF (@ysnDispatch = 1 AND @ysnDispatched = 1)
	BEGIN
		RETURN;
	END

	IF (@ysnDispatch = 0 AND @ysnDispatched = 0)
	BEGIN
		RETURN;
	END

	/* Validate Details */
	IF (@intTransactionType <> 2)
	BEGIN
		SELECT TOP 1 @ErrMsg = 'Location ''' + CL.strLocationName + ''' is invalid or missing for Item ''' + I.strDescription + ''''
		FROM tblLGLoadDetail LD
			INNER JOIN tblICItem I ON I.intItemId = LD.intItemId
			LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
		WHERE intLoadId = @intTransactionId
			AND NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblICItemLocation WHERE intItemId = LD.intItemId AND intLocationId = LD.intPCompanyLocationId)
	END
	IF (@intTransactionType <> 1)
	BEGIN
		SELECT TOP 1 @ErrMsg = 'Location ''' + CL.strLocationName + ''' is invalid or missing for Item ''' + I.strDescription + ''''
		FROM tblLGLoadDetail LD
			INNER JOIN tblICItem I ON I.intItemId = LD.intItemId
			LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intSCompanyLocationId
		WHERE intLoadId = @intTransactionId
			AND NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblICItemLocation WHERE intItemId = LD.intItemId AND intLocationId = LD.intSCompanyLocationId)
	END

	IF (@ErrMsg IS NOT NULL)
	BEGIN
		RAISERROR(@ErrMsg, 16, 1)
	END

	IF (@ysnDispatch = 1)
	BEGIN
	/* Dispatch/Cancel Dispatch */
		UPDATE tblLGLoad 
		SET ysnDispatched = 1
			,intShipmentStatus = 2
			,dtmDispatchedDate = GETDATE()
			,intDispatcherId = @intEntityUserSecurityId
		 WHERE intLoadId = @intTransactionId
		 AND intShipmentType = 1 AND intTransUsedBy <> 1
	END
	ELSE
	BEGIN
	/* Cancel Dispatch */
		UPDATE tblLGLoad 
		SET ysnDispatched = 0
			,intShipmentStatus = CASE WHEN (intShipmentStatus = 2) THEN 1 ELSE intShipmentStatus END
			,dtmDispatchedDate = NULL
			,intDispatcherId = NULL
		 WHERE intLoadId = @intTransactionId
		 AND intShipmentType = 1 AND intTransUsedBy <> 1
	END

	/* Update Related Orders */
	EXEC uspLGLoadUpdateOrders @intTransactionId, @intEntityUserSecurityId

	DECLARE @strAuditLogActionType NVARCHAR(200)
	SELECT @strAuditLogActionType = CASE WHEN ISNULL(@ysnDispatch,0) = 1 THEN 'Dispatched' ELSE 'Cancelled Dispatch' END
	EXEC uspSMAuditLog	
			@keyValue	=	@intTransactionId,
			@screenName =	'Logistics.view.ShipmentSchedule',
			@entityId	=	@intEntityUserSecurityId,
			@actionType =	@strAuditLogActionType,
			@actionIcon =	'small-tree-modified',
			@details	=	''

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH

GO
