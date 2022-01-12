CREATE PROCEDURE [dbo].uspSCPostSpecialDiscount
    @intTicketId INT
	,@intUserId INT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS ON

	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;

	DECLARE @ysnSpecialGradePosted BIT
	DECLARE @intInventoryReceiptId INT
	DECLARE @intLoopInventoryReceiptId INT
	DECLARE @strTransactionId NVARCHAR(40) = NULL
	DECLARE @ysnIRPosted BIT
	DECLARE @splitDistribution NVARCHAR(3)
	DECLARE @intLoopInventoryReceiptChargeId INT
	DECLARE @_intLoopInventoryReceiptChargeId INT
	DECLARE @dblChargeAmount NUMERIC(18,6)
	DECLARE @ysnTicketSpecialGradePosted BIT
	DECLARE @ysnTicketHasSpecialDiscount BIT
	DECLARE @intBillId INT
	DECLARE @ysnLoadContract BIT
	DECLARE @intTicketContractDetailId INT
	DECLARE @dblTicketScheduledQty NUMERIC(18,6)
	DECLARE @intTicketItemUOMId INT
	DECLARE @dblQuantityToReceive NUMERIC(38,15)

BEGIN 
	DECLARE @TransactionName AS VARCHAR(500) = 'uspSCProcessReceiptToVoucher_' + CAST(NEWID() AS NVARCHAR(100));
	BEGIN TRAN @TransactionName
	SAVE TRAN @TransactionName
END

	BEGIN TRY
		SELECT TOP 1
			@ysnSpecialGradePosted = ysnSpecialGradePosted
			,@splitDistribution = strDistributionOption
			,@ysnTicketHasSpecialDiscount = ysnHasSpecialDiscount
			,@ysnTicketSpecialGradePosted = ysnSpecialGradePosted
			,@intTicketContractDetailId = intContractId
			,@dblTicketScheduledQty = dblScheduleQty
			,@intTicketItemUOMId = intItemUOMIdTo
		FROM tblSCTicket
		WHERE intTicketId = @intTicketId


		CREATE TABLE #tmpItemReceiptChargeIds (
			[intInventoryReceiptChargeId] [INT] PRIMARY KEY,
			[dblAmount] NUMERIC(18,6),
			UNIQUE ([intInventoryReceiptChargeId])
		);


		--Get all receipt for the ticket
		CREATE TABLE #tmpItemReceiptIds (
			[intInventoryReceiptId] [INT] PRIMARY KEY,
			[strReceiptNumber] [VARCHAR](100),
			[ysnPosted] [BIT],
			[dblQty] NUMERIC(38,15)
			UNIQUE ([intInventoryReceiptId])
		);
	
		INSERT INTO #tmpItemReceiptIds(
			intInventoryReceiptId
			,strReceiptNumber
			,ysnPosted
			,dblQty)
		SELECT DISTINCT(
			intInventoryReceiptId)
			,strReceiptNumber
			,ysnPosted
			,[dblQty] = dblQtyToReceive
		FROM vyuICGetInventoryReceiptItem 
		WHERE intSourceId = @intTicketId AND strSourceType = 'Scale'
		ORDER BY intInventoryReceiptId ASC


		SET @ysnIRPosted = 0
		SET @intLoopInventoryReceiptId = NULL
		SET @intInventoryReceiptId = NULL
		SET @dblQuantityToReceive = 0

		SELECT TOP 1
			@intInventoryReceiptId =  intInventoryReceiptId 
			,@strTransactionId = strReceiptNumber
			,@ysnIRPosted = ysnPosted
			,@dblQuantityToReceive = dblQty
			,@intLoopInventoryReceiptId = intInventoryReceiptId
		FROM #tmpItemReceiptIds

		WHILE @intInventoryReceiptId IS NOT NULL
		BEGIN

			SET @intLoopInventoryReceiptId = @intInventoryReceiptId

			IF(@ysnIRPosted = 1)
			BEGIN
				--unpost the IR
				EXEC [dbo].[uspICPostInventoryReceipt] 0, 0, @strTransactionId, @intUserId

				IF ISNULL(@intTicketContractDetailId,0) > 0
				BEGIN
					---- Update contract schedule based on ticket schedule qty
					IF ISNULL(@intTicketContractDetailId, 0) > 0 AND (@splitDistribution = 'CNT' OR @splitDistribution = 'LOD')
					BEGIN
						-- For Review
						SET @ysnLoadContract = 0
						SELECT TOP 1
							@ysnLoadContract = A.ysnLoad
						FROM tblCTContractHeader A
						INNER JOIN tblCTContractDetail B
							ON A.intContractHeaderId = B.intContractHeaderId
						WHERE B.intContractDetailId = @intTicketContractDetailId

						IF(ISNULL(@ysnLoadContract,0) = 0)
						BEGIN
							EXEC uspCTUpdateScheduleQuantityUsingUOM @intTicketContractDetailId, @dblQuantityToReceive, @intUserId, @intTicketId, 'Scale', @intTicketItemUOMId
						END
					END
				END
			END

			--GEt/generate charges amount
			BEGIN
				DELETE FROM #tmpItemReceiptChargeIds
			 
				INSERT INTO #tmpItemReceiptChargeIds(
					intInventoryReceiptChargeId
					,dblAmount
				)
				SELECT
				IRC.intInventoryReceiptChargeId 
				,dblAmount =  CASE
										WHEN IC.strCostMethod = 'Per Unit' THEN 0
										WHEN IC.strCostMethod = 'Amount' THEN 
										CASE 
											WHEN IRI.intOwnershipType = 0 THEN 0
											WHEN IRI.intOwnershipType = 1 THEN
											CASE
												WHEN QM.dblDiscountAmount < 0 THEN 
												CASE
													WHEN @splitDistribution = 'SPL' THEN (dbo.fnSCCalculateDiscountSplit(IRI.intSourceId, IR.intEntityVendorId, QM.intTicketDiscountId, IRI.dblOpenReceive, GR.intUnitMeasureId, IRI.dblUnitCost, 0) * -1)
													ELSE (dbo.fnSCCalculateDiscount(IRI.intSourceId,QM.intTicketDiscountId, IRI.dblOpenReceive, GR.intUnitMeasureId, IRI.dblUnitCost) * -1)
												END 
												WHEN QM.dblDiscountAmount > 0 THEN 
												CASE
													WHEN @splitDistribution = 'SPL' THEN dbo.fnSCCalculateDiscountSplit(IRI.intSourceId, IR.intEntityVendorId, QM.intTicketDiscountId, IRI.dblOpenReceive, GR.intUnitMeasureId, IRI.dblUnitCost, 0)
													ELSE dbo.fnSCCalculateDiscount(IRI.intSourceId, QM.intTicketDiscountId, IRI.dblOpenReceive, GR.intUnitMeasureId, IRI.dblUnitCost)
												END 
											END
										END
									END
			
				FROM tblICInventoryReceiptCharge IRC
				INNER JOIN tblICInventoryReceipt IR
					ON IRC.intInventoryReceiptId = IR.intInventoryReceiptId
				INNER JOIN tblICInventoryReceiptItem IRI
					ON ISNULL(IRI.intContractHeaderId,0) = ISNULL(IRC.intContractId,0)
						AND ISNULL(IRI.intContractDetailId,0) = ISNULL(IRC.intContractDetailId,0)
						AND ISNULL(IRI.strChargesLink,'') = ISNULL(IRC.strChargesLink,'')
						AND ISNULL(IRI.intInventoryReceiptId,'') = ISNULL(IR.intInventoryReceiptId,'')
				INNER JOIN tblICItem IC 
					ON IC.intItemId = IRC.intChargeId
				INNER JOIN tblGRDiscountScheduleCode GR 
					ON IC.intItemId = GR.intItemId
				INNER JOIN tblQMTicketDiscount QM
					ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
				LEFT JOIN tblICItemUOM UM 
					ON UM.intItemId = GR.intItemId 
						AND UM.intUnitMeasureId = GR.intUnitMeasureId
				WHERE IRI.intSourceId = @intTicketId
					AND QM.intTicketId = @intTicketId
					AND IR.intSourceType = 1
					AND QM.strSourceType = 'Scale'
					AND GR.ysnSpecialDiscountCode = 1
				ORDER BY IRC.intInventoryReceiptChargeId ASC

				--Updating of charge amount will be on uspICUpdateReceiptCharge
				----UPDATE tblICInventoryReceiptCharge
				----SET dblAmount = A.dblAmount
				----FROM #tmpItemReceiptChargeIds A
				----WHERE tblICInventoryReceiptCharge.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
			END

			--Update the ysnAllowVoucher Of receiptItem
			BEGIN
				UPDATE tblICInventoryReceiptItem
				SET ysnAllowVoucher = A.ysnAllowVoucher
				FROM tblSCInventoryReceiptAllowVoucherTracker A
				WHERE tblICInventoryReceiptItem.intInventoryReceiptItemId = A.intInventoryReceiptItemId AND A.intInventoryReceiptId = @intLoopInventoryReceiptId
			END

			--Update the ysnAllowVoucher Of receiptCharges
			BEGIN
				UPDATE tblICInventoryReceiptCharge
				SET ysnAllowVoucher = A.ysnAllowVoucher
				FROM tblSCInventoryReceiptAllowVoucherTracker A
				WHERE tblICInventoryReceiptCharge.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId AND A.intInventoryReceiptId = @intLoopInventoryReceiptId
			END

			--Update IR charges 
			BEGIN
				SET @dblChargeAmount = NULL
				SET @intLoopInventoryReceiptChargeId = NULL
				SET @_intLoopInventoryReceiptChargeId = NULL

				SELECT TOP 1 
					@intLoopInventoryReceiptChargeId = intInventoryReceiptChargeId
					,@_intLoopInventoryReceiptChargeId = intInventoryReceiptChargeId
					,@dblChargeAmount = ISNULL(dblAmount,0)
				FROM #tmpItemReceiptChargeIds

				WHILE @intLoopInventoryReceiptChargeId IS NOT NULL
				BEGIN
					SET @intLoopInventoryReceiptChargeId = NULL
				
					EXEC uspICUpdateReceiptCharge 
						NULL
						, NULL
						, @dblChargeAmount
						, NULL
						, NULL
						, @intInventoryReceiptChargeId = @_intLoopInventoryReceiptChargeId


					SELECT TOP 1 
						@intLoopInventoryReceiptChargeId = intInventoryReceiptChargeId
						,@_intLoopInventoryReceiptChargeId = intInventoryReceiptChargeId
						,@dblChargeAmount = dblAmount
					FROM #tmpItemReceiptChargeIds 
					WHERE intInventoryReceiptChargeId > @_intLoopInventoryReceiptChargeId

				END
			END



			EXEC [dbo].[uspICPostInventoryReceipt] 1, 0, @strTransactionId, @intUserId

			IF(@ysnTicketHasSpecialDiscount <> 1 OR (@ysnTicketSpecialGradePosted = 1 AND @ysnTicketHasSpecialDiscount = 1))
			BEGIN
				EXEC uspSCProcessReceiptToVoucher @intTicketId, @intLoopInventoryReceiptId	,@intUserId, @intBillId OUTPUT
			END

			SET @ysnIRPosted = 0
			SET @intInventoryReceiptId = NULL
			SET @dblQuantityToReceive = 0

			SELECT TOP 1
				@intInventoryReceiptId =  intInventoryReceiptId 
				,@strTransactionId = strReceiptNumber
				,@ysnIRPosted = ysnPosted
				,@dblQuantityToReceive = dblQty
			FROM #tmpItemReceiptIds
			WHERE intInventoryReceiptId > @intLoopInventoryReceiptId  
		END

		IF @@TRANCOUNT > 0  
    		COMMIT TRANSACTION @TransactionName; 

	END TRY
	BEGIN CATCH
		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		IF @@TRANCOUNT > 0 
		BEGIN
			ROLLBACK TRANSACTION @TransactionName; 
			COMMIT TRAN @TransactionName
		END

		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		);
	END CATCH



END
