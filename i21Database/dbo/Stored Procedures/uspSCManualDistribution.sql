CREATE PROCEDURE [dbo].[uspSCManualDistribution]
	@LineItem ScaleManualCostingTableType READONLY,
	@intTicketId AS INT, 
	@intUserId AS INT,
	@intEntityId AS INT,
	@InventoryReceiptId AS INT OUTPUT 
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @ItemsForItemReceipt AS ItemCostingTableType
DECLARE @total AS INT
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @strDistributionOption NVARCHAR(40) = NULL

DECLARE @dblRemainingUnits AS DECIMAL (13,3)
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketUOM INT
DECLARE @intTicketItemUOMId INT
DECLARE @strReceiptType AS NVARCHAR(100)
DECLARE @intLoadId INT
DECLARE @dblTicketFreightRate AS DECIMAL (9, 5)
DECLARE @intScaleStationId AS INT
DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnIsStorage AS BIT
DECLARE @intLoadContractId AS INT
DECLARE @dblLoadScheduledUnits AS NUMERIC(12,4)
DECLARE @strInOutFlag AS NVARCHAR(100)
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @intItemId AS INT
DECLARE @intStorageScheduleId AS INT

BEGIN
	SELECT	@intTicketUOM = UOM.intUnitMeasureId, @intItemId = SC.intItemId
	FROM	dbo.tblSCTicket SC	        
			JOIN dbo.tblICItemUOM UOM ON SC.intItemId = UOM.intItemId
	WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
END

BEGIN 
	SELECT	@intTicketItemUOMId = UM.intItemUOMId, @intLoadId = SC.intLoadId
		FROM	dbo.tblICItemUOM UM	
	      JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE	UM.ysnStockUnit = 1 AND SC.intTicketId = @intTicketId
END

--BEGIN 
--	SELECT	@intTicketItemUOMId = UM.intItemUOMId
--	FROM	dbo.tblICItemUOM UM	
--			JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
--	WHERE	UM.intUnitMeasureId = @intTicketUOM AND SC.intTicketId = @intTicketId
--END

BEGIN TRY
DECLARE @intId INT;
DECLARE @intLoopContractId INT;
DECLARE @dblLoopContractUnits NUMERIC(12,4);
DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT intTransactionDetailId, dblQty, ysnIsStorage, intId, strDistributionOption , intStorageScheduleId
FROM @LineItem;

OPEN intListCursor;

		-- Initial fetch attempt
		FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Here we do some kind of action that requires us to 
			-- process the table variable row-by-row. This example simply
			-- uses a PRINT statement as that action (not a very good
			-- example).
			IF @ysnIsStorage = 0
				BEGIN
					IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
					BEGIN
						IF @strDistributionOption = 'LOD'
							BEGIN 
								SELECT @intLoadId = intLoadId, @strInOutFlag = strInOutFlag FROM tblSCTicket WHERE intTicketId = @intTicketId;
							END
							BEGIN
								IF @strInOutFlag = 'I'
									SELECT @intLoadContractId = LGL.intPContractDetailId, @dblLoadScheduledUnits = LGL.dblQuantity FROM vyuLGLoadDetailView LGL WHERE LGL.intLoadId = @intLoadId
								ELSE
									SELECT @intLoadContractId = LGL.intSContractDetailId, @dblLoadScheduledUnits = LGL.dblQuantity FROM vyuLGLoadDetailView LGL WHERE LGL.intLoadId = @intLoadId
							END
							IF @intLoadContractId IS NOT NULL
							BEGIN
								SET @dblLoadScheduledUnits = @dblLoadScheduledUnits * -1;
								EXEC uspCTUpdateScheduleQuantity @intLoadContractId, @dblLoadScheduledUnits, @intUserId, @intTicketId, 'Scale'
							END
							BEGIN
								INSERT INTO [dbo].[tblSCTicketCost]
										([intTicketId]
										,[intConcurrencyId]
										,[intItemId]
										,[intEntityVendorId]
										,[strCostMethod]
										,[dblRate]
										,[intItemUOMId]
										,[ysnAccrue]
										,[ysnMTM]
										,[ysnPrice])
							SELECT	@intTicketId,
									1, 
									LD.intItemId,
									LD.intVendorId,
									LD.strCostMethod,
									LD.dblRate,
									LD.intItemUOMId,
									LD.ysnAccrue,
									LD.ysnMTM,
									LD.ysnPrice
							FROM	tblLGLoadCost LD WHERE LD.intLoadId = @intLoadId
							END
							IF @strDistributionOption = 'CNT'
								BEGIN
									INSERT INTO [dbo].[tblSCTicketCost]
											   ([intTicketId]
											   ,[intConcurrencyId]
											   ,[intItemId]
											   ,[intEntityVendorId]
											   ,[strCostMethod]
											   ,[dblRate]
											   ,[intItemUOMId]
											   ,[ysnAccrue]
											   ,[ysnMTM]
											   ,[ysnPrice])
									SELECT	@intTicketId,
											1, 
											CC.intItemId,
											CC.intVendorId,
											CC.strCostMethod,
											CC.dblRate,
											CC.intItemUOMId,
											CC.ysnAccrue,
											CC.ysnMTM,
											CC.ysnPrice
									FROM	tblCTContractCost CC WHERE CC.intContractDetailId = @intLoopContractId
								END
							IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
							BEGIN
								IF	ISNULL(@intLoopContractId,0) != 0
								--EXEC uspCTUpdateScheduleQuantity @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale'
								EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
							END
						INSERT INTO @ItemsForItemReceipt (
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
						INSERT INTO @ItemsForItemReceipt (
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
					EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt; 
				END
			IF @ysnIsStorage = 1
			BEGIN
				INSERT INTO @ItemsForItemReceipt (
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
				EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblLoopContractUnits , @intEntityId, @strDistributionOption, NULL , @intStorageScheduleId
			END		   
			-- Attempt to fetch next row from cursor
			FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits, @ysnIsStorage, @intId, @strDistributionOption, @intStorageScheduleId;
		END;

CLOSE intListCursor;
DEALLOCATE intListCursor;

SELECT @total = COUNT(*) FROM @ItemsForItemReceipt;
IF (@total = 0)
	RETURN;
BEGIN 
	EXEC dbo.uspSCAddScaleTicketToItemReceipt @intTicketId, @intUserId, @ItemsForItemReceipt, @intEntityId, NULL, @InventoryReceiptId OUTPUT; 
END

BEGIN 
SELECT	@strTransactionId = IR.strReceiptNumber
FROM	dbo.tblICInventoryReceipt IR	        
WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		
END

	SELECT @strLotTracking = strLotTracking FROM tblICItem WHERE intItemId = @intItemId
	IF @strLotTracking != 'Yes - Manual'
		BEGIN
			EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intEntityId;
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