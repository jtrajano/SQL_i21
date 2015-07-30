CREATE PROCEDURE [dbo].[uspSCProcessToItemReceipt]
	 @intSourceTransactionId AS INT
	,@strSourceType AS NVARCHAR(100) 
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (13,3)
	,@dblCost AS DECIMAL (9,5)
	,@intEntityId AS INT
	,@intContractId AS INT
	,@strDistributionOption AS NVARCHAR(3)
	,@InventoryReceiptId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

-- Constant variables for the source type
DECLARE @SourceType_PurchaseOrder AS NVARCHAR(100) = 'Purchase Order'
DECLARE @SourceType_TransferOrder AS NVARCHAR(100) = 'Transfer Order'
DECLARE @SourceType_Direct AS NVARCHAR(100) = 'Direct'
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @strDummyDistributionOption AS NVARCHAR(3) = NULL

DECLARE @ItemsForItemReceipt AS ItemCostingTableType
DECLARE @intTicketId AS INT = @intSourceTransactionId
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
DECLARE @ysnDeductFreightFarmer AS BIT

BEGIN
    SELECT TOP 1 @intLoadId = ST.intLoadId, @dblTicketFreightRate = ST.dblFreightRate, @intScaleStationId = ST.intScaleSetupId,
	@ysnDeductFreightFarmer = ST.ysnFarmerPaysFreight
	FROM dbo.tblSCTicket ST WHERE
	ST.intTicketId = @intTicketId
END

DECLARE @ErrMsg                    NVARCHAR(MAX),
              @dblBalance          NUMERIC(12,4),                    
              @intItemId           INT,
              @dblNewBalance       NUMERIC(12,4),
              @strInOutFlag        NVARCHAR(4),
              @dblQuantity         NUMERIC(12,4),
              @strAdjustmentNo     NVARCHAR(50)

BEGIN TRY
		IF @strDistributionOption = 'LOD'
		BEGIN
			IF @intLoadId IS NULL
			BEGIN 
				RAISERROR('Unable to find load details. Try Again.', 11, 1);
				GOTO _Exit
			END
			ELSE
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
		FROM	tblCTContractCost CC WHERE CC.intContractDetailId = @intContractId
		END
		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		BEGIN
			SET @strReceiptType = 'Purchase Contract'
		END
		ELSE
		BEGIN
			SET @strReceiptType = 'Direct'
		END
		BEGIN 
			SELECT	@intTicketUOM = UOM.intUnitMeasureId
			FROM	dbo.tblSCTicket SC	        
					JOIN dbo.tblICCommodityUnitMeasure UOM On SC.intCommodityId  = UOM.intCommodityId
			WHERE	SC.intTicketId = @intTicketId AND UOM.ysnStockUnit = 1		
		END

		BEGIN 
			SELECT	@intTicketItemUOMId = UM.intItemUOMId
				FROM	dbo.tblICItemUOM UM	
				  JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
			WHERE	UM.intUnitMeasureId =@intTicketUOM AND SC.intTicketId = @intTicketId
		END
				IF @dblTicketFreightRate > 0
		BEGIN
	   	SELECT	@intFreightItemId = ST.intFreightItemId
		FROM	dbo.tblSCScaleSetup ST	        
		WHERE	ST.intScaleSetupId = @intScaleStationId
		IF @intFreightItemId IS NULL 
		BEGIN 
			-- Raise the error:
			RAISERROR('Invalid Default Freight Item in Scale Setup - uspSCProcessToItemReceipt', 16, 1);
			RETURN;
		END
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
				@intFreightItemId,
				SS.intFreightCarrierId,
				'Per Unit',
				SS.dblFreightRate,
				@intTicketItemUOMId,
				1,
				0,
				0
		FROM	tblSCTicket SS WHERE SS.intTicketId = @intTicketId
		END
		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		BEGIN
			INSERT INTO @LineItems (
			intContractDetailId,
			dblUnitsDistributed,
			dblUnitsRemaining,
			dblCost)
			EXEC dbo.uspCTUpdationFromTicketDistribution 
			 @intTicketId
			,@intEntityId
			,@dblNetUnits
			,@intContractId
			,@intUserId
			,0
			IF @strDistributionOption = 'CNT'
			BEGIN
				DECLARE @intLoopContractId INT;
				DECLARE @dblLoopContractUnits NUMERIC(12,4);
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intContractDetailId, dblUnitsDistributed
				FROM @LineItems;

				OPEN intListCursor;

				-- Initial fetch attempt
				FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits;

				WHILE @@FETCH_STATUS = 0
				BEGIN
				   -- Here we do some kind of action that requires us to 
				   -- process the table variable row-by-row. This example simply
				   -- uses a PRINT statement as that action (not a very good
				   -- example).
				   IF	ISNULL(@intLoopContractId,0) != 0
				   EXEC uspCTUpdateScheduleQuantity @intLoopContractId, @dblLoopContractUnits

				   -- Attempt to fetch next row from cursor
				   FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits;
				END;

				CLOSE intListCursor;
				DEALLOCATE intListCursor;
			END
		SELECT TOP 1 @dblRemainingUnits = LI.dblUnitsRemaining FROM @LineItems LI
		IF(@dblRemainingUnits IS NULL)
		BEGIN
		SET @dblRemainingUnits = @dblNetUnits
		END
		IF(@dblRemainingUnits > 0)
		BEGIN
			EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblRemainingUnits , @intEntityId, @strDummyDistributionOption, NULL
			IF (@dblRemainingUnits = @dblNetUnits)
			RETURN
		END
		UPDATE @LineItems set intTicketId = @intTicketId
		DELETE FROM @ItemsForItemReceipt
		END

	-- Get the items to process
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
		,ysnIsCustody 
	)
	EXEC dbo.uspSCGetScaleItemForItemReceipt 
		 @intTicketId
		,@strSourceType
		,@intUserId
		,@dblNetUnits
		,@dblCost
		,@intEntityId
		,@intContractId
		,@strDistributionOption
		,@LineItems

	-- Validate the items to receive 
	EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt; 

	-- Add the items to the item receipt 
	--IF @strSourceType = @SourceType_Direct
	BEGIN 
		EXEC dbo.uspSCAddScaleTicketToItemReceipt @intTicketId, @intUserId, @ItemsForItemReceipt, @intEntityId, @strReceiptType, @InventoryReceiptId OUTPUT; 
	END

	BEGIN 
	SELECT	@strTransactionId = IR.strReceiptNumber
	FROM	dbo.tblICInventoryReceipt IR	        
	WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		
	END
	EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intUserId, @intEntityId;
	--EXEC dbo.uspAPCreateBillFromIR @InventoryReceiptId, @intUserId;

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