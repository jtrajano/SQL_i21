CREATE PROCEDURE [dbo].[uspSCManualDistributionOutbound]
	@LineItem ScaleManualCostingTableType READONLY,
	@intTicketId AS INT, 
	@intUserId AS INT,
	@intEntityId AS INT,
	@InventoryShipmentId AS INT OUTPUT 
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @ItemsForItemShipment AS ItemCostingTableType
DECLARE @total AS INT
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @strDistributionOption NVARCHAR(50) = NULL

DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @strReceiptType AS NVARCHAR(100)
DECLARE @intOrderId AS INT
DECLARE @intLoadId AS INT
DECLARE @intScaleStationId AS INT
DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnIsStorage AS BIT
DECLARE @intLoadContractId AS INT
DECLARE @dblLoadScheduledUnits AS NUMERIC(38,20)
DECLARE @strInOutFlag AS NVARCHAR(100)
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @intItemId AS INT
DECLARE @intStorageScheduleId AS INT
		,@intStorageScheduleTypeId INT
		,@intInventoryShipmentItemId AS INT
		,@intInvoiceId AS INT
		,@intOwnershipType AS INT
		,@intPricingTypeId AS INT
		,@intShipmentOrderId AS INT
		,@successfulCount AS INT
		,@invalidCount AS INT
		,@success AS INT
		,@batchIdUsed AS INT
		,@recapId AS INT
		,@strWhereFinalizedWeight NVARCHAR(20)
		,@strWhereFinalizedGrade NVARCHAR(20);

SELECT @intTicketItemUOMId = intItemUOMIdTo
	, @intLoadId = intLoadId
	, @intItemId = intItemId 
	, @strWhereFinalizedWeight = strWeightFinalized
	, @strWhereFinalizedGrade = strGradeFinalized
	, @strInOutFlag = strInOutFlag
	, @intLoadId = intLoadId
FROM vyuSCTicketScreenView where intTicketId = @intTicketId

BEGIN TRY
DECLARE @intId INT;
DECLARE @ysnDPStorage AS BIT;
DECLARE @intLoopContractId INT;
DECLARE @dblLoopContractUnits NUMERIC(38,20);
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT intTransactionDetailId, dblQty, ysnIsStorage, intId, strDistributionOption , intStorageScheduleId, intStorageScheduleTypeId
FROM @LineItem;

OPEN intListCursor;

		-- Initial fetch attempt
		FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId, @intStorageScheduleTypeId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF ISNULL(@intStorageScheduleTypeId,0) > 0
				SELECT	@ysnDPStorage = ST.ysnDPOwnedType FROM dbo.tblGRStorageType ST WHERE ST.intStorageScheduleTypeId = @intStorageScheduleTypeId

			IF @ysnIsStorage = 0
				BEGIN
					IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
					BEGIN
						IF @strDistributionOption = 'LOD'
						BEGIN 
							IF @strInOutFlag = 'I'
								SELECT @intLoadContractId = LGL.intPContractDetailId, @dblLoadScheduledUnits = LGL.dblQuantity FROM vyuLGLoadDetailView LGL WHERE LGL.intLoadId = @intLoadId
							ELSE
								SELECT @intLoadContractId = LGL.intSContractDetailId, @dblLoadScheduledUnits = LGL.dblQuantity FROM vyuLGLoadDetailView LGL WHERE LGL.intLoadId = @intLoadId
							
							IF @intLoadContractId IS NOT NULL
							BEGIN
								SET @dblLoadScheduledUnits = @dblLoadScheduledUnits * -1;
								EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoadContractId, @dblLoadScheduledUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
							END
							BEGIN
								INSERT INTO [dbo].[tblSCTicketCost]
								(
									[intTicketId]
									,[intConcurrencyId]
									,[intItemId]
									,[intEntityVendorId]
									,[strCostMethod]
									,[dblRate]
									,[intItemUOMId]
									,[ysnAccrue]
									,[ysnMTM]
									,[ysnPrice]
								)
								SELECT	
									@intTicketId,
									1, 
									LD.intItemId,
									LD.intVendorId,
									LD.strCostMethod,
									LD.dblRate,
									LD.intItemUOMId,
									LD.ysnAccrue,
									LD.ysnMTM,
									LD.ysnPrice
								FROM tblLGLoadCost LD WHERE LD.intLoadId = @intLoadId
							END
						END
						ELSE IF @strDistributionOption = 'CNT'
						BEGIN
							INSERT INTO [dbo].[tblSCTicketCost]
							(
								[intTicketId]
								,[intConcurrencyId]
								,[intItemId]
								,[intEntityVendorId]
								,[strCostMethod]
								,[dblRate]
								,[intItemUOMId]
								,[ysnAccrue]
								,[ysnMTM]
								,[ysnPrice]
							)
							SELECT	
								@intTicketId,
								1, 
								CC.intItemId,
								CC.intVendorId,
								CC.strCostMethod,
								CC.dblRate,
								CC.intItemUOMId,
								CC.ysnAccrue,
								CC.ysnMTM,
								CC.ysnPrice
							FROM tblCTContractCost CC WHERE CC.intContractDetailId = @intLoopContractId AND CC.ysnBasis = 0
						END
						
						IF	ISNULL(@intLoopContractId,0) != 0
						BEGIN
							EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
							EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;
						END
						INSERT INTO @ItemsForItemShipment (
								intItemId
								,intItemLocationId
								,intItemUOMId
								,dtmDate
								,dblQty
								,dblUOMQty
								,dblCost
								,dblSalesPrice
								,intCurrencyId
								,dblExchangeRate
								,intTransactionId
								,intTransactionDetailId
								,strTransactionId
								,intTransactionTypeId
								,intLotId
								,intSubLocationId
								,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
								,ysnIsStorage
								,strSourceTransactionId  
							)SELECT 
								intItemId
								,intItemLocationId
								,intItemUOMId
								,dtmDate
								,dblQty
								,dblUOMQty
								,dblCost
								,dblSalesPrice
								,intCurrencyId
								,dblExchangeRate
								,intTransactionId
								,intTransactionDetailId
								,strTransactionId
								,intTransactionTypeId
								,intLotId
								,intSubLocationId
								,intStorageLocationId
								,ysnIsStorage
								,strDistributionOption 
							FROM @LineItem
							where intId = @intId
					END
					ELSE
						BEGIN
						INSERT INTO @ItemsForItemShipment (
								intItemId
								,intItemLocationId
								,intItemUOMId
								,dtmDate
								,dblQty
								,dblUOMQty
								,dblCost
								,dblSalesPrice
								,intCurrencyId
								,dblExchangeRate
								,intTransactionId
								,intTransactionDetailId
								,strTransactionId
								,intTransactionTypeId
								,intLotId
								,intSubLocationId
								,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
								,ysnIsStorage
								,strSourceTransactionId  
							)SELECT 
								intItemId
								,intItemLocationId
								,intItemUOMId
								,dtmDate
								,dblQty
								,dblUOMQty
								,dblCost
								,dblSalesPrice
								,intCurrencyId
								,dblExchangeRate
								,intTransactionId
								,intTransactionDetailId
								,strTransactionId
								,intTransactionTypeId
								,intLotId
								,intSubLocationId
								,intStorageLocationId
								,ysnIsStorage
								,strDistributionOption 
							FROM @LineItem
							where intId = @intId
					END
					EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemShipment; 
				END
			IF @ysnIsStorage = 1
			BEGIN
				IF @ysnDPStorage = 1
					BEGIN
					INSERT INTO @LineItems (
					intContractDetailId,
					dblUnitsDistributed,
					dblUnitsRemaining,
					dblCost,
					intCurrencyId)
					EXEC dbo.uspCTUpdationFromTicketDistribution 
					@intTicketId
					,@intEntityId
					,@dblLoopContractUnits
					,@intLoopContractId
					,@intUserId
					,@ysnDPStorage

					SET @dblLoopContractUnits = @dblLoopContractUnits * -1
					DECLARE @intDPContractId INT;
					DECLARE @dblDPContractUnits NUMERIC(12,4);
					DECLARE intListCursorDP CURSOR LOCAL FAST_FORWARD
					FOR
					SELECT intContractDetailId, dblUnitsDistributed
					FROM @LineItems;

					OPEN intListCursorDP;

					-- Initial fetch attempt
					FETCH NEXT FROM intListCursorDP INTO @intDPContractId, @dblDPContractUnits;

					WHILE @@FETCH_STATUS = 0
					BEGIN
						-- Here we do some kind of action that requires us to 
						-- process the table variable row-by-row. This example simply
						-- uses a PRINT statement as that action (not a very good
						-- example).
						IF	ISNULL(@intDPContractId,0) != 0
							INSERT INTO @ItemsForItemShipment (
							intItemId
							,intItemLocationId
							,intItemUOMId
							,dtmDate
							,dblQty
							,dblUOMQty
							,dblCost
							,dblSalesPrice
							,intCurrencyId
							,dblExchangeRate
							,intTransactionId
							,intTransactionDetailId
							,strTransactionId
							,intTransactionTypeId
							,intLotId
							,intSubLocationId
							,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
							,ysnIsStorage
							,strSourceTransactionId  
							)
							EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, @intDPContractId
							EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intDPContractId, @dblDPContractUnits, @intEntityId, @ysnIsStorage;
						-- Attempt to fetch next row from cursor
						FETCH NEXT FROM intListCursorDP INTO @intLoopContractId, @dblDPContractUnits;
					END;

					CLOSE intListCursorDP;
					DEALLOCATE intListCursorDP;
				END
				ELSE
					BEGIN
					SET @dblLoopContractUnits = @dblLoopContractUnits * -1
					INSERT INTO @ItemsForItemShipment (
						intItemId
						,intItemLocationId
						,intItemUOMId
						,dtmDate
						,dblQty
						,dblUOMQty
						,dblCost
						,dblSalesPrice
						,intCurrencyId
						,dblExchangeRate
						,intTransactionId
						,intTransactionDetailId
						,strTransactionId
						,intTransactionTypeId
						,intLotId
						,intSubLocationId
						,intStorageLocationId -- ???? I don't see usage for this in the PO to Inventory receipt conversion.
						,ysnIsStorage
						,intStorageScheduleTypeId
					)
					EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, NULL , @intStorageScheduleId
					END
			END		   
			-- Attempt to fetch next row from cursor
			FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId, @intStorageScheduleTypeId;
		END;

CLOSE intListCursor;
DEALLOCATE intListCursor;

SELECT @total = COUNT(*) FROM @ItemsForItemShipment;
IF (@total = 0)
	RETURN;

SELECT TOP 1 @strDistributionOption = strSourceTransactionId FROM @ItemsForItemShipment WHERE (strSourceTransactionId = 'LOD' OR strSourceTransactionId = 'CNT');
IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
 	SET @intOrderId = 1
ELSE
 	SET @intOrderId = 4

BEGIN 
	EXEC dbo.uspSCAddScaleTicketToItemShipment @intTicketId ,@intUserId ,@ItemsForItemShipment ,@intEntityId ,@intOrderId ,@InventoryShipmentId OUTPUT;
END

BEGIN 
	SELECT	@strTransactionId = ship.strShipmentNumber
	FROM	dbo.tblICInventoryShipment ship	        
	WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
	END
	SELECT @strLotTracking = strLotTracking FROM tblICItem WHERE intItemId = @intItemId
	IF @strLotTracking = 'No' -- temporary fixes for 16.2
	--IF @strLotTracking != 'Yes - Manual'
		BEGIN
			EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId;

			--INVOICE intergration
			SELECT @intPricingTypeId = CTD.intPricingTypeId FROM tblICInventoryShipmentItem ISI 
			LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = ISI.intLineNo
			WHERE intInventoryShipmentId = @InventoryShipmentId

			IF ISNULL(@InventoryShipmentId, 0) != 0 AND (ISNULL(@intPricingTypeId,0) <= 1 OR ISNULL(@intPricingTypeId,0) = 6) AND ISNULL(@strWhereFinalizedWeight, 'Origin') = 'Origin' AND ISNULL(@strWhereFinalizedGrade, 'Origin') = 'Origin'
			BEGIN
				EXEC @intInvoiceId = dbo.uspARCreateInvoiceFromShipment @InventoryShipmentId, @intUserId, NULL;
			END
		END
_Exit:
	
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