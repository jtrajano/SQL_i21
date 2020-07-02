CREATE PROCEDURE [dbo].[uspSCReverseDeliverySheet]
	@intDeliverySheetId INT,
	@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@jsonData NVARCHAR(MAX);

DECLARE @storageHistoryData AS StorageHistoryStagingTable
DECLARE @dblDeliverySheetGross NUMERIC(18,6)
DECLARE @dblDeliverySheetShrink NUMERIC(18,6)
DECLARE @_intTicketId INT
DECLARE @intInventoryAdjustmentId INT
DECLARE @strAdjustmentNo NVARCHAR(50)
DECLARE @strReversalAdjustmentDescription NVARCHAR(200)
DECLARE @strDeliverySheetNumber NVARCHAR(50)
DECLARE @intReversedInventoryAdjustmentId INT
DECLARE @intAdjustmentItemId INT
DECLARE @intAdjustmentLocationId INT
DECLARE @intAdjustmentSubLocationId INT
DECLARE @intAdjustmentStorageLocationId INT
DECLARE @strLotNumber NVARCHAR(50)
DECLARE @intOwnershipType INT
DECLARE @dblAdjustByQuantity NUMERIC(18,6)
DECLARE @intItemUOMId INT
DECLARE @dtmTransactionDate DATETIME
DECLARE @intLoopDeliverySheetContractAdjustmentId INT
DECLARE @intDSContractAdjusmentDeliverySheetId INT
DECLARE @intDSContractAdjusmentContractDetailId INT
DECLARE @intDSContractAdjusmentEntityId INT
DECLARE @dblDSContractAdjusmentQuantity  NUMERIC(18,6)
DECLARE @intDSContractAdjusmentItemUOMId INT
DECLARE @CustomerStorageId AS Id

BEGIN TRY

	--- get Delivery Sheet Information
	SELECT TOP 1 
		@dblDeliverySheetGross = dblGross
		,@dblDeliverySheetShrink = dblShrink
		,@strDeliverySheetNumber = strDeliverySheetNumber
	FROM tblSCDeliverySheet
	WHERE intDeliverySheetId = @intDeliverySheetId

	SET @dtmTransactionDate = GETDATE()

	IF(ISNULL(@dblDeliverySheetShrink,0) > 0)
	BEGIN
		Print 'Delivery Sheet with Adjustment'

		--GEt previous inventory adjustment information
		SELECT TOP 1
			@strAdjustmentNo = A.strAdjustmentNo
			,@intInventoryAdjustmentId = A.intInventoryAdjustmentId 
			,@intAdjustmentItemId = B.intItemId
			,@intAdjustmentLocationId = A.intLocationId
			,@intAdjustmentStorageLocationId = B.intStorageLocationId
			,@strLotNumber = B.strNewLotNumber
			,@intOwnershipType =B.intOwnershipType
			,@dblAdjustByQuantity = B.dblAdjustByQuantity
			,@intItemUOMId = B.intItemUOMId
		FROM tblICInventoryAdjustment A 
		INNER JOIN tblICInventoryAdjustmentDetail B
			ON A.intInventoryAdjustmentId = B.intInventoryAdjustmentId
		WHERE intSourceId = @intDeliverySheetId 
			AND strDescription LIKE 'Delivery Sheet Posting%'

		--- mark the previous adjustment as reversed
		UPDATE tblICInventoryAdjustment
		SET strDescription = REPLACE(strDescription, 'Delivery Sheet', 'Delivery Sheet(Reversed)')
			,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
		WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId


		---Create Reversal Adjustment
		BEGIN
			SET @strReversalAdjustmentDescription = 'Delivery Sheet(Reversed) Posting';
			SET	@strReversalAdjustmentDescription = @strReversalAdjustmentDescription + (SELECT (CASE WHEN ISNULL(@strDeliverySheetNumber, '') != '' THEN  '- ' + @strDeliverySheetNumber ELSE '' END) )
			

			EXEC [dbo].[uspICInventoryAdjustment_CreatePostQtyChange]
				@intAdjustmentItemId
				,@dtmTransactionDate
				,@intAdjustmentLocationId
				,@intAdjustmentSubLocationId
				,@intAdjustmentStorageLocationId
				,@strLotNumber
				,@intOwnershipType
				,@dblAdjustByQuantity 
				,0
				,@intItemUOMId
				,@intDeliverySheetId --delivery sheet id
				,53 --Delivery Sheet inventory transaction id
				,@intUserId
				,@intReversedInventoryAdjustmentId OUTPUT
				,@strReversalAdjustmentDescription;
		END

		-- insert reversal adjustment in the storage history table
		BEGIN
			INSERT INTO @storageHistoryData
			(
				[intCustomerStorageId]
				,[intTicketId]
				,[intDeliverySheetId]
				,[intInventoryAdjustmentId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[dblCurrencyRate]
				,[strPaidDescription]
				,[intTransactionTypeId]
				,[intUserId]
				,[strType]
				,[ysnPost]
				,[strTransactionId]	
			)
			SELECT 	
				[intCustomerStorageId]				= intCustomerStorageId				
				,[intTicketId]						= NULL
				,[intDeliverySheetId]				= intDeliverySheetId
				,[intInventoryAdjustmentId]			= @intReversedInventoryAdjustmentId
				,[dblUnits]							= (dblUnits * -1)
				,[dtmHistoryDate]					= @dtmTransactionDate
				,[dblCurrencyRate]					= 1
				,[strPaidDescription]				= 'Quantity Adjustment Reversal ' + @strAdjustmentNo + ' From Delivery Sheet'
				,[intTransactionTypeId]				= 9
				,[intUserId]						= @intUserId
				,[strType]							= 'From Inventory Adjustment'
				,[ysnPost]							= 1
				,[strTransactionId]					= @strAdjustmentNo
			FROM tblGRStorageHistory 
			WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId

			EXEC uspGRInsertStorageHistoryRecord @storageHistoryData
		END

	
		--Update Discount of customer storages and opening balance
		BEGIN
			INSERT INTO @CustomerStorageId
			SELECT 
				A.intCustomerStorageId 
			FROM tblGRCustomerStorage A
			INNER JOIN tblSCDeliverySheet B
				ON A.intDeliverySheetId = B.intDeliverySheetId
			INNER JOIN tblSCDeliverySheetSplit C
				ON B.intDeliverySheetId = C.intDeliverySheetId
			WHERE A.intEntityId = C.intEntityId
				AND A.intItemId = B.intItemId
				AND A.intCompanyLocationId = B.intCompanyLocationId 
				AND ISNULL(A.intDeliverySheetId,0) = ISNULL(B.intDeliverySheetId,0)
				AND A.intStorageTypeId = C.intStorageScheduleTypeId
				AND A.intDeliverySheetId = @intDeliverySheetId
				AND A.ysnTransferStorage = 0

		
			DELETE FROM tblQMTicketDiscount 
			WHERE intTicketFileId IN (	SELECT intId FROM @CustomerStorageId) 
			AND strSourceType = 'Storage'

			--update customer storage
			UPDATE tblGRCustomerStorage
			SET dblOriginalBalance = A.dblOriginalBalance
				,dblOpenBalance = A.dblOpenBalance
			FROM (SELECT
					intCustomerStorageId
					,dblOriginalBalance = dbo.[fnGRCalculateStorageUnits](intCustomerStorageId)
					,dblOpenBalance = dbo.[fnGRCalculateStorageUnits](intCustomerStorageId)
				 FROM tblGRCustomerStorage
				 WHERE intCustomerStorageId IN (SELECT intId FROM @CustomerStorageId) 
				 ) A
			WHERE A.intCustomerStorageId = tblGRCustomerStorage.intCustomerStorageId
			
				
		END

		--- Check DP Contrac Adjustments
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM tblSCDeliverySheetContractAdjustment WHERE intDeliverySheetId = @intDeliverySheetId AND ysnReversed = 0)
			BEGIN
				SELECT 
					*
				INTO #tblSCDeliverySheetContractAdjustment
				FROM tblSCDeliverySheetContractAdjustment
				WHERE intDeliverySheetId = @intDeliverySheetId

				SELECT TOP 1 
					@intLoopDeliverySheetContractAdjustmentId = intDeliverySheetContractAdjustmentId
					,@intDSContractAdjusmentDeliverySheetId = [intDeliverySheetId]
					,@intDSContractAdjusmentContractDetailId = [intContractDetailId]
					,@intDSContractAdjusmentEntityId = [intEntityId]
					,@dblDSContractAdjusmentQuantity = -[dblQuantity]
					,@intDSContractAdjusmentItemUOMId = [intItemUOMId]
				FROM #tblSCDeliverySheetContractAdjustment
				ORDER BY intDeliverySheetContractAdjustmentId

				WHILE (ISNULL(@intLoopDeliverySheetContractAdjustmentId,0) > 0)
				BEGIN

					EXEC uspCTUpdateSequenceQuantityUsingUOM @intDSContractAdjusmentContractDetailId, @dblDSContractAdjusmentQuantity, @intUserId, @intDSContractAdjusmentDeliverySheetId, 'Delivery Sheet',@intDSContractAdjusmentItemUOMId


					--Loop Iterator
					BEGIN
						IF EXISTS(SELECT TOP 1 1 FROM #tblSCDeliverySheetContractAdjustment WHERE intDeliverySheetContractAdjustmentId > @intLoopDeliverySheetContractAdjustmentId)
						BEGIN
							SELECT TOP 1 
								@intLoopDeliverySheetContractAdjustmentId = intDeliverySheetContractAdjustmentId
								,@intDSContractAdjusmentDeliverySheetId = [intDeliverySheetId]
								,@intDSContractAdjusmentContractDetailId = [intContractDetailId]
								,@intDSContractAdjusmentEntityId = [intEntityId]
								,@dblDSContractAdjusmentQuantity = [dblQuantity]
								,@intDSContractAdjusmentItemUOMId = [intItemUOMId]
							FROM #tblSCDeliverySheetContractAdjustment
							WHERE intDeliverySheetContractAdjustmentId > @intLoopDeliverySheetContractAdjustmentId
							ORDER BY intDeliverySheetContractAdjustmentId
						END
						ELSE
						BEGIN
							SET @intLoopDeliverySheetContractAdjustmentId = 0
						END
					END

				END

				DELETE FROM tblSCDeliverySheetContractAdjustment
				WHERE intDeliverySheetId = @intDeliverySheetId 
			END
		END

		--Update DP contract adjustments table
		UPDATE tblSCDeliverySheetContractAdjustment
		SET ysnReversed = 1
		WHERE intDeliverySheetId = @intDeliverySheetId 
			AND ysnReversed = 0
	END
	ELSE
	BEGIN
		PRINT 'No adjustment'
	END

	---Update Delivery Sheet Status 
	EXEC [dbo].[uspSCUpdateDeliverySheetStatus] @intDeliverySheetId, 1;
		
	--Audit Log Delivery Sheet
	BEGIN
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intDeliverySheetId				-- Primary Key Value of the Ticket. 
			,@screenName		= 'Grain.view.DeliverySheet'		-- Screen Namespace
			,@entityId			= @intUserId						-- Entity Id.
			,@actionType		= 'Updated'							-- Action Type
			,@changeDescription	= 'Delivery Sheet Status'			-- Description
			,@fromValue			= 'Posted'							-- Previous Value
			,@toValue			= 'Unposted'						-- New Value
			,@details			= '';
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