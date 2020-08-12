CREATE PROCEDURE [dbo].[uspSCProcessToItemReceipt]
	 @intSourceTransactionId AS INT
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (38,20)
	,@dblCost AS DECIMAL (38, 20)
	,@intEntityId AS INT
	,@intContractId AS INT
	,@strDistributionOption AS NVARCHAR(3)
	,@intStorageScheduleId AS INT = NULL
	,@InventoryReceiptId AS INT OUTPUT
	,@intBillId AS INT OUTPUT
	,@ysnSkipValidation as BIT = NULL
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
		,@voucherItems AS VoucherDetailReceipt 
		,@voucherOtherCharges AS VoucherDetailReceiptCharge
		,@thirdPartyVoucher AS VoucherDetailReceiptCharge
		,@prePayId AS Id		
		,@voucherPayable as VoucherPayable
		,@voucherTaxDetail as VoucherDetailTax
DECLARE @intTicketId AS INT = @intSourceTransactionId
DECLARE @dblRemainingUnits AS NUMERIC(38, 20)
DECLARE @dblRemainingQuantity AS NUMERIC(38, 20)
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @intDirectType AS INT = 3
DECLARE @intTicketItemUOMId INT
DECLARE @strReceiptType AS NVARCHAR(100)
DECLARE @intLoadId INT
DECLARE @dblTicketFreightRate AS DECIMAL (9, 5)
DECLARE @intScaleStationId AS INT
DECLARE @intFreightItemId AS INT
DECLARE @intFreightVendorId AS INT
DECLARE @ysnDeductFreightFarmer AS BIT
DECLARE @total AS INT
DECLARE @ysnDPStorage AS BIT
DECLARE @strLotTracking AS NVARCHAR(100)
DECLARE @intIRContractPricingType AS INT
DECLARE @intInventoryReceiptItemId AS INT
		,@intOrderId INT
		,@intOwnershipType INT
		,@intPricingTypeId INT
		,@successfulCount AS INT
		,@invalidCount AS INT
		,@success AS INT
		,@batchIdUsed AS INT
		,@recapId AS INT
		,@dblTotal AS DECIMAL(18,6)
		,@returnValue AS BIT
		,@requireApproval AS BIT
		,@intLocationId AS INT
		,@intShipTo AS INT
		,@intShipFrom AS INT
		,@intCurrencyId AS INT
		,@intHaulerId INT
		,@intInventoryReceiptChargeId INT
		,@dblQtyReceived NUMERIC (38,20)
		,@dblInventoryReceiptCost NUMERIC (38,20)
		,@intTaxId INT
		,@vendorOrderNumber NVARCHAR(50)
		,@voucherDate DATETIME
		,@dblGrossUnits AS NUMERIC(38, 20)
		,@dblTicketNetUnits AS NUMERIC(38, 20)
		,@intItemId INT
		,@createVoucher AS BIT
		,@postVoucher AS BIT
		,@intLotType INT
		,@intLotId INT
		,@intContractDetailId INT
		,@shipFromEntityId INT
		,@intFarmFieldId INT
		,@intLoadDetailId INT;
DECLARE @intLoadContractDetailId INT
DECLARE @intLoopLoadDetailId INT
DECLARE @dblLoadScheduleQty NUMERIC(18, 6)
DECLARE @intLoopLoadItemUOMId INT
DECLARE @intTicketContractDetailId INT
DECLARE @ysnTicketHasSpecialDiscount BIT
DECLARE @ysnTicketSpecialGradePosted BIT
DECLARE @intTicketEntityId INT
DECLARE @intTicketDeliverySheetId INT
DECLARE @intDeliverySheetEntityId INT
DECLARE @intDeliverySheetItemId INT
DECLARE @intDeliverySheetLocationId INT
DECLARE @strTicketStatus NVARCHAR(5)
DECLARE @_strReceiptNumber NVARCHAR(50)
DECLARE @dblTicketUnitPrice NUMERIC(18, 6)
DECLARE @dblTicketUnitBasis NUMERIC(18, 6)
   

DECLARE @ErrMsg              NVARCHAR(MAX),
        @dblBalance          NUMERIC(38, 20),                    
        @dblNewBalance       NUMERIC(38, 20),
        @strInOutFlag        NVARCHAR(4),
        @dblQuantity         NUMERIC(38, 20),
        @strAdjustmentNo     NVARCHAR(50);

 SELECT TOP 1 @intLoadId = ST.intLoadId
		, @dblTicketFreightRate = ST.dblFreightRate
		, @intScaleStationId = ST.intScaleSetupId
		, @ysnDeductFreightFarmer = ST.ysnFarmerPaysFreight
		, @intLocationId = ST.intProcessingLocationId
		, @dblGrossUnits = ST.dblGrossUnits
		, @dblTicketNetUnits = ST.dblNetUnits
		, @intItemId = ST.intItemId
		, @intTicketItemUOMId = ST.intItemUOMIdTo
		, @shipFromEntityId = ST.intEntityId
		, @intFarmFieldId = ST.intFarmFieldId
		, @intLoadDetailId = ST.intLoadDetailId
		, @intTicketContractDetailId = intContractId
		, @ysnTicketHasSpecialDiscount = ysnHasSpecialDiscount
		, @ysnTicketSpecialGradePosted = ysnSpecialGradePosted
		, @strInOutFlag = strInOutFlag
		, @intTicketItemUOMId = ST.intItemUOMIdTo
		, @intTicketEntityId = ST.intEntityId
		, @intTicketDeliverySheetId = intDeliverySheetId
		, @strTicketStatus = strTicketStatus
		, @dblTicketUnitPrice = dblUnitPrice
		, @dblTicketUnitBasis = dblUnitBasis
FROM dbo.tblSCTicket ST WHERE
ST.intTicketId = @intTicketId

SELECT	@ysnDPStorage = ST.ysnDPOwnedType 
FROM dbo.tblGRStorageType ST WHERE 
ST.strStorageTypeCode = @strDistributionOption


BEGIN TRY
		--Validation
		BEGIN

			IF @strTicketStatus = 'C' OR  @strTicketStatus = 'V'
			BEGIN
				RAISERROR('Cannot distribute closed ticket.', 11, 1);
			END

			---Check existing IS and Invoice
			
			if isnull(@ysnSkipValidation, 0) = 0
			begin
				SELECT TOP 1 
					@_strReceiptNumber = ISNULL(B.strReceiptNumber,'')
				FROM tblICInventoryReceiptItem A
				INNER JOIN tblICInventoryReceipt B
					ON A.intInventoryReceiptId = B.intInventoryReceiptId
				WHERE B.intSourceType = 1
					AND A.intSourceId = @intTicketId

				IF ISNULL(@_strReceiptNumber,'') <> ''
				BEGIN
					SET @ErrMsg  = 'Cannot distribute ticket. Ticket already have a receipt ' + @_strReceiptNumber + '.'
					RAISERROR(@ErrMsg, 11, 1);
				END
			end
			

		END

		IF(@strDistributionOption = 'SPT')
			AND (ISNULL(@dblTicketUnitBasis,0) + ISNULL(@dblTicketUnitPrice,0)) = 0
		BEGIN

			SET @ErrMsg  = 'Cannot distribute Zero Spot ticket with destination Weights/Grades'
			RAISERROR(@ErrMsg, 11, 1);

		END

		IF @strDistributionOption = 'LOD' AND @intLoadId IS NULL
		BEGIN
			RAISERROR('Unable to find load details. Try Again.', 11, 1);
			GOTO _Exit
		END

		IF(ISNULL(@intTicketDeliverySheetId,0) > 0)
		BEGIN
			SELECT TOP 1 
				@intDeliverySheetEntityId = intEntityId
				,@intDeliverySheetItemId = intItemId
				,@intDeliverySheetLocationId = intCompanyLocationId
			FROM tblSCDeliverySheet
			WHERE intDeliverySheetId = @intTicketDeliverySheetId

			IF(@intDeliverySheetEntityId <> @intTicketEntityId OR @intDeliverySheetItemId <> @intItemId OR @intDeliverySheetLocationId <> @intLocationId)
			BEGIN
				RAISERROR('Ticket Entity, Item or Location does not match with the selected Delivery Sheet. Please check the Delivery sheet and re-select it again.', 11, 1);
				GOTO _Exit
			END
		END


		IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		BEGIN
			
			--IF @strDistributionOption = 'CNT'
			--BEGIN

				INSERT INTO @LineItems (
					intContractDetailId,
					dblUnitsDistributed,
					dblUnitsRemaining,
					dblCost,
					intCurrencyId,
					intLoadDetailId)
				EXEC dbo.uspSCGetContractsAndAllocate 
				@intTicketId
				,@intEntityId
				,@dblNetUnits
				,@intContractId
				,@intUserId
				,0
				,0
				,1
				,@strDistributionOption
				,@intLoadDetailId

				UPDATE @LineItems SET intTicketId = @intTicketId

				DECLARE @intLoopContractId INT;
				DECLARE @dblLoopContractUnits NUMERIC(38,20);
				DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
				FOR
				SELECT intContractDetailId, dblUnitsDistributed,intLoadDetailId
				FROM @LineItems;

				
				OPEN intListCursor;

				FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits,@intLoopLoadDetailId;

				WHILE @@FETCH_STATUS = 0
				BEGIN
				
					IF ISNULL(@intLoopContractId,0) != 0
					BEGIN
						--SChedule the quantity against the contract if it's a different contract than the ticket used
						-- IF(@intLoopContractId != @intTicketContractDetailId)
						-- BEGIN
						-- 	EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoopContractId, @dblLoopContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
						-- END
						EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoopContractId, @dblLoopContractUnits, @intEntityId;
					END

					--Insert to the load used table
					IF ISNULL(@intLoopLoadDetailId,0) != 0 AND @strDistributionOption = 'LOD'
					BEGIN
						EXEC dbo.uspSCUpdateTicketLoadUsed @intTicketId,@intLoopLoadDetailId, @dblLoopContractUnits, @intEntityId;	
					END
				
					FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits,@intLoopLoadDetailId;

					
				END;

				CLOSE intListCursor;
				DEALLOCATE intListCursor;
			--END
			--ELSE IF @strDistributionOption = 'LOD'
			--BEGIN
			--	INSERT INTO @LineItems (  
			--		intTicketId,  
			--		intContractDetailId,  
			--		dblUnitsDistributed,  
			--		dblUnitsRemaining,  
			--		dblCost,  
			--		intCurrencyId
			--		,intLoadDetailId)  
			--	EXEC [uspSCGetLoadContractsAndAllocate]  
			--	@intTicketId  
			--	,@intLoadDetailId  
			--	,@dblNetUnits  
			--	,'I'  


			--	DECLARE @intLoadContractId INT;
			--	DECLARE @dblLoadContractUnits NUMERIC(38,20);
			--	DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
			--	FOR
			--	SELECT intContractDetailId, dblUnitsDistributed,intLoadDetailId
			--	FROM @LineItems;

			--	OPEN intListCursor;

			--	-- Initial fetch attempt
			--	FETCH NEXT FROM intListCursor INTO @intLoadContractId, @dblLoadContractUnits,@intLoopLoadDetailId;

			--	WHILE @@FETCH_STATUS = 0
			--	BEGIN
			--		IF ISNULL(@intLoadContractId,0) != 0
			--		BEGIN

			--			--get contract Detail Id of the load detail  
			--			SELECT @intLoadContractDetailId = intPContractDetailId FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoopLoadDetailId  
							
			--			-- remove schedule quantity of the load schedule  					
			--			SELECT TOP 1 @dblLoadScheduleQty = dblQuantity,@intLoopLoadItemUOMId = intItemUOMId FROM tblLGLoadDetail WHERE intLoadDetailId = @intLoopLoadDetailId  
			--			SET @dblLoadScheduleQty  = @dblLoadScheduleQty * -1  
			--			EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoadContractDetailId, @dblLoadScheduleQty , @intUserId, @intTicketId, 'Scale', @intLoopLoadItemUOMId  
								
			--			-- add schedule quantity of the ticket  
			--			EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoadContractDetailId, @dblLoadContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId  

			--			SELECT @intContractDetailId = intContractDetailId FROM tblCTContractDetail WHERE intContractDetailId = @intLoadContractId
			--			IF @intContractDetailId != @intContractId
			--			BEGIN
			--				--EXEC uspCTUpdateScheduleQuantityUsingUOM @intLoadContractId, @dblLoadContractUnits, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
			--				EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoadContractId, @dblLoadContractUnits, @intEntityId;
							
			--			END
			--			ELSE
			--			BEGIN
			--				EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intLoadContractId, @dblLoadContractUnits, @intEntityId,1;
			--			END
			--		END

			--		IF(ISNULL(@intLoopLoadDetailId,0) > 0)
			--		BEGIN 
			--			EXEC dbo.uspSCUpdateTicketLoadUsed @intTicketId,@intLoopLoadDetailId, @dblLoadContractUnits, @intEntityId;	
			--		END

			--		-- Attempt to fetch next row from cursor
			--		FETCH NEXT FROM intListCursor INTO @intLoadContractId, @dblLoadContractUnits,@intLoopLoadDetailId
			--	END;
			--	CLOSE intListCursor;
			--	DEALLOCATE intListCursor;


				
			--END

			SELECT TOP 1 @dblRemainingUnits = MIN(LI.dblUnitsRemaining) FROM @LineItems LI
			IF(@dblRemainingUnits IS NULL)
			BEGIN
			SET @dblRemainingUnits = @dblNetUnits
			END
			IF(@dblRemainingUnits > 0)
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
					,intStorageScheduleTypeId
					,ysnAllowVoucher 
				)
				EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblRemainingUnits , @intEntityId, @strDistributionOption, NULL

				SELECT TOP 1 @dblRemainingQuantity = dblQty FROM @ItemsForItemReceipt
				IF(@dblRemainingUnits > ISNULL(@dblRemainingQuantity,0))
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
						,intStorageScheduleTypeId
						,ysnAllowVoucher
					)
					EXEC dbo.uspSCGetScaleItemForItemReceipt 
						@intTicketId
						,@intUserId
						,@dblRemainingUnits
						,0
						,@intEntityId
						,@intContractId
						,'SPT'
						,@LineItems
				END
			END
			
			UPDATE @LineItems set intTicketId = @intTicketId
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
				,ysnIsStorage
				,strSourceTransactionId  
				,intStorageScheduleTypeId
				,ysnAllowVoucher
			)
			EXEC dbo.uspSCGetScaleItemForItemReceipt 
				@intTicketId
				,@intUserId
				,@dblNetUnits
				,@dblCost
				,@intEntityId
				,@intContractId
				,@strDistributionOption
				,@LineItems

			-- Validate the items to receive 
			EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt; 

			SELECT @total = COUNT(*) FROM @ItemsForItemReceipt;
			IF (@total = 0)
				RETURN;
		END
	ELSE
	BEGIN
		IF @strDistributionOption = 'SPT'
		BEGIN
			UPDATE @LineItems set intTicketId = @intTicketId
				--DELETE FROM @ItemsForItemReceipt
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
					,ysnIsStorage
					,strSourceTransactionId 
					,intStorageScheduleTypeId
					,ysnAllowVoucher
				)
				EXEC dbo.uspSCGetScaleItemForItemReceipt 
					 @intTicketId
					,@intUserId
					,@dblNetUnits
					,@dblCost
					,@intEntityId
					,@intContractId
					,@strDistributionOption
					,@LineItems

			-- Validate the items to receive 
			EXEC dbo.uspICValidateProcessToItemReceipt @ItemsForItemReceipt;
		END
		ELSE
		BEGIN
			IF @ysnDPStorage = 1
				BEGIN
					SET @strReceiptType = 'Delayed Price';
					INSERT INTO @LineItems (
					intContractDetailId,
					dblUnitsDistributed,
					dblUnitsRemaining,
					dblCost,
					intCurrencyId,
					intLoadDetailId)
					EXEC dbo.uspSCGetContractsAndAllocate 
					@intTicketId
					,@intEntityId
					,@dblNetUnits
					,@intContractId
					,@intUserId
					,@ysnDPStorage

					DECLARE @intDPContractId INT;
					DECLARE @dblDPContractUnits NUMERIC(38,20);
					DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
					FOR
					SELECT intContractDetailId, dblUnitsDistributed
					FROM @LineItems;

					OPEN intListCursor;

					-- Initial fetch attempt
					FETCH NEXT FROM intListCursor INTO @intDPContractId, @dblDPContractUnits;

					WHILE @@FETCH_STATUS = 0
					BEGIN
						-- Here we do some kind of action that requires us to 
						-- process the table variable row-by-row. This example simply
						-- uses a PRINT statement as that action (not a very good
						-- example).
						IF	ISNULL(@intDPContractId,0) != 0
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
								,intStorageLocationId
								,ysnIsStorage
								,strSourceTransactionId 
								,intStorageScheduleTypeId
								,ysnAllowVoucher 
							)
							EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblNetUnits , @intEntityId, @strDistributionOption, @intDPContractId, @intStorageScheduleId
							EXEC dbo.uspSCUpdateTicketContractUsed @intTicketId, @intDPContractId, @dblNetUnits, @intEntityId, @ysnDPStorage;

						-- Attempt to fetch next row from cursor
						FETCH NEXT FROM intListCursor INTO @intLoopContractId, @dblLoopContractUnits;
					END;

					CLOSE intListCursor;
					DEALLOCATE intListCursor;
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
							,intStorageScheduleTypeId
							,ysnAllowVoucher
					)
					EXEC dbo.uspSCStorageUpdate @intTicketId, @intUserId, @dblNetUnits , @intEntityId, @strDistributionOption, NULL, @intStorageScheduleId
				END
		END
	END

	BEGIN 
		EXEC dbo.uspSCAddScaleTicketToItemReceipt @intTicketId, @intUserId, @ItemsForItemReceipt, @intEntityId, @strReceiptType, @InventoryReceiptId OUTPUT; 
	END

	SELECT	@strTransactionId = IR.strReceiptNumber
			,@intShipFrom = IR.intShipFromId
			,@intShipTo = IR.intLocationId
			,@intCurrencyId = IR.intCurrencyId
			,@vendorOrderNumber = IR.strVendorRefNo
			,@intCurrencyId = IR.intCurrencyId
	FROM	dbo.tblICInventoryReceipt IR	        
	WHERE	IR.intInventoryReceiptId = @InventoryReceiptId		

	IF(@ysnTicketHasSpecialDiscount = 1 AND @strInOutFlag = 'I')
	BEGIN
		DELETE FROM tblSCInventoryReceiptAllowVoucherTracker
		WHERE intInventoryReceiptId = @InventoryReceiptId


		-- snapshot the ysnAllowvoucher before updating it all to zero. Will be used during posting of special grades 
		-- will be deleted upon undistribution of ticket
		BEGIN
			--ITEM
			INSERT INTO tblSCInventoryReceiptAllowVoucherTracker(
				intInventoryReceiptId
				,intInventoryReceiptItemId
				,ysnAllowVoucher
			)
			SELECT 
				intInventoryReceiptId
				,intInventoryReceiptItemId
				,ysnAllowVoucher
			FROM tblICInventoryReceiptItem
			WHERE intInventoryReceiptId = @InventoryReceiptId

			--CHARGES
			INSERT INTO tblSCInventoryReceiptAllowVoucherTracker(
				intInventoryReceiptId
				,intInventoryReceiptChargeId
				,ysnAllowVoucher
			)
			SELECT 
				intInventoryReceiptId
				,intInventoryReceiptChargeId
				,ysnAllowVoucher
			FROM tblICInventoryReceiptCharge
			WHERE intInventoryReceiptId = @InventoryReceiptId
		END

		--Update all ysn allowvoucher to zero for all receipt item and charges
		BEGIN
			UPDATE tblICInventoryReceiptItem SET ysnAllowVoucher = 0 WHERE intInventoryReceiptId = @InventoryReceiptId
			UPDATE tblICInventoryReceiptCharge SET ysnAllowVoucher = 0 WHERE intInventoryReceiptId = @InventoryReceiptId
		END
	END

	EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intUserId;
		
	UPDATE	SC
	SET		SC.intLotId = ICLot.intLotId, SC.strLotNumber = ICLot.strLotNumber
	FROM	dbo.tblSCTicket SC 
	INNER JOIN tblICInventoryReceiptItem IRI ON SC.intTicketId = IRI.intSourceId
	INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND intSourceType = 1
	INNER JOIN tblICInventoryReceiptItemLot ICLot ON ICLot.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	WHERE SC.intTicketId = @intTicketId

	
	SELECT @intLotType = dbo.fnGetItemLotType(@intItemId)
	IF @intLotType != 0
	BEGIN
		DECLARE @QualityPropertyValueTable AS QualityPropertyValueTable;
		INSERT INTO @QualityPropertyValueTable(
			strPropertyName
			,strPropertyValue
			,strComment
		)
		SELECT 
			strPropertyName = IC.strShortName
			,strPropertyValue = QM.dblGradeReading
			,strComment = QM.strShrinkWhat 
		FROM tblQMTicketDiscount QM 
		INNER JOIN tblGRDiscountScheduleCode GR ON GR.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
		INNER JOIN tblICItem IC ON IC.intItemId = GR.intItemId
		WHERE QM.intTicketId = @intTicketId AND QM.strSourceType = 'Scale'

		DECLARE lotCursor CURSOR LOCAL FAST_FORWARD
		FOR
		SELECT ICLot.intLotId FROM dbo.tblSCTicket SC 
		INNER JOIN tblICInventoryReceiptItem IRI ON SC.intTicketId = IRI.intSourceId
		INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND intSourceType = 1
		INNER JOIN tblICInventoryReceiptItemLot ICLot ON ICLot.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
		WHERE SC.intTicketId = @intTicketId

		OPEN lotCursor;

		-- Initial fetch attempt
		FETCH NEXT FROM lotCursor INTO @intLotId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF    ISNULL(@intLotId,0) != 0
			EXEC dbo.uspQMSampleCreateForScaleTicket @intItemId,'Inbound Scale Sample', @intLotId, @intUserId, @QualityPropertyValueTable
			FETCH NEXT FROM lotCursor INTO @intLotId;
		END

		CLOSE lotCursor;
		DEALLOCATE lotCursor;
	END		

	IF(@ysnTicketHasSpecialDiscount <> 1 OR (@ysnTicketSpecialGradePosted = 1 AND @ysnTicketHasSpecialDiscount = 1))
	BEGIN
		EXEC uspSCProcessReceiptToVoucher @intTicketId, @InventoryReceiptId	,@intUserId, @intBillId OUTPUT
	END

	EXEC dbo.uspSMAuditLog 
			@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
			,@screenName		= 'Grain.view.Scale'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Updated'					-- Action Type
			,@changeDescription	= 'Inventory Receipt'		-- Description
			,@fromValue			= ''						-- Old Value
			,@toValue			= @strTransactionId			-- New Value
			,@details			= '';

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
