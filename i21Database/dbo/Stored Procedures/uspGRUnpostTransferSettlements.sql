CREATE PROCEDURE [dbo].[uspGRUnpostTransferSettlements]
(
	 @intTransferSettlementHeaderId INT
	 ,@intUserId INT

)
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF	

	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @billList AS Id
	DECLARE @BillIdParams NVARCHAR(max)
	DECLARE @success BIT
	DECLARE @BillId INT

	INSERT INTO @billList
	SELECT DISTINCT intBillToId --DM
	FROM tblGRTransferSettlementReference
	WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId
	UNION ALL
	SELECT DISTINCT intTransferToBillId --BL
	FROM tblGRTransferSettlementReference
	WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId	

	BEGIN TRY
		--1. Unpost the voucher
		SELECT @BillIdParams = STUFF(
		(
			SELECT ',' + CAST(intId AS NVARCHAR)
			FROM @billList B
			INNER JOIN tblAPBill AP
				ON AP.intBillId = B.intId
					AND AP.ysnPosted = 1 --include only the posted vouchers
			FOR XML PATH('')
		),1,1,'')

		IF @BillIdParams IS NOT NULL
		BEGIN
			EXEC uspAPPostBill 
				@post = 0
				,@recap = 0
				,@isBatch = 0
				,@param = @BillIdParams
				,@transactionType = NULL
				,@userId = @intUserId
				,@success = @success OUTPUT

			SELECT TOP 1 @ErrMsg = strMessage 
			FROM tblAPPostResult 
			WHERE intTransactionId IN (SELECT * FROM [dbo].fnGetRowsFromDelimitedValues(@BillIdParams))
				AND strMessage NOT IN ('Transaction successfully posted.','Transaction successfully unposted.');

			IF ISNULL(@ErrMsg,'') <> ''
			BEGIN
				RAISERROR (@ErrMsg, 16, 1);
				GOTO DONE;
			END
		END

		--Book AP clearing for reversal
		BEGIN		
			DECLARE @APClearing AS APClearing;
			DELETE FROM @APClearing
			INSERT INTO @APClearing
			(
				[intTransactionId],
				[strTransactionId],
				[intTransactionType],
				[strReferenceNumber],
				[dtmDate],
				[intEntityVendorId],
				[intLocationId],
				--DETAIL
				[intTransactionDetailId],
				[intAccountId],
				[intItemId],
				[intItemUOMId],
				[dblQuantity],
				[dblAmount],
				--OTHER INFORMATION
				[strCode]
			)
			SELECT
				-- HEADER
				[intTransactionId]
				,[strTransactionId]
				,[intTransactionType]
				,[strReferenceNumber]
				,[dtmDate]
				,[intEntityVendorId]
				,[intLocationId]
				-- DETAIL
				,[intTransactionDetailId]
				,[intAccountId]
				,[intItemId]
				,[intItemUOMId]
				,[dblQuantity]
				,[dblAmount]
				,[strCode]
			FROM tblAPClearing
			WHERE intTransactionId = @intTransferSettlementHeaderId
				AND intTransactionType = 6 --Grain
				AND intOffsetId IS NULL

			--SELECT '@APClearing',* FROM @APClearing
			EXEC uspAPClearing @APClearing = @APClearing, @post = 0;
		END

		--DELETE VOUCHER
		WHILE EXISTS(SELECT 1 FROM @billList)
		BEGIN
			SELECT @BillId = intId FROM @billList

			EXEC uspAPDeleteVoucher 
				@BillId
				,@intUserId
				,@callerModule = 1					

			DELETE FROM @billList WHERE intId = @BillId
		END

		--DELETE TRANSFER SETTLEMENTS
		DELETE FROM tblGRTransferSettlementsHeader WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId

		--unpost AP CLEARING

		DONE:

	END TRY
	BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	END CATCH
	
END