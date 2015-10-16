CREATE PROCEDURE [dbo].[uspLGUpdateInboundIntransitQty]
	 @intShipmentId AS INT
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
     INSERT into @ItemsToIncreaseInTransitInBound(
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
	   SC.intItemId,
	   intItemLocationId = (SELECT Top(1) intItemLocationId from tblICItemLocation where intItemId=SC.intItemId),
       CT.intItemUOMId,
	   NULL,
	   SH.intSubLocationId,
	   NULL,
	   CASE WHEN @ysnUnShip = 0 THEN SC.dblQuantity ELSE -SC.dblQuantity END,
	   SH.intShipmentId,
	   CAST (SH.intTrackingNumber as VARCHAR(100)),
	   22
	   FROM tblLGShipmentContractQty SC
	   JOIN tblLGShipment SH ON SH.intShipmentId = SC.intShipmentId
	   JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = SC.intContractDetailId
       WHERE SH.intShipmentId = @intShipmentId;

    select @total = count(*) from @ItemsToIncreaseInTransitInBound;
    IF (@total = 0)
	BEGIN
		RAISERROR('Inventorize process failure #1', 11, 1);
		RETURN;
	END

	SELECT @ysnDirectShip = S.ysnDirectShipment from tblLGShipment S WHERE intShipmentId=@intShipmentId
	if (@ysnDirectShip <> 1)
	BEGIN
		EXEC dbo.uspICIncreaseInTransitInBoundQty @ItemsToIncreaseInTransitInBound;
	END

	IF (@ysnInventorize = 1)
	BEGIN
			UPDATE tblLGShipment SET ysnInventorized = 1, dtmInventorizedDate=GETDATE() WHERE intShipmentId=@intShipmentId
	END

	IF (@ysnInventorize = 0)
	BEGIN
			UPDATE tblLGShipment SET ysnInventorized = 0, dtmInventorizedDate=NULL WHERE intShipmentId=@intShipmentId
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