CREATE PROCEDURE [dbo].[uspLGUpdateInboundIntransitQty]
	 @intLoadId AS INT
	,@ysnInventorize AS BIT
	,@ysnUnShip AS BIT	

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

DECLARE @ItemsToIncreaseInTransitInBound AS InTransitTableType,
        @total as int;
BEGIN TRY

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
		 LD.intItemId
		,intItemLocationId = IL.intItemLocationId
		,CT.intItemUOMId
		,NULL
		,LW.intSubLocationId
		,NULL
		,CASE 
		 WHEN @ysnUnShip = 0
			THEN LD.dblQuantity
		 ELSE - LD.dblQuantity
		 END
		,LD.intLoadId
		,CAST(L.strLoadNumber AS VARCHAR(100))
		,22
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
	LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
	LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN tblICItemLocation IL ON IL.intLocationId = CT.intCompanyLocationId 
	WHERE L.intLoadId = @intLoadId AND IL.intItemId = LD.intItemId;

    SELECT @total = COUNT(*) FROM @ItemsToIncreaseInTransitInBound;
    IF (@total = 0)
	BEGIN
		RAISERROR('Inventorize process failure #1', 11, 1);
		RETURN;
	END

	SELECT @ysnDirectShip = CASE WHEN intSourceType = 3 THEN 1 ELSE 0 END FROM tblLGLoad S WHERE intLoadId=@intLoadId

	IF (@ysnDirectShip <> 1)
	BEGIN
		EXEC dbo.uspICIncreaseInTransitInBoundQty @ItemsToIncreaseInTransitInBound;
	END

	IF (@ysnInventorize = 1)
	BEGIN
			UPDATE tblLGLoad SET ysnPosted = 1, dtmPostedDate=GETDATE() WHERE intLoadId = @intLoadId
	END

	IF (@ysnInventorize = 0)
	BEGIN
			UPDATE tblLGLoad SET ysnPosted = 0, dtmPostedDate=NULL WHERE intLoadId = @intLoadId
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