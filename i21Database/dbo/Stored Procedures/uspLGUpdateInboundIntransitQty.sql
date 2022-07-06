CREATE PROCEDURE [dbo].[uspLGUpdateInboundIntransitQty]
	 @intLoadId AS INT
	,@ysnInventorize AS BIT
	,@ysnUnShip AS BIT	
	,@intEntityUserSecurityId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @ErrMsg NVARCHAR(MAX);
DECLARE @ysnDirectShip BIT;
DECLARE @ysnCancel BIT;
DECLARE @strAuditLogActionType NVARCHAR(MAX)

DECLARE @ItemsToIncreaseInTransitInBound AS InTransitTableType,
        @total as int;
BEGIN TRY

	SELECT @ysnDirectShip = CASE WHEN intSourceType = 3 THEN 1 ELSE 0 END 
		,@ysnCancel = ISNULL(ysnCancelled, 0)
	FROM tblLGLoad S WHERE intLoadId=@intLoadId

-- Insert Entries to Stagging table that needs to processed from Inbound Shipments
	INSERT INTO @ItemsToIncreaseInTransitInBound (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[dblQty]
		,[intTransactionId]
		,[strTransactionId]
		,[intTransactionTypeId]
		)
	 SELECT 
	   [intItemId] = LD.intItemId
	  ,[intItemLocationId] = IL.intItemLocationId
	  ,[intItemUOMId] = CT.intItemUOMId
	  ,[intLotId] = NULL
	  ,[intSubLocationId] = ISNULL(LW.intSubLocationId, LD.intPSubLocationId)
	  ,[intStorageLocationId] = NULL
	  ,[dblQty] = CASE WHEN (@ysnUnShip = 1 OR @ysnCancel = 1)
						THEN -LD.dblQuantity
						ELSE LD.dblQuantity
					   END
	  ,[intTransactionId] = LD.intLoadId
	  ,[strTransactionId] = CAST(L.strLoadNumber AS VARCHAR(100))
	  ,[intTransactionTypeId] = 22
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId= L.intLoadId
	LEFT JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN tblICItemLocation IL ON IL.intLocationId = CT.intCompanyLocationId 
	WHERE L.intLoadId = @intLoadId AND IL.intItemId = LD.intItemId;

    SELECT @total = COUNT(*) FROM @ItemsToIncreaseInTransitInBound;
    IF (@total = 0)
	BEGIN
		RAISERROR('Inventorize process failure #1', 11, 1);
		RETURN;
	END

	IF (@ysnDirectShip <> 1)
	BEGIN
		EXEC dbo.uspICIncreaseInTransitInBoundQty @ItemsToIncreaseInTransitInBound;
	END

	IF (@ysnInventorize = 1)
	BEGIN
		UPDATE tblLGLoad SET ysnPosted = 1, dtmPostedDate=GETDATE() WHERE intLoadId = @intLoadId AND @ysnCancel = 0
	END

	IF (@ysnInventorize = 0)
	BEGIN
		UPDATE tblLGLoad SET ysnPosted = 0, dtmPostedDate=NULL WHERE intLoadId = @intLoadId AND @ysnCancel = 0
	END

	IF (@ysnCancel = 0)
	BEGIN
		SELECT @strAuditLogActionType = CASE WHEN ISNULL(@ysnInventorize,0) = 1 THEN 'Posted'
											ELSE 'Unposted' END

		EXEC uspSMAuditLog	
				@keyValue	=	@intLoadId,
				@screenName =	'Logistics.view.ShipmentSchedule',
				@entityId	=	@intEntityUserSecurityId,
				@actionType =	@strAuditLogActionType,
				@actionIcon =	'small-tree-modified',
				@details	=	''
	END

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH