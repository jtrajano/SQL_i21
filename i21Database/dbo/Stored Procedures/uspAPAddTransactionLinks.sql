CREATE PROCEDURE [dbo].[uspAPAddTransactionLinks]
	@intTransactionType INT,
	@strTransactionIds NVARCHAR(MAX),
	@intAction INT,
	@intUserId INT
AS

BEGIN
	--TRACEABILITY
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
		DECLARE @TransactionLinks udtICTransactionLinks
		DECLARE @ID AS TABLE (intID INT)
		DECLARE @intDestId INT, @strDestTransactionNo NVARCHAR(100)

		--VOUCHER
		IF @intTransactionType = 1
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
	END

	--TRADE FINANCE
	IF EXISTS(
		SELECT 1
		FROM tblAPBill A
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) B ON A.intBillId = B.intID
		WHERE NULLIF(A.strFinanceTradeNo, '') IS NOT NULL
			  OR NULLIF(A.intBankId, 0) IS NOT NULL
			  OR NULLIF(A.intBankAccountId, 0) IS NOT NULL
			  OR NULLIF(A.intBorrowingFacilityId, 0) IS NOT NULL
			  OR NULLIF(A.strBankReferenceNo, '') IS NOT NULL
			  OR NULLIF(A.intBorrowingFacilityLimitId, 0) IS NOT NULL
			  OR NULLIF(A.intBorrowingFacilityLimitDetailId, 0) IS NOT NULL
			  OR NULLIF(A.strReferenceNo, '') IS NOT NULL
			  OR NULLIF(A.intBankValuationRuleId, 0) IS NOT NULL
			  OR NULLIF(A.strComments, '') IS NOT NULL
	)
	BEGIN
		DECLARE @TradeFinanceLogs AS TRFLog

		--VOUCHER
		IF @intTransactionType = 1
		BEGIN
			INSERT INTO @TradeFinanceLogs (
				strAction
				, strTransactionType
				, intTransactionHeaderId
				, intTransactionDetailId
				, strTransactionNumber
				, dtmTransactionDate
				, intBankId
				, intBankAccountId
				, intBorrowingFacilityId
				, dblTransactionAmountAllocated
				, dblTransactionAmountActual
				, intLimitId
				, dblLimit
				, strBankTradeReference
				, strBankApprovalStatus
				, dtmAppliedToTransactionDate
				, intStatusId
				, intWarrantId
				, strWarrantId
				, intUserId
				, intConcurrencyId
				, intContractHeaderId
				, intContractDetailId
			)
			SELECT
				strAction						= CASE WHEN @intAction = 1 THEN 'Created Voucher' 
													   WHEN @intAction = 2 THEN 'Updated Voucher'
													   ELSE 'Deleted Voucher'
												  END
				, strTransactionType			= 'Voucher'
				, intTransactionHeaderId		= B.intBillId
				, intTransactionDetailId		= BD.intBillDetailId
				, strTransactionNumber			= B.strBillId
				, dtmTransactionDate			= GETDATE()
				, intBankId						= B.intBankId
				, intBankAccountId				= B.intBankAccountId
				, intBorrowingFacilityId		= B.intBorrowingFacilityId
				, dblTransactionAmountAllocated = CTCD.dblLoanAmount
				, dblTransactionAmountActual	= CTCD.dblLoanAmount
				, intLimitId					= B.intBorrowingFacilityLimitId
				, dblLimit						= CMBFL.dblLimit
				, strBankTradeReference			= B.strBankReferenceNo
				, strBankApprovalStatus			= 'No Need For Approval'
				, dtmAppliedToTransactionDate	= GETDATE()
				, intStatusId					= 1
				, intWarrantId					= NULL
				, strWarrantId					= ''
				, intUserId						= @intUserId
				, intConcurrencyId				= 1
				, intContractHeaderId			= BD.intContractHeaderId
				, intContractDetailId			= BD.intContractDetailId
			FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) IDS
			INNER JOIN tblAPBill B ON B.intBillId = IDS.intID
			INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
			LEFT JOIN tblCTContractDetail CTCD ON CTCD.intContractDetailId = BD.intContractDetailId
			LEFT JOIN tblCTContractHeader CTCH ON CTCH.intContractHeaderId = CTCD.intContractHeaderId
			LEFT JOIN tblCMBorrowingFacilityLimit CMBFL ON CMBFL.intBorrowingFacilityLimitId = B.intBorrowingFacilityLimitId
			WHERE NULLIF(B.strFinanceTradeNo, '') IS NOT NULL
			  	  OR NULLIF(B.intBankId, 0) IS NOT NULL
			      OR NULLIF(B.intBankAccountId, 0) IS NOT NULL
			      OR NULLIF(B.intBorrowingFacilityId, 0) IS NOT NULL
			      OR NULLIF(B.strBankReferenceNo, '') IS NOT NULL
			      OR NULLIF(B.intBorrowingFacilityLimitId, 0) IS NOT NULL
			      OR NULLIF(B.intBorrowingFacilityLimitDetailId, 0) IS NOT NULL
			      OR NULLIF(B.strReferenceNo, '') IS NOT NULL
			      OR NULLIF(B.intBankValuationRuleId, 0) IS NOT NULL
			      OR NULLIF(B.strComments, '') IS NOT NULL
		END

		--PAYMENT
		IF @intTransactionType = 2
		BEGIN
			INSERT INTO @TradeFinanceLogs (
				strAction
				, strTransactionType
				, intTransactionHeaderId
				, intTransactionDetailId
				, strTransactionNumber
				, dtmTransactionDate
				, intBankId
				, intBankAccountId
				, intBorrowingFacilityId
				, dblTransactionAmountAllocated
				, dblTransactionAmountActual
				, intLimitId
				, dblLimit
				, strBankTradeReference
				, strBankApprovalStatus
				, dtmAppliedToTransactionDate
				, intStatusId
				, intWarrantId
				, strWarrantId
				, intUserId
				, intConcurrencyId
				, intContractHeaderId
				, intContractDetailId
			)
			SELECT
				strAction						= CASE WHEN @intAction = 1 THEN 'Created Payment' 
													   WHEN @intAction = 2 THEN 'Updated Payment'
													   ELSE 'Deleted Payment'
												  END
				, strTransactionType			= 'Payment'
				, intTransactionHeaderId		= P.intPaymentId
				, intTransactionDetailId		= PD.intPaymentDetailId
				, strTransactionNumber			= P.strPaymentRecordNum
				, dtmTransactionDate			= GETDATE()
				, intBankId						= B.intBankId
				, intBankAccountId				= B.intBankAccountId
				, intBorrowingFacilityId		= B.intBorrowingFacilityId
				, dblTransactionAmountAllocated = CTCD.dblLoanAmount
				, dblTransactionAmountActual	= CTCD.dblLoanAmount
				, intLimitId					= B.intBorrowingFacilityLimitId
				, dblLimit						= CMBFL.dblLimit
				, strBankTradeReference			= B.strBankReferenceNo
				, strBankApprovalStatus			= 'No Need For Approval'
				, dtmAppliedToTransactionDate	= GETDATE()
				, intStatusId					= 1
				, intWarrantId					= NULL
				, strWarrantId					= ''
				, intUserId						= @intUserId
				, intConcurrencyId				= 1
				, intContractHeaderId			= BD.intContractHeaderId
				, intContractDetailId			= BD.intContractDetailId
			FROM dbo.fnGetRowsFromDelimitedValues(@strTransactionIds) IDS
			INNER JOIN tblAPPayment P ON P.intPaymentId = IDS.intID
			INNER JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
			INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
			INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
			LEFT JOIN tblCTContractDetail CTCD ON CTCD.intContractDetailId = BD.intContractDetailId
			LEFT JOIN tblCTContractHeader CTCH ON CTCH.intContractHeaderId = CTCD.intContractHeaderId
			LEFT JOIN tblCMBorrowingFacilityLimit CMBFL ON CMBFL.intBorrowingFacilityLimitId = B.intBorrowingFacilityLimitId
			WHERE NULLIF(B.strFinanceTradeNo, '') IS NOT NULL
			  	  OR NULLIF(B.intBankId, 0) IS NOT NULL
			      OR NULLIF(B.intBankAccountId, 0) IS NOT NULL
			      OR NULLIF(B.intBorrowingFacilityId, 0) IS NOT NULL
			      OR NULLIF(B.strBankReferenceNo, '') IS NOT NULL
			      OR NULLIF(B.intBorrowingFacilityLimitId, 0) IS NOT NULL
			      OR NULLIF(B.intBorrowingFacilityLimitDetailId, 0) IS NOT NULL
			      OR NULLIF(B.strReferenceNo, '') IS NOT NULL
			      OR NULLIF(B.intBankValuationRuleId, 0) IS NOT NULL
			      OR NULLIF(B.strComments, '') IS NOT NULL
		END

		EXEC uspTRFLogTradeFinance @TradeFinanceLogs
	END
END