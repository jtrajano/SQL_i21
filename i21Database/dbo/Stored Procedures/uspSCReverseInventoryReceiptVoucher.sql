CREATE PROCEDURE [dbo].[uspSCReverseInventoryReceiptVoucher]
	@intTicketId INT,
	@intUserId INT,
	@intInventoryReceiptId INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@jsonData NVARCHAR(MAX);

DECLARE @intTicketStorageScheduleTypeId INT
dECLARE @intMatchTicketId INT
DECLARE @intMatchLoadDetailId INT
DECLARE @dblQtyUpdate NUMERIC(18,6)
DECLARE @dblTicketNetUnits NUMERIC(18,6)
DECLARE @intTicketContractDetailId INT
DECLARE @intTicketType INT
DECLARE @_intBillId INT
DECLARE @ysnPost BIT
DECLARE @intReversedBillId INT
DECLARE @strDebitMemoNumber NVARCHAR(MAX)

BEGIN TRY

	-- print 'voucher reversal'

	IF OBJECT_ID (N'tempdb.dbo.#tmpSCVoucherDetail') IS NOT NULL DROP TABLE #tmpSCVoucherDetail
	CREATE TABLE #tmpSCVoucherDetail(
		intBillId INT
		,intBillDetailId INT
		,ysnPosted BIT
	)
	
	--Get Ticket Details
	SELECT TOP 1
		@intTicketStorageScheduleTypeId = intStorageScheduleTypeId
		,@intMatchTicketId = intMatchTicketId
		,@intTicketContractDetailId = intContractId
		,@dblTicketNetUnits = dblNetUnits
	FROM tblSCTicket
	WHERE intTicketId = @intTicketId

	--Populate voucher table list
	IF(ISNULL(@intInventoryReceiptId,0) > 0)
	BEGIN
		-- print 'has IR'
		INSERT INTO #tmpSCVoucherDetail(
			ysnPosted
			,intBillId
			,intBillDetailId
		)
		SELECT 
			A.ysnPosted
			,B.intBillId
			,B.intBillDetailId
		FROM tblAPBillDetail B
		INNER JOIN tblAPBill A
			ON A.intBillId = B.intBillId
		INNER JOIN tblICInventoryReceiptItem C
			ON B.intInventoryReceiptItemId = C.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt D
			ON C.intInventoryReceiptId = D.intInventoryReceiptId
		WHERE C.intSourceId = @intTicketId
			AND D.intSourceType = 1
			AND D.intInventoryReceiptId = @intInventoryReceiptId
			AND ISNULL(A.intTransactionReversed ,0) = 0
			AND A.intTransactionType = 1
	END
	ELSE
	BEGIN
		-- print 'direct voucher'
		-- get the invoice detail for the ticket 
		INSERT INTO #tmpSCVoucherDetail(
			ysnPosted
			,intBillId
			,intBillDetailId
		)
		SELECT 
			A.ysnPosted
			,B.intBillId
			,B.intBillDetailId
		FROM tblAPBillDetail B
		INNER JOIN tblAPBill A
			ON B.intBillDetailId = B.intBillDetailId
		WHERE B.intScaleTicketId = @intTicketId
			AND ISNULL(A.intTransactionReversed ,0) = 0
	END


	
	--reversal entry for voucher
	SELECT TOP 1 
		@_intBillId = MIN (intBillId) 
		,@ysnPost = ysnPosted
	FROM #tmpSCVoucherDetail
	GROUP BY intBillId,ysnPosted

	
	WHILE (ISNULL(@_intBillId,0) > 0)
	BEGIN
		IF(ISNULL(@ysnPost,0) = 0)
		BEGIN
			DELETE FROM tblCTPriceFixationDetailAPAR WHERE intBillId = @_intBillId
			EXEC [dbo].[uspAPDeleteVoucher] @_intBillId, @intUserId, 2
		END
		ELSE
		BEGIN
			---create voucher reversal for posted voucher
			EXEC uspAPReverseTransaction 
				@billId = @_intBillId
				,@userId = @intUserId
				,@billCreatedId = @intReversedBillId OUTPUT


			-- Audit log Entry
			IF(ISNULL(@intReversedBillId,0) > 0)
			BEGIN
				SELECT TOP 1
					@strDebitMemoNumber = strBillId
				FROM tblAPBill
				WHERE intBillId = @intReversedBillId

				EXEC dbo.uspSMAuditLog 
					@keyValue			= @intTicketId				-- Primary Key Value of the Ticket. 
					,@screenName		= 'Grain.view.Scale'				-- Screen Namespace
					,@entityId			= @intUserId						-- Entity Id.
					,@actionType		= 'Updated'							-- Action Type
					,@changeDescription	= 'Debit Memo' 				-- Description
					,@fromValue			= ''								-- Old Value
					,@toValue			= @strDebitMemoNumber								-- New Value
					,@details			= '';
			END
		END

		--Loop Iterator
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM #tmpSCVoucherDetail WHERE intBillId > @_intBillId)
			BEGIN
				SELECT TOP 1 
					@_intBillId = MIN (intBillId) 
					,@ysnPost = ysnPosted
				FROM #tmpSCVoucherDetail
				WHERE intBillId > @_intBillId
				GROUP BY intBillId,ysnPosted
			END
			ELSE
			BEGIN
				SET @_intBillId = 0
			END
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


