CREATE PROCEDURE [dbo].[uspGRProcessTransferSettlements]
(
	 @intTransferSettlementHeaderId INT	 
)
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF	

	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @dblTransferUnits NUMERIC(18,6)
	DECLARE @dblTransferAmount NUMERIC(18,6)	
	DECLARE @TransferFromSettlements AS TransferFromSettlementStagingTable
	DECLARE @TransferToSettlements AS TransferToSettlementStagingTable
	DECLARE @intUserId INT

	INSERT INTO @TransferFromSettlements
	SELECT intTransferFromSettlementId
		,intTransferSettlementHeaderId
		,intBillId
		,intBillDetailId
		,dblSettlementAmountTransferred
		,intCurrencyId
		,dblUnits
		,intAccountId
	FROM tblGRTransferFromSettlements
	WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId
	
	INSERT INTO @TransferToSettlements
	SELECT intTransferToSettlementId
		,intTransferSettlementHeaderId
		,intEntityId
		,dblTotalTransferPercent
		,dblTotalSettlementAmount
		,dblTotalUnits
	FROM tblGRTransferToSettlements
	WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId

	SELECT @intUserId = intUserId FROM tblGRTransferSettlementsHeader WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId

	BEGIN TRY
		DECLARE @intBillId INT
		DECLARE @intBillDetailId INT
		DECLARE @dblTotalTransferPercent DECIMAL(18,6)
		DECLARE @dblTotalSettlementAmount DECIMAL(18,6)
		DECLARE @dblTotalUnits DECIMAL(18,6)
		DECLARE @intTransferFromSettlementId INT
		DECLARE @intTransferToSettlementId INT
		
		DECLARE @dblSettlementAmountTransferred DECIMAL(18,6)
		DECLARE @dblUnits DECIMAL(18,6)

		DECLARE @refId INT

		--SAVE THE SPLITS IN tblGRTransferSettlementReference
		WHILE(SELECT TOP 1 1 FROM @TransferToSettlements) = 1
		BEGIN
			SELECT TOP 1
				@intTransferToSettlementId	= intTransferToSettlementId
				,@dblTotalTransferPercent	= dblTotalTransferPercent
				,@dblTotalSettlementAmount	= dblTotalSettlementAmount
				,@dblTotalUnits				= dblTotalUnits
			FROM @TransferToSettlements
			ORDER BY intTransferToSettlementId

			SELECT @intTransferFromSettlementId = MIN(intTransferFromSettlementId)
			FROM @TransferFromSettlements
			
			WHILE ISNULL(@intTransferFromSettlementId,0) > 0
			BEGIN
				SELECT
					@intBillId							= intBillId
					,@intBillDetailId					= intBillDetailId
					,@dblSettlementAmountTransferred	= dblSettlementAmountTransferred
					,@dblUnits							= dblUnits
				FROM @TransferFromSettlements
				WHERE intTransferFromSettlementId = @intTransferFromSettlementId
				ORDER BY intTransferFromSettlementId
				
				INSERT INTO tblGRTransferSettlementReference
				(
					[intTransferSettlementHeaderId]
					,[intTransferToSettlementId]
					,[intBillFromId]
					,[intBillDetailFromId]
					,[intBillToId]
					,[dblTransferPercent]
					,[dblSettlementAmount]
					,[dblUnits]
					,[intTransferToBillId]
					,[intAccountId]
				)
				SELECT @intTransferSettlementHeaderId
					,@intTransferToSettlementId
					,@intBillId
					,@intBillDetailId
					,NULL
					,@dblTotalTransferPercent
					,ROUND((@dblSettlementAmountTransferred * @dblTotalTransferPercent) / 100, 2)
					,ROUND((@dblUnits * @dblTotalTransferPercent) / 100, 4)
					,NULL
					,NULL

				SET @refId = SCOPE_IDENTITY()

				DECLARE @dblTotalSettlementAmount2 DECIMAL(18,6)
				DECLARE @dblTotalUnits2 DECIMAL(18,6)
				DECLARE @dblTotalTransferPercent2 DECIMAL(18,6)

				SELECT @dblTotalSettlementAmount2	= SUM(dblSettlementAmount)
					,@dblTotalUnits2				= SUM(dblUnits)
					,@dblTotalTransferPercent2		= SUM(dblTransferPercent)
				FROM tblGRTransferSettlementReference
				WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId
				GROUP BY intBillFromId, intBillDetailFromId

				IF @dblTotalSettlementAmount2 > @dblSettlementAmountTransferred
					OR @dblTotalUnits2 > @dblUnits
					OR @dblTotalTransferPercent2 > 100
				BEGIN
					UPDATE tblGRTransferSettlementReference
					SET dblTransferPercent = dblTransferPercent - (100 - @dblTotalTransferPercent2)
						,dblSettlementAmount = dblSettlementAmount - (@dblTotalSettlementAmount2 - @dblSettlementAmountTransferred)
						,dblUnits = dblUnits - (@dblTotalUnits2 - @dblUnits)
					WHERE intTransferSettlementReferenceId = @refId
				END


				--select 'test',* from tblGRTransferSettlementReference where intTransferSettlementHeaderId = @intTransferSettlementHeaderId

				SELECT @intTransferFromSettlementId = MIN(intTransferFromSettlementId)
				FROM @TransferFromSettlements
				WHERE intTransferFromSettlementId > @intTransferFromSettlementId
			END

			DELETE FROM @TransferToSettlements WHERE intTransferToSettlementId = @intTransferToSettlementId
		END

		--START CREATING DM AND VOUCHERS
		DECLARE @voucherPayable VoucherPayable
		DECLARE @voucherPayableTax VoucherDetailTax
		DECLARE @createdVouchersId NVARCHAR(MAX)
		DECLARE @success AS BIT

		DECLARE @TransferSettlementReference TransferSettlementReferenceStagingTable
		
		INSERT INTO @TransferSettlementReference
		(
			[intTransferSettlementReferenceId]
			,[intTransferSettlementHeaderId]
			,[intTransferToSettlementId]
			,[intBillFromId]
			,[intBillDetailFromId]
			,[intBillToId]
			,[dblTransferPercent]
			,[dblSettlementAmount]
			,[dblUnits]
			,[intTransferToBillId]
			,[intAccountId]
		)
		SELECT [intTransferSettlementReferenceId]
			,[intTransferSettlementHeaderId]
			,[intTransferToSettlementId]
			,[intBillFromId]
			,[intBillDetailFromId]
			,[intBillToId]
			,[dblTransferPercent]
			,[dblSettlementAmount]
			,[dblUnits]
			,[intTransferToBillId]
			,[intAccountId]
		FROM tblGRTransferSettlementReference
		WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId
		--SELECT '@TransferSettlementReference',* FROM @TransferSettlementReference
		--WHILE(SELECT TOP 1 1 FROM @TransferSettlementReference) = 1
		BEGIN
			--DM 
			INSERT INTO @voucherPayable
			(
				intTransactionType
				,intEntityVendorId		
				,intShipToId
				,intItemId
				,dblQuantityToBill
				,dblOrderQty
				,dblCost
				,intAccountId
				,strVendorOrderNumber
				,strMiscDescription
				,intTermId
				,ysnStage
			)
			SELECT
				intTransactionType		= 3
				,intEntityVendorId		= TS.intEntityId
				,intShipToId			= TS.intCompanyLocationId
				,intItemId				= NULL
				,dblQuantityToBill		= TSR.dblUnits
				,dblOrderQty			= TSR.dblUnits
				,dblCost				= ROUND(TSR.dblSettlementAmount / TSR.dblUnits,6)
				,intAccountId			= TSFROM.intAccountId
				,strVendorOrderNumber	= TS.strTransferSettlementNumber
				,strMiscDescription		= AP.strVendorOrderNumber
				,intTermId				= AP.intTermsId
				,ysnStage				= 0
			FROM @TransferSettlementReference TSR
			INNER JOIN tblGRTransferSettlementsHeader TS
				ON TS.intTransferSettlementHeaderId = TSR.intTransferSettlementHeaderId
			INNER JOIN tblGRTransferFromSettlements TSFROM
				ON TSFROM.intBillId = TSR.intBillFromId
					AND TSFROM.intTransferSettlementHeaderId = TS.intTransferSettlementHeaderId
			INNER JOIN tblAPBill AP
				ON AP.intBillId = TSR.intBillFromId
			INNER JOIN tblAPBillDetail BD
				ON BD.intBillDetailId = TSR.intBillDetailFromId

			--VOUCHER
			INSERT INTO @voucherPayable
			(
				intTransactionType
				,intEntityVendorId		
				,intShipToId
				,intItemId
				,dblQuantityToBill
				,dblOrderQty
				,dblCost
				,intAccountId
				,strVendorOrderNumber
				,strMiscDescription
				,intTermId
				,ysnStage
			)
			SELECT
				intTransactionType		= 1
				,intEntityVendorId		= TSTO.intEntityId
				,intShipToId			= TS.intCompanyLocationId
				,intItemId				= NULL
				,dblQuantityToBill		= TSR.dblUnits
				,dblOrderQty			= TSR.dblUnits
				,dblCost				= ROUND(TSR.dblSettlementAmount / TSR.dblUnits,6)
				,intAccountId			= TSFROM.intAccountId
				,strVendorOrderNumber	= TS.strTransferSettlementNumber
				,strMiscDescription		= AP.strVendorOrderNumber
				,intTermId				= AP.intTermsId
				,ysnStage				= 0
			FROM @TransferSettlementReference TSR
			INNER JOIN tblGRTransferSettlementsHeader TS
				ON TS.intTransferSettlementHeaderId = TSR.intTransferSettlementHeaderId
			INNER JOIN tblGRTransferFromSettlements TSFROM
				ON TSFROM.intBillId = TSR.intBillFromId
					AND TSFROM.intTransferSettlementHeaderId = TS.intTransferSettlementHeaderId
			INNER JOIN tblGRTransferToSettlements TSTO	
				ON TSTO.intTransferToSettlementId = TSR.intTransferToSettlementId
			INNER JOIN tblAPBill AP
				ON AP.intBillId = TSR.intBillFromId
			INNER JOIN tblAPBillDetail BD
				ON BD.intBillDetailId = TSR.intBillDetailFromId

		END

		EXEC uspAPCreateVoucher
			@voucherPayables = @voucherPayable
			,@voucherPayableTax = @voucherPayableTax
			,@userId = @intUserId
			,@throwError = 1
			,@error = @ErrMsg
			,@createdVouchersId = @createdVouchersId OUTPUT		

		IF @createdVouchersId IS NOT NULL
		BEGIN
			EXEC [dbo].[uspAPPostBill] 
				@post = 1
				,@recap = 0
				,@isBatch = 0
				,@param = @createdVouchersId
				,@userId = @intUserId
				,@transactionType = NULL
				,@success = @success OUTPUT
		END

		--update ysnPosted
		UPDATE tblGRTransferSettlementsHeader SET ysnPosted = 1 WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId

		--LINK BILL ID
		DECLARE @Bills AS TABLE (
			intBillId INT
			,intTransactionType INT
			,intEntityId INT
		)

		INSERT INTO @Bills
		SELECT intBillId,intTransactionType,intEntityVendorId FROM tblAPBill WHERE intBillId IN (SELECT * FROM dbo.fnCommaSeparatedValueToTable(@createdVouchersId))

		UPDATE TSR
		SET intBillToId = B_DM.intBillId
			,intTransferToBillId = B_BL.intBillId
		FROM tblGRTransferSettlementReference TSR
		INNER JOIN tblGRTransferSettlementsHeader TSH
			ON TSH.intTransferSettlementHeaderId = TSR.intTransferSettlementHeaderId
		INNER JOIN tblGRTransferToSettlements TSS
			ON TSS.intTransferToSettlementId = TSR.intTransferToSettlementId
		INNER JOIN @Bills B_DM
			ON (B_DM.intEntityId = TSH.intEntityId AND B_DM.intTransactionType = 3) --DM
		INNER JOIN @Bills B_BL
			ON (B_BL.intEntityId = TSS.intEntityId AND B_BL.intTransactionType = 1) --BL
		WHERE TSR.intTransferSettlementHeaderId = @intTransferSettlementHeaderId

		--Book AP clearing
		BEGIN		
			DECLARE @APClearing AS APClearing;
			DELETE FROM @APClearing;
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
			--REDUCE AP CLEARING OF THE SOURCE TRANSACTION AND VENDOR
			SELECT
				-- HEADER
				[intTransactionId]          = V.intTransferFromSettlementId
				,[strTransactionId]         = V.strTransferSettlementNumber
				,[intTransactionType]       = 6 -- GRAIN
				,[strReferenceNumber]       = ''
				,[dtmDate]                  = V.dtmDate
				,[intEntityVendorId]        = V.intEntityId
				,[intLocationId]            = V.intCompanyLocationId
				-- DETAIL
				,[intTransactionDetailId]   = V.intTransferSettlementReferenceId
				,[intAccountId]             = BD.intAccountId
				,[intItemId]                = V.intItemId
				,[intItemUOMId]             = BD.intUnitOfMeasureId
				,[dblQuantity]              = V.dblToUnits
				,[dblAmount]                = V.dblSettlementAmount
				,[strCode]                  = 'TSTR'
			FROM vyuGRTransferSettlements V
			INNER JOIN tblAPBillDetail BD
				ON BD.intBillId = V.intSourceBillId
					AND BD.intBillDetailId = V.intBillDetailFromId
			INNER JOIN tblICItem IC
				ON IC.intItemId = BD.intItemId
					AND IC.strType = 'Inventory'
			WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId
			UNION ALL
			--INCREASE AP CLEARING OF THE TRANSFER SETTLEMENT
			SELECT
				-- HEADER
				[intTransactionId]          = V.intTransferFromSettlementId
				,[strTransactionId]         = V.strTransferSettlementNumber
				,[intTransactionType]       = 6 -- GRAIN
				,[strReferenceNumber]       = ''
				,[dtmDate]                  = V.dtmDate
				,[intEntityVendorId]        = V.intEntityTransferId
				,[intLocationId]            = V.intCompanyLocationId
				-- DETAIL
				,[intTransactionDetailId]   = V.intTransferSettlementReferenceId
				,[intAccountId]             = BD.intAccountId
				,[intItemId]                = NULL
				,[intItemUOMId]             = NULL
				,[dblQuantity]              = V.dblToUnits
				,[dblAmount]                = V.dblSettlementAmount
				,[strCode]                  = 'TSTR'
			FROM vyuGRTransferSettlements V
			INNER JOIN tblAPBillDetail BD
				ON BD.intBillId = V.intTransferToBillId
			--INNER JOIN tblICItem IC
			--	ON IC.intItemId = BD.intItemId
			--		AND IC.strType = 'Inventory'
			WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId
			--SELECT '@APClearing',* FROM @APClearing
			EXEC uspAPClearing @APClearing = @APClearing, @post = 1;
		END


		DONE:

	END TRY
	BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	END CATCH
	
END