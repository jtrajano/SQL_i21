CREATE PROCEDURE [dbo].uspSCProcessReceiptToVoucher
    @intTicketId INT
	,@intInventoryReceiptId INT
	,@intUserId INT
	,@intBillId AS INT OUTPUT
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

	DECLARE @intContractDetailId INT
	DECLARE @intIRContractPricingType INT
	DECLARE @intLotType INT
	DECLARE @intItemId INT
	DECLARE @intLotId INT
	DECLARE @total INT
	DECLARE @createVoucher BIT
	DECLARE @postVoucher BIT
	DECLARE @intEntityId INT
	DECLARE @prePayId AS Id
	DECLARE @dblTotal AS DECIMAL(18,6) 
	DECLARE @requireApproval AS BIT
	DECLARE @success AS INT
	DECLARE @intLocationId AS INT
	DECLARE @ysnHasBasisContract INT = 0
	DECLARE @_intLoopContractDetailId INT = 0

	
	BEGIN TRY
		BEGIN
			SELECT TOP 1 
				@intItemId = ST.intItemId
				, @intLocationId = ST.intProcessingLocationId
			FROM dbo.tblSCTicket ST
			WHERE ST.intTicketId = @intTicketId

			SELECT @intContractDetailId = MIN(ri.intLineNo)
					,@intIRContractPricingType = MIN(CD.intPricingTypeId)
			FROM tblICInventoryReceipt r 
			JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
			LEFT JOIN tblCTContractDetail CD 
				ON ri.intContractDetailId = CD.intContractDetailId
			WHERE ri.intInventoryReceiptId = @intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'

			/*--Contract Partial Pricing

			WHILE ISNULL(@intContractDetailId,0) > 0 AND @intIRContractPricingType = 2
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
				BEGIN
					EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId
				END

				SELECT @intContractDetailId = MIN(ri.intLineNo)
						,@intIRContractPricingType = MIN(CD.intPricingTypeId)
				FROM tblICInventoryReceipt r 
				JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
				LEFT JOIN tblCTContractDetail CD 
					ON ri.intContractDetailId = CD.intContractDetailId
				WHERE ri.intInventoryReceiptId = @intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract' AND ri.intLineNo > @intContractDetailId

				select @intBillId = intBillId from tblAPBillDetail where intInventoryReceiptItemId in (
					select ri.intInventoryReceiptItemId
					FROM tblICInventoryReceipt r 
						JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId					
							WHERE ri.intInventoryReceiptId = @intInventoryReceiptId 
				) and intInventoryReceiptChargeId is null
			
			END

				

			-- VOUCHER INTEGRATION

			SELECT @total = COUNT(1)
					FROM	tblICInventoryReceiptItem ri
					WHERE	ri.intInventoryReceiptId = intInventoryReceiptId
							AND ri.intOwnershipType = 1
							AND ISNULL(ri.ysnAllowVoucher,1) = 1

			DECLARE @ysnHasBasisContract INT = 0
			SELECT @ysnHasBasisContract = CASE WHEN COUNT(DISTINCT intPricingTypeId) > 0 THEN 1 ELSE 0 END FROM tblICInventoryReceiptItem IRI
			INNER JOIN tblCTContractDetail CT
				ON CT.intContractDetailId = IRI.intContractDetailId
			WHERE intInventoryReceiptId = @intInventoryReceiptId and CT.intPricingTypeId = 2
			GROUP BY intInventoryReceiptId
			IF(@ysnHasBasisContract = 1)
			BEGIN
				SELECT @intContractDetailId = MIN(ri.intLineNo)
				FROM tblICInventoryReceipt r 
				JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
				WHERE ri.intInventoryReceiptId = @intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract' 
			
				WHILE ISNULL(@intContractDetailId,0) > 0
				BEGIN
					IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
					BEGIN
						EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId, @intUserId
					END
					SELECT @intContractDetailId = MIN(ri.intLineNo)
					FROM tblICInventoryReceipt r 
					JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId					
					WHERE ri.intInventoryReceiptId = @intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract' AND ri.intLineNo > @intContractDetailId
					
					
					select @intBillId = intBillId from tblAPBillDetail where intInventoryReceiptItemId in (
						select ri.intInventoryReceiptItemId
						FROM tblICInventoryReceipt r 
							JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId					
								WHERE ri.intInventoryReceiptId = @intInventoryReceiptId 
					) and intInventoryReceiptChargeId is null
				END
			END*/
			
			SELECT @intEntityId =intEntityVendorId
			FROM tblICInventoryReceipt
			WHERE intInventoryReceiptId = @intInventoryReceiptId

			SELECT @createVoucher = ysnCreateVoucher, @postVoucher = ysnPostVoucher FROM tblAPVendor WHERE intEntityId = @intEntityId
			IF ISNULL(@createVoucher, 0) = 1 OR ISNULL(@postVoucher, 0) = 1
			BEGIN
			
			
				IF EXISTS(SELECT TOP 1 1 FROM tblICInventoryReceiptItem WHERE ysnAllowVoucher = 1) 
				BEGIN
					EXEC dbo.uspICProcessToBill @intReceiptId = @intInventoryReceiptId, @intUserId = @intUserId, @intBillId = @intBillId OUT
				END

				
				--Basis/Partial Pricing
				
				SELECT 
					@ysnHasBasisContract = CASE WHEN COUNT(DISTINCT intPricingTypeId) > 0 THEN 1 ELSE 0 END 
					,@intContractDetailId = MIN(IRI.intContractDetailId)
				FROM tblICInventoryReceiptItem IRI
				INNER JOIN tblCTContractDetail CT
					ON CT.intContractDetailId = IRI.intContractDetailId
				WHERE intInventoryReceiptId = @intInventoryReceiptId and CT.intPricingTypeId = 2
				GROUP BY intInventoryReceiptId,IRI.intContractDetailId

				IF(@ysnHasBasisContract = 1)
				BEGIN
					SET @_intLoopContractDetailId =  @intContractDetailId
					WHILE ISNULL(@intContractDetailId,0) > 0 
					BEGIN
						IF EXISTS(SELECT TOP 1 1 FROM tblCTPriceFixation WHERE intContractDetailId = @intContractDetailId)
						BEGIN
							EXEC uspCTCreateVoucherInvoiceForPartialPricing @intContractDetailId = @intContractDetailId, @intUserId = @intUserId, @intTransactionId = @intBillId
						END

						SET @intContractDetailId = NULL
						SELECT @intContractDetailId = MIN(ri.intContractDetailId)
								,@intIRContractPricingType = MIN(CD.intPricingTypeId)
								,@_intLoopContractDetailId = MIN(ri.intContractDetailId)
						FROM tblICInventoryReceipt r 
						JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
						LEFT JOIN tblCTContractDetail CD 
							ON ri.intContractDetailId = CD.intContractDetailId
						WHERE ri.intInventoryReceiptId = @intInventoryReceiptId 
							AND r.strReceiptType = 'Purchase Contract' 
							AND ri.intContractDetailId > @_intLoopContractDetailId

						-- select @intBillId = intBillId from tblAPBillDetail where intInventoryReceiptItemId in (
						-- 	select ri.intInventoryReceiptItemId
						-- 	FROM tblICInventoryReceipt r 
						-- 		JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId					
						-- 			WHERE ri.intInventoryReceiptId = @intInventoryReceiptId 
						-- ) and intInventoryReceiptChargeId is null
					
					END
				END
				
				IF ISNULL(@intBillId , 0) != 0 AND ISNULL(@postVoucher, 0) = 1
				BEGIN

					--Add contract prepayment to voucher
					BEGIN
						IF OBJECT_ID (N'tempdb.dbo.#tmpContractPrepay') IS NOT NULL
							DROP TABLE #tmpContractPrepay

						CREATE TABLE #tmpContractPrepay (
							[intPrepayId] INT
						);
						DECLARE @Ids as Id
				
						INSERT INTO @Ids(intId)
						SELECT DISTINCT
							CT.intContractDetailId 
						FROM tblICInventoryReceiptItem A 
						INNER JOIN tblCTContractDetail CT 
							ON CT.intContractDetailId = A.intContractDetailId
						WHERE A.dblUnitCost > 0
							AND A.intInventoryReceiptId = @intInventoryReceiptId

						INSERT INTO #tmpContractPrepay(
							[intPrepayId]
						) 
						SELECT intTransactionId FROM dbo.fnSCGetPrepaidIds(@Ids)
				
						SELECT @total = COUNT(intPrepayId) FROM #tmpContractPrepay where intPrepayId > 0;
						IF (@total > 0)
						BEGIN
							INSERT INTO @prePayId(
								[intId]
							)
							SELECT [intId] = intPrepayId
							FROM #tmpContractPrepay where intPrepayId > 0
					
							EXEC uspAPApplyPrepaid @intBillId, @prePayId
							update tblAPBillDetail set intScaleTicketId = @intTicketId WHERE intBillId = @intBillId
						END
					END

					SELECT @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @intBillId

					EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
					@type = N'AccountsPayable.view.Voucher',
					@transactionEntityId = @intEntityId,
					@currentUserEntityId = @intUserId,
					@locationId = @intLocationId,
					@amount = @dblTotal,
					@requireApproval = @requireApproval OUTPUT

					IF ISNULL(@dblTotal,0) > 0 AND ISNULL(@requireApproval , 0) = 0
					BEGIN
						EXEC [dbo].[uspAPPostBill]
						@post = 1
						,@recap = 0
						,@isBatch = 0
						,@param = @intBillId
						,@userId = @intUserId
						,@success = @success OUTPUT
					END
				END

			
			END




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
		RAISERROR (
			@ErrorMessage, -- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState -- State.
		);
	END CATCH
END
