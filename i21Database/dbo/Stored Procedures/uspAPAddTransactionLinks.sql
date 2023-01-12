CREATE PROCEDURE [dbo].[uspAPAddTransactionLinks]
	@intTransactionType INT,
	@strTransactionIds NVARCHAR(MAX),
	@intAction INT,
	@intUserId INT,
	@ysnSkip BIT = 0
AS

BEGIN
	--TRACEABILITY
		DECLARE @TransactionLinks udtICTransactionLinks
		DECLARE @ID AS TABLE (intID INT)
		DECLARE @intDestId INT, @strDestTransactionNo NVARCHAR(100)

		--VOUCHER
		IF @intTransactionType = 1
		BEGIN
			IF EXISTS(
				SELECT 1
				FROM tblAPBillDetail A
				INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) B ON A.intBillId = B.intID
				WHERE A.intInventoryReceiptItemId > 0
					OR A.intInventoryReceiptChargeId > 0
					OR A.intInventoryShipmentChargeId > 0
					OR A.intLoadDetailId > 0
					OR A.intLoadShipmentCostId > 0
					OR A.intSettleStorageId > 0
			)
			BEGIN
				--CREATE/UPDATE
				IF @intAction = 1 OR @intAction = 2
				BEGIN
					INSERT INTO @TransactionLinks (
						intSrcId,
						strSrcTransactionNo,
						strSrcTransactionType,
						strSrcModuleName,
						intDestId,
						strDestTransactionNo,
						strDestTransactionType,
						strDestModuleName,
						strOperation
					)
					SELECT
						ST.intSourceTransactionId,
						ST.strSourceTransaction,
						ST.strSourceTransactionType,
						ST.strSourceModule,
						B.intBillId,
						B.strBillId,
						'Voucher',
						'Accounts Payable',
						'Create'
					FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) IDS
					INNER JOIN tblAPBill B ON B.intBillId = IDS.intID
					INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
					CROSS APPLY fnAPGetDetailSourceTransaction(BD.intInventoryReceiptItemId, BD.intInventoryReceiptChargeId, BD.intInventoryShipmentChargeId, BD.intLoadDetailId, BD.intLoadShipmentCostId, BD.intCustomerStorageId, BD.intSettleStorageId, BD.intBillId, BD.intItemId) ST

					EXEC uspICAddTransactionLinks @TransactionLinks
				END

				--DELETE
				IF @intAction = 3
				BEGIN
					INSERT INTO @ID
					SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds)

					WHILE EXISTS(SELECT TOP 1 1 FROM @ID)
					BEGIN
						SELECT TOP 1 @intDestId = B.intBillId, @strDestTransactionNo = B.strBillId
						FROM @ID ID
						INNER JOIN tblAPBill B ON B.intBillId = ID.intID

						IF @intDestId IS NULL
						BEGIN
							RAISERROR('Error occured while updating Voucher Traceability.', 16, 1);
							RETURN;
						END
						ELSE
						BEGIN
							EXEC uspICDeleteTransactionLinks @intDestId, @strDestTransactionNo, 'Voucher', 'Accounts Payable'
							DELETE FROM @ID WHERE intID = @intDestId
						END
					END
				END
			END
		END

		--PAYMENT
		IF @intTransactionType = 2
		BEGIN
			--CREATE/UPDATE
			IF @intAction = 1 OR @intAction = 2
			BEGIN
				INSERT INTO @TransactionLinks (
					intSrcId,
					strSrcTransactionNo,
					strSrcTransactionType,
					strSrcModuleName,
					intDestId,
					strDestTransactionNo,
					strDestTransactionType,
					strDestModuleName,
					strOperation
				)
				SELECT
					CASE WHEN I.intInvoiceId IS NOT NULL THEN I.intInvoiceId ELSE B.intBillId END,
					CASE WHEN I.intInvoiceId IS NOT NULL THEN I.strInvoiceNumber ELSE B.strBillId END,
					CASE WHEN I.intInvoiceId IS NOT NULL THEN 'Invoice' ELSE 'Voucher' END,
					'Accounts Payable',
					P.intPaymentId,
					P.strPaymentRecordNum,
					'Payment',
					'Accounts Payable',
					'Create'
				FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) IDS
				INNER JOIN tblAPPayment P ON P.intPaymentId = IDS.intID
				INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
				LEFT JOIN tblAPBill B ON B.intBillId = PD.intBillId
				LEFT JOIN tblARInvoice I ON I.intInvoiceId = PD.intInvoiceId
				WHERE PD.dblPayment <> 0

				EXEC uspICAddTransactionLinks @TransactionLinks
			END
			
			--DELETE
			IF @intAction = 3
			BEGIN
				INSERT INTO @ID
				SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds)

				WHILE EXISTS(SELECT TOP 1 1 FROM @ID)
				BEGIN
					SELECT TOP 1 @intDestId = P.intPaymentId, @strDestTransactionNo = P.strPaymentRecordNum
					FROM @ID ID
					INNER JOIN tblAPPayment P ON P.intPaymentId = ID.intID


					IF @intDestId IS NULL
					BEGIN
						RAISERROR('Error occured while updating Payment Traceability.', 16, 1);
						RETURN;
					END
					ELSE
					BEGIN
						EXEC uspICDeleteTransactionLinks @intDestId, @strDestTransactionNo, 'Payment', 'Accounts Payable'
						DELETE FROM @ID WHERE intID = @intDestId
					END
				END
			END
		END

	--TRADE FINANCE
	IF @ysnSkip <> 1
	BEGIN
		DECLARE @TradeFinanceLogs AS TRFLog

		--VOUCHER
		IF @intTransactionType = 1
		BEGIN
			INSERT INTO @TradeFinanceLogs (
				strAction,
				strTransactionType,
				strTradeFinanceTransaction,
				intTransactionHeaderId,
				strTransactionNumber,
				dtmTransactionDate,
				intBankId,
				intBankAccountId,
				intBorrowingFacilityId,
				intLimitId,
				dblLimit,
				intSublimitId,
				dblSublimit,
				strBankTradeReference,
				intOverrideBankValuationId,
				dblFinanceQty,
				dblFinancedAmount,
				ysnDeleted,
				ysnMarkOnlyDeleted,
				strBankApprovalStatus,
				dtmAppliedToTransactionDate,
				intStatusId,
				intUserId,
				intConcurrencyId,
				intContractHeaderId,
				intContractDetailId
			)
			SELECT
				strAction						= CASE 
														WHEN @intAction = 1 THEN 'Created ' + dbo.fnAPGetVoucherTransactionType2(B.intTransactionType)
														WHEN @intAction = 2 THEN 'Updated ' + dbo.fnAPGetVoucherTransactionType2(B.intTransactionType)
														ELSE 'Deleted ' + dbo.fnAPGetVoucherTransactionType2(B.intTransactionType)
												   END, 
				strTransactionType				= 'Purchasing',
				strTradeFinanceTransaction		= B.strFinanceTradeNo,
				intTransactionHeaderId			= B.intBillId,
				strTransactionNumber			= B.strBillId,
				dtmTransactionDate				= B.dtmBillDate,
				intBankId						= B.intBankId,
				intBankAccountId				= B.intBankAccountId,
				intBorrowingFacilityId			= B.intBorrowingFacilityId,
				intLimitId						= B.intBorrowingFacilityLimitId,
				dblLimit						= BFL.dblLimit,
				intSublimitId					= B.intBorrowingFacilityLimitDetailId,
				dblSublimit						= BFLD.dblLimit,
				strBankTradeReference			= B.strReferenceNo,
				intOverrideBankValuationId		= B.intBankValuationRuleId,
				dblFinanceQty					= CASE WHEN (BD.dblQtyReceived - BDT.dblQtyReceived) = 0 THEN BD.dblQtyReceived ELSE BD.dblQtyReceived - BDT.dblQtyReceived END,
				dblFinancedAmount				= CASE WHEN (BD.dblQtyReceived - BDT.dblQtyReceived) = 0 THEN BD.dblTotal ELSE BD.dblTotal - BDT.dblTotal END,
				ysnDeleted						= CASE WHEN (BD.dblQtyReceived - BDT.dblQtyReceived) = 0 THEN 1 ELSE 0 END,
				ysnMarkOnlyDeleted				= CASE WHEN @intAction NOT IN (1, 2) AND (BD.dblQtyReceived - BDT.dblQtyReceived) <> 0 THEN 1 ELSE 0 END,
				strBankApprovalStatus			= ISNULL(ap.strApprovalStatus, 'Approved'),
				dtmAppliedToTransactionDate		= B.dtmBillDate,
				intStatusId						= 1,
				intUserId						= @intUserId,
				intConcurrencyId				= 1,
				intContractHeaderId				= BD.intContractHeaderId,
				intContractDetailId				= BD.intContractDetailId
			FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) IDS
			INNER JOIN tblAPBill B ON B.intBillId = IDS.intID
			OUTER APPLY (
				SELECT MIN(BD2.intContractHeaderId) intContractHeaderId, MIN(BD2.intContractDetailId) intContractDetailId, MIN(BD2.intLoadId) intLoadId, SUM(BD2.dblQtyReceived) dblQtyReceived, SUM(BD2.dblTotal + BD2.dblTax) dblTotal
				FROM tblAPBill B2
				INNER JOIN tblAPBillDetail BD2 ON BD2.intBillId = B2.intBillId
				WHERE B2.strFinanceTradeNo = B.strFinanceTradeNo
			) BD
			OUTER APPLY (
				SELECT ISNULL(SUM(BD2.dblQtyReceived), 0) dblQtyReceived, ISNULL(SUM(BD2.dblTotal + BD2.dblTax), 0) dblTotal
				FROM tblAPBill B2
				INNER JOIN tblAPBillDetail BD2 ON BD2.intBillId = B2.intBillId
				WHERE B2.intBillId = B.intBillId AND @intAction NOT IN (1, 2)
			) BDT
			LEFT JOIN tblCMBorrowingFacilityLimit BFL ON BFL.intBorrowingFacilityLimitId = B.intBorrowingFacilityLimitId
			LEFT JOIN tblCMBorrowingFacilityLimitDetail BFLD ON BFLD.intBorrowingFacilityLimitDetailId = B.intBorrowingFacilityLimitDetailId
			LEFT JOIN tblCTContractDetail ctd ON ctd.intContractDetailId = BD.intContractDetailId
			LEFT JOIN tblLGLoad l ON l.intLoadId = BD.intLoadId
			LEFT JOIN tblCTApprovalStatusTF ap ON ap.intApprovalStatusId = ISNULL(l.intApprovalStatusId, ctd.intApprovalStatusId)
			WHERE NULLIF(B.strFinanceTradeNo, '') IS NOT NULL
				  OR NULLIF(B.intBankId, 0) IS NOT NULL
				  OR NULLIF(B.intBankAccountId, 0) IS NOT NULL
				  OR NULLIF(B.intBorrowingFacilityId, 0) IS NOT NULL
				  OR NULLIF(B.intBorrowingFacilityLimitId, 0) IS NOT NULL
				  OR NULLIF(B.intBorrowingFacilityLimitDetailId, 0) IS NOT NULL
				  OR NULLIF(B.strReferenceNo, '') IS NOT NULL
				  OR NULLIF(B.intBankValuationRuleId, 0) IS NOT NULL
		END

		--PAYMENT
		IF @intTransactionType = 2
		BEGIN
			INSERT INTO @TradeFinanceLogs (
				strAction,
				strTransactionType,
				strTradeFinanceTransaction,
				intTransactionHeaderId,
				strTransactionNumber,
				dtmTransactionDate,
				intBankId,
				intBankAccountId,
				intBorrowingFacilityId,
				intLimitId,
				dblLimit,
				intSublimitId,
				dblSublimit,
				strBankTradeReference,
				intOverrideBankValuationId,
				dblFinanceQty,
				dblFinancedAmount,
				strBankApprovalStatus,
				dtmAppliedToTransactionDate,
				intStatusId,
				intUserId,
				intConcurrencyId,
				intContractHeaderId,
				intContractDetailId
			)
SELECT
				strAction						= CASE WHEN @intAction = 1 THEN 'Created Payment' 
														WHEN @intAction = 2 THEN 'Updated Payment'
														ELSE 'Deleted Payment'
													END, 
				strTransactionType				= 'Purchasing',
				strTradeFinanceTransaction		= B.strFinanceTradeNo,
				intTransactionHeaderId			= P.intPaymentId,
				strTransactionNumber			= P.strPaymentRecordNum,
				dtmTransactionDate				= P.dtmDatePaid,
				intBankId						= B.intBankId,
				intBankAccountId				= B.intBankAccountId,
				intBorrowingFacilityId			= B.intBorrowingFacilityId,
				intLimitId						= B.intBorrowingFacilityLimitId,
				dblLimit						= BFL.dblLimit,
				intSublimitId					= B.intBorrowingFacilityLimitDetailId,
				dblSublimit						= BFLD.dblLimit,
				strBankTradeReference			= B.strReferenceNo,
				intOverrideBankValuationId		= B.intBankValuationRuleId,
				dblFinanceQty					= BD.dblQtyReceived,
				dblFinancedAmount				= PD.dblPayment,
				strBankApprovalStatus			= ISNULL(ap.strApprovalStatus, 'Approved'),
				dtmAppliedToTransactionDate		= P.dtmDatePaid,
				intStatusId						= 1, --Active
				intUserId						= @intUserId,
				intConcurrencyId				= 1,
				intContractHeaderId				= BD.intContractHeaderId,
				intContractDetailId				= BD.intContractDetailId
			FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) IDS
			INNER JOIN tblAPPayment P ON P.intPaymentId = IDS.intID
			INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
			INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
			INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
			LEFT JOIN tblCMBorrowingFacilityLimit BFL ON BFL.intBorrowingFacilityLimitId = B.intBorrowingFacilityLimitId
			LEFT JOIN tblCMBorrowingFacilityLimitDetail BFLD ON BFLD.intBorrowingFacilityLimitDetailId = B.intBorrowingFacilityLimitDetailId
			LEFT JOIN tblCTContractDetail ctd ON BD.intContractDetailId = ctd.intContractDetailId
			LEFT JOIN tblLGLoad l ON l.intLoadId = BD.intLoadId
			LEFT JOIN tblCTApprovalStatusTF ap ON ap.intApprovalStatusId = ISNULL(l.intApprovalStatusId, ctd.intApprovalStatusId)
			WHERE (NULLIF(B.strFinanceTradeNo, '') IS NOT NULL
				  OR NULLIF(B.intBankId, 0) IS NOT NULL
				  OR NULLIF(B.intBankAccountId, 0) IS NOT NULL
				  OR NULLIF(B.intBorrowingFacilityId, 0) IS NOT NULL
				  OR NULLIF(B.intBorrowingFacilityLimitId, 0) IS NOT NULL
				  OR NULLIF(B.intBorrowingFacilityLimitDetailId, 0) IS NOT NULL
				  OR NULLIF(B.strReferenceNo, '') IS NOT NULL
				  OR NULLIF(B.intBankValuationRuleId, 0) IS NOT NULL)
				  AND PD.dblPayment <> 0
		END

		-- --REVERSE LOGS
		-- DECLARE @strTradeFinanceNumber NVARCHAR(100), @strTransactionType NVARCHAR(100), @dtmTransactionDate DATETIME, @strAction NVARCHAR(100)
		
		-- DECLARE TFLogCursor CURSOR LOCAL FAST_FORWARD
		-- FOR
		-- SELECT strTradeFinanceTransaction, strTransactionType, dtmTransactionDate, strAction FROM @TradeFinanceLogs

		-- OPEN TFLogCursor
		-- FETCH NEXT FROM TFLogCursor INTO @strTradeFinanceNumber, @strTransactionType, @dtmTransactionDate, @strAction
		-- WHILE @@FETCH_STATUS = 0
		-- BEGIN
		-- 	EXEC uspTRFNegateTFLogFinancedQtyAndAmount
		-- 		@strTradeFinanceNumber 	= @strTradeFinanceNumber,
		-- 		@strTransactionType		= @strTransactionType,
		-- 		@strLimitType			= NULL,
		-- 		@dtmTransactionDate		= @dtmTransactionDate,
		-- 		@strAction				= @strAction

		-- 	FETCH NEXT FROM TFLogCursor INTO @strTradeFinanceNumber, @strTransactionType, @dtmTransactionDate, @strAction
		-- END
		-- CLOSE TFLogCursor
		-- DEALLOCATE TFLogCursor

		--NEW LOGS
		EXEC uspTRFLogTradeFinance @TradeFinanceLogs
	END
END