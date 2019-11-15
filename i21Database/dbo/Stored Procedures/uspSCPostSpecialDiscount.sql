CREATE PROCEDURE [dbo].uspSCPostSpecialDiscount
    @intTicketId INT
	,@intUserId INT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

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

BEGIN TRANSACTION
	BEGIN TRY
		SELECT TOP 1
			@ysnSpecialGradePosted = ysnSpecialGradePosted
			,@splitDistribution = strDistributionOption
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
			UNIQUE ([intInventoryReceiptId])
		);
	
		INSERT INTO #tmpItemReceiptIds(
			intInventoryReceiptId
			,strReceiptNumber
			,ysnPosted) 
		SELECT DISTINCT(
			intInventoryReceiptId)
			,strReceiptNumber
			,ysnPosted 
		FROM vyuICGetInventoryReceiptItem 
		WHERE intSourceId = @intTicketId AND strSourceType = 'Scale'
		ORDER BY intInventoryReceiptId ASC

		SELECT TOP 1 
			@intInventoryReceiptId =  intInventoryReceiptId 
			,@strTransactionId = strReceiptNumber
		FROM #tmpItemReceiptIds  
	

		WHILE @intInventoryReceiptId IS NOT NULL
		BEGIN
			SET @ysnIRPosted = 0
			SET @intLoopInventoryReceiptId = @intInventoryReceiptId
			SET @intInventoryReceiptId = NULL

			SELECT 
				@ysnIRPosted = ysnPosted
			FROM tblICInventoryReceipt
			WHERE intInventoryReceiptId = @intLoopInventoryReceiptId

			IF(@ysnIRPosted = 1)
			BEGIN
				--unpost the IR
				EXEC [dbo].[uspICPostInventoryReceipt] 0, 0, @strTransactionId, @intUserId
			END

			--update IR special discount charges amount
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

				UPDATE tblICInventoryReceiptCharge
				SET dblAmount = A.dblAmount
				FROM #tmpItemReceiptChargeIds A
				WHERE tblICInventoryReceiptCharge.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
			END

			--Update the ysnAllowVoucher Of receiptItem
			BEGIN
				UPDATE tblICInventoryReceiptItem
				SET ysnAllowVoucher = A.ysnAllowVoucher
				FROM tblSCInventoryReceiptAllowVoucherTracker A
				WHERE tblICInventoryReceiptItem.intInventoryReceiptItemId = A.intInventoryReceiptItemId
			END

			--Update the ysnAllowVoucher Of receiptCharges
			BEGIN
				UPDATE tblICInventoryReceiptCharge
				SET ysnAllowVoucher = A.ysnAllowVoucher
				FROM tblSCInventoryReceiptAllowVoucherTracker A
				WHERE tblICInventoryReceiptCharge.intInventoryReceiptChargeId = A.intInventoryReceiptChargeId
			END

			--Update charges total
			BEGIN
				SELECT TOP 1 
					@intLoopInventoryReceiptChargeId = intInventoryReceiptChargeId
					,@_intLoopInventoryReceiptChargeId = intInventoryReceiptChargeId
				FROM #tmpItemReceiptChargeIds

				WHILE @intLoopInventoryReceiptChargeId IS NOT NULL
				BEGIN
					SET @intLoopInventoryReceiptChargeId = NULL
				
					EXEC uspICUpdateReceiptCharge @intInventoryReceiptChargeId = 1234

					SELECT TOP 1 
						@intLoopInventoryReceiptChargeId = intInventoryReceiptChargeId
						,@_intLoopInventoryReceiptChargeId = intInventoryReceiptChargeId
					FROM #tmpItemReceiptChargeIds 
					WHERE intInventoryReceiptChargeId > @_intLoopInventoryReceiptChargeId

				END
			END

			EXEC [dbo].[uspICPostInventoryReceipt] 1, 0, @strTransactionId, @intUserId

			SELECT TOP 1 
				@intInventoryReceiptId =  intInventoryReceiptId 
				,@strTransactionId = strReceiptNumber
			FROM #tmpItemReceiptIds
			WHERE intInventoryReceiptId > @intLoopInventoryReceiptId  
		END

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
			ROLLBACK TRANSACTION; 
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		);
	END CATCH

IF @@TRANCOUNT > 0  
    COMMIT TRANSACTION; 


END
