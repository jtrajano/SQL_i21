CREATE PROCEDURE [dbo].[uspGRProcessTransferSettlements]
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
	DECLARE @dblTransferUnits NUMERIC(18,6)
	DECLARE @dblTransferAmount NUMERIC(18,6)	
	DECLARE @TransferFromSettlements AS TransferFromSettlementStagingTable
	DECLARE @TransferToSettlements AS TransferToSettlementStagingTable

	INSERT INTO @TransferFromSettlements
	SELECT intTransferFromSettlementId
		,intTransferSettlementHeaderId
		,intBillId
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

	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @intBillId INT
		DECLARE @dblTotalTransferPercent DECIMAL(18,6)
		DECLARE @dblTotalSettlementAmount DECIMAL(18,6)
		DECLARE @dblTotalUnits DECIMAL(18,6)
		DECLARE @intTransferFromSettlementId INT
		DECLARE @intTransferToSettlementId INT

		DECLARE @dblSettlementAmountTransferred DECIMAL(18,6)
		DECLARE @dblUnits DECIMAL(18,6)

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
					,@dblSettlementAmountTransferred	= dblSettlementAmountTransferred
					,@dblUnits							= dblUnits
				FROM @TransferFromSettlements
				WHERE intTransferFromSettlementId = @intTransferFromSettlementId
				ORDER BY intTransferFromSettlementId
				
				INSERT INTO tblGRTransferSettlementReference
				SELECT @intTransferSettlementHeaderId
					,@intTransferToSettlementId
					,@intBillId
					,NULL
					,@dblTotalTransferPercent
					,ROUND((@dblSettlementAmountTransferred * @dblTotalTransferPercent) / 100, 2)
					,ROUND((@dblUnits * @dblTotalTransferPercent) / 100, 4)
					,NULL

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
		SELECT *
		FROM tblGRTransferSettlementReference
		WHERE intTransferSettlementHeaderId = @intTransferSettlementHeaderId

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
				,dblCost				= ROUND(TSR.dblSettlementAmount / TSR.dblUnits,2)
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
			INNER JOIN tblAPBill AP
				ON AP.intBillId = TSR.intBillFromId

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
				,dblCost				= ROUND(TSR.dblSettlementAmount / TSR.dblUnits,2)
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
			INNER JOIN tblGRTransferToSettlements TSTO	
				ON TSTO.intTransferToSettlementId = TSR.intTransferToSettlementId
			INNER JOIN tblAPBill AP
				ON AP.intBillId = TSR.intBillFromId
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

		--SELECT '@Bills',* FROM @Bills

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


		DONE:
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	END CATCH
	
END