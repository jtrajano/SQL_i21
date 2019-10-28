﻿CREATE PROCEDURE [dbo].[uspCCTransactionToAPBill]
	 @intSiteHeaderId	INT
	,@userId			INT	
	,@post				BIT
	,@recap				BIT
	,@success			BIT = NULL OUTPUT
	,@errorMessage NVARCHAR(MAX) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorSeverity INT,
		@ErrorNumber   INT,
		@ErrorState INT

BEGIN

	IF(@post = 1)
	BEGIN
		DECLARE @CCRItemToAPItem TABLE(intSiteHeaderId int, strItem nvarchar(100))
		DECLARE @strCcdReference NVARCHAR(50) = NULL
		DECLARE @intVendorId INT = NULL
		DECLARE @dtmDate DATETIME = NULL
		DECLARE @intShipTo INT = NULL
		DECLARE @createdVouchersId NVARCHAR(1000) = NULL
		DECLARE @created1099KVouchersId NVARCHAR(1000) = NULL

		DECLARE @Voucher VoucherPayable
		DECLARE @Voucher1099K VoucherPayable

		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Site Net')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Site Gross')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Site Fees')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Gross')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Fees')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Site Shared Fees')

		SELECT @strCcdReference = ccSiteHeader.strCcdReference
			, @dtmDate = ccSiteHeader.dtmDate
			, @intShipTo = ccSiteHeader.intCompanyLocationId
			, @intVendorId = ccVendorDefault.intVendorId
		FROM tblCCSiteHeader ccSiteHeader
		INNER JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
		WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId

		INSERT INTO @Voucher (intTransactionType
			, dtmDate
			, intEntityVendorId
			, intShipToId
			, intLocationId
			, strVendorOrderNumber
			, intAccountId
			, intCCSiteDetailId
			, strMiscDescription
			, dblCost
			, dblQuantityToBill
			, ysnStage)
		SELECT intTransactionType = 3 
			,dtmDate = @dtmDate
			,intEntityVendorId = @intVendorId
			,intShipToId = @intShipTo
			,intLocationId = @intShipTo
			,strVendorOrderNumber = @strCcdReference
			,intAccountId
			,intSiteDetailId
			,strItem
			,SUM(dblCost)
			,[dblQtyReceived] = CASE WHEN strItem IN ('Company Owned Fees', 'Dealer Site Shared Fees', 'Dealer Site Fees') THEN -1 ELSE 1 END
			,0
		FROM (SELECT ccSiteDetail.intSiteDetailId
				 ,ccItem.strItem
				 ,(CASE WHEN ccItem.strItem = 'Dealer Site Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSite.intAccountId 
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intCreditCardReceivableAccountId  
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intFeeExpenseAccountId
					WHEN ccItem.strItem = 'Dealer Site Gross' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSite.intAccountId 
					WHEN ccItem.strItem = 'Dealer Site Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSite.intAccountId 
					WHEN ccItem.strItem = 'Dealer Site Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSite.intFeeExpenseAccountId
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned Pass Thru' THEN ccSite.intCreditCardReceivableAccountId  
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned Pass Thru' THEN ccSite.intFeeExpenseAccountId
					ELSE null END) AS intAccountId
				 ,(CASE WHEN ccItem.strItem = 'Dealer Site Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSiteDetail.dblNet 
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblGross 
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblFees
					WHEN ccItem.strItem = 'Dealer Site Gross' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblGross
					WHEN ccItem.strItem = 'Dealer Site Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100)
					WHEN ccItem.strItem = 'Dealer Site Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblFees - (ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100))
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned Pass Thru' THEN ccSiteDetail.dblGross 
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned Pass Thru' THEN ccSiteDetail.dblFees
					ELSE null END) AS dblCost
			FROM tblCCSiteHeader ccSiteHeader
			LEFT JOIN tblCCSiteDetail ccSiteDetail ON ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
			LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
			LEFT JOIN @CCRItemToAPItem ccItem ON ccItem.intSiteHeaderId = ccSiteHeader.intSiteHeaderId 
			WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId and ccSiteHeader.strApType <> 'Cash Deposited') A
		WHERE intAccountId IS NOT NULL AND dblCost != 0
		GROUP BY  intAccountId, intSiteDetailId, strItem 

		-- 1099K Adjustment
		INSERT INTO @Voucher1099K (intTransactionType
			, dtmDate
			, intEntityVendorId
			, intShipToId
			, strVendorOrderNumber
			, intAccountId
			, intLocationId
			, intCCSiteDetailId
			, strMiscDescription
			, dblCost
			, dblQuantityToBill
			, ysnStage)
		SELECT 9
			, dtmDate
			, intEntityVendorId
			, intShipToId
			, strVendorOrderNumber
			, intAccountId
			, intLocationId
			, intCCSiteDetailId
			, strMiscDescription
			, dblCost
			, dblQuantityToBill
			, 0 
		FROM @Voucher WHERE strMiscDescription IN ('Dealer Site Gross', 'Dealer Site Net')

		IF EXISTS(SELECT TOP 1 1 FROM @Voucher)
		BEGIN
			EXEC [dbo].[uspAPCreateVoucher] 
			@voucherPayables = @Voucher
			,@userId = @userId
			,@error = @errorMessage OUTPUT
			,@createdVouchersId = @createdVouchersId OUTPUT

			EXEC [dbo].[uspAPPostBill]
			@post = @post
			,@recap = @recap
			,@isBatch = 0
			,@transactionType = 'Credit Card'
			,@param = @createdVouchersId
			,@userId = @userId
			,@success = @success OUTPUT

			IF EXISTS(SELECT TOP 1 1 FROM @Voucher1099K)
			BEGIN
				EXEC [dbo].[uspAPCreateVoucher] 
				@voucherPayables = @Voucher1099K
				,@userId = @userId
				,@error = @errorMessage OUTPUT
				,@createdVouchersId = @created1099KVouchersId OUTPUT
			END
		END
		ELSE
		BEGIN
			SET @success = 1
		END

			--DECLARE @voucherDetailCC AS VoucherDetailCC
			--DECLARE @shipTo INT
			--DECLARE @dtmDate DATETIME
			--DECLARE @ccdReference NVARCHAR(50)
			--DECLARE @vendorId INT
			--	DECLARE @CCRItemToAPItem TABLE
			--	(
			--		intSiteHeaderId int, 
			--		strItem nvarchar(100)
			--	)

			--	INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Sites Net')
			--	INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Gross')
			--	INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Fees')
			--	INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Sites Shared Fees')

			--	SELECT @ccdReference = ccSiteHeader.strCcdReference
			--		, @dtmDate = ccSiteHeader.dtmDate
			--		, @shipTo = ccSiteHeader.intCompanyLocationId
			--		, @vendorId = ccVendorDefault.intVendorId
			--	FROM tblCCSiteHeader ccSiteHeader
			--	INNER JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
			--	WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId

			--INSERT INTO @voucherDetailCC([intAccountId] 
			--	,[intSiteDetailId] 
			--	,[strMiscDescription] 
			--	,[dblCost]
			--	,[dblQtyReceived])
			--SELECT [intAccountId] = intAccountId
			--	,[intSiteDetailId] = intSiteDetailId
			--	,[strMiscDescription] = strItem
			--	,[dblCost] = SUM(dblCost)
			--	,[dblQtyReceived]  = CASE WHEN strItem = 'Company Owned Fees' THEN -1 ELSE 1 END
			--FROM(
			--SELECT 
			--	 ccSiteDetail.intSiteDetailId
			--	 ,ccItem.strItem
			--	 ,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSite.intAccountId 
			--		WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intCreditCardReceivableAccountId  
			--		WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intFeeExpenseAccountId
			--		WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSite.intAccountId 
			--		WHEN ccItem.strItem = 'Dealer Sites Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSite.intFeeExpenseAccountId
			--		ELSE null END) AS intAccountId
			--	 ,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSiteDetail.dblNet 
			--		WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblGross 
			--		WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblFees
			--		WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblNet
			--		WHEN ccItem.strItem = 'Dealer Sites Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblFees - (ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100))
			--		ELSE null END) AS dblCost
			--FROM tblCCSiteHeader ccSiteHeader
			--LEFT JOIN tblCCSiteDetail ccSiteDetail ON ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
			--LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
			--LEFT JOIN @CCRItemToAPItem ccItem ON ccItem.intSiteHeaderId = ccSiteHeader.intSiteHeaderId 
			--WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId and ccSiteHeader.strApType <> 'Cash Deposited') A
			--WHERE intAccountId IS NOT NULL AND dblCost != 0
			--GROUP BY  intAccountId, intSiteDetailId, strItem 

			--DECLARE @intCountDetail INT = 0

			--SELECT @intCountDetail = COUNT(*) FROM @voucherDetailCC

			--IF(@intCountDetail > 0)
			--BEGIN
			--	EXEC [dbo].[uspAPCreateBillData]
			--		 @userId	= @userId
			--		,@vendorId = @vendorId
			--		,@type = 3	
			--		,@shipTo = @shipTo
			--		,@vendorOrderNumber = @ccdReference
			--		,@voucherDate = @dtmDate
			--		,@voucherDetailCC = @voucherDetailCC
			--		,@billId = @createdBillId OUTPUT

			--	UPDATE tblAPBill SET strComment = @ccdReference WHERE intBillId = @createdBillId

			--	EXEC [dbo].[uspAPPostBill]
			--		@post = @post
			--		,@recap = @recap
			--		,@isBatch = 0
			--		,@param = @createdBillId
			--		,@userId = @userId
			--		,@success = @success OUTPUT
			--END

		END
	ELSE IF (@post = 0)
	BEGIN
			
		DECLARE @intBillId INT = NULL
		DECLARE @intTransactionType INT = NULL
			--DECLARE @paymentTrans INT = NULL
			
			--Find AP Info
			

			--SELECT @isPaid = ysnPaid FROM tblAPBill WHERE intBillId = @billId
			--SELECT @paymentTrans = COUNT(A.intPaymentId) FROM tblAPPayment A JOIN
			--tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId 
			--WHERE intBillId = @billId

		DECLARE @CursorTran AS CURSOR

		SET @CursorTran = CURSOR FOR
		SELECT C.intBillId, D.intTransactionType FROM tblCCSiteHeader A 
		INNER JOIN tblCCSiteDetail B ON B.intSiteHeaderId = A.intSiteHeaderId
		INNER JOIN tblAPBillDetail C ON C.intCCSiteDetailId = B.intSiteDetailId
		INNER JOIN tblAPBill D ON D.intBillId = C.intBillId
		WHERE A.intSiteHeaderId = @intSiteHeaderId
		GROUP BY C.intBillId, D.intTransactionType

		OPEN @CursorTran
		IF (@@CURSOR_ROWS = 0)
		BEGIN
			SET @success = 1
		END
		FETCH NEXT FROM @CursorTran INTO @intBillId, @intTransactionType
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			IF (@intTransactionType != 9)
			BEGIN
				EXEC [dbo].[uspAPPostBill]
					@post = @post
					,@recap = 0
					,@isBatch = 0
					,@param = @intBillId
					,@transactionType = 'Credit Card'
					,@userId = @userId
					,@success = @success OUTPUT
			END

			IF(@success = 1)
			BEGIN
				-- DELETE AP
				EXEC [dbo].[uspAPDeleteVoucher]
					@intBillId = @intBillId
					,@UserId = @userId
			END
			ELSE
			BEGIN
				SELECT TOP 1 @errorMessage = strMessage FROM tblAPPostResult WHERE intTransactionId = @intBillId ORDER BY intId DESC
				RAISERROR(@errorMessage,16,1)
			END
			
			FETCH NEXT FROM @CursorTran INTO @intBillId, @intTransactionType
		END
		CLOSE @CursorTran
		DEALLOCATE @CursorTran

			--IF(@billId IS NOT NULL)
			--BEGIN

			--	--IF(@paymentTrans > 0)
			--	--	BEGIN
			--	--		RAISERROR('Cannot unpost this transaction. There is already payment made on the associated Voucher/Invoice.', 16, 1)
			--	--	END
			--	--ELSE
			--		BEGIN
						
			--			EXEC [dbo].[uspAPPostBill]
			--				@post = @post
			--				,@recap = 0
			--				,@isBatch = 0
			--				,@param = @billId
			--				,@userId = @userId
			--				,@success = @success OUTPUT

						

			--			--DELETE Bill Transaction
			--			--DELETE FROM tblAPBill WHERE intBillId = 
			--			--(SELECT DISTINCT intBillId 
			--			--	FROM tblAPBillDetail A
			--			--JOIN  tblCCSiteDetail B ON A.intCCSiteDetailId = B.intSiteDetailId
			--			--	WHERE B.intSiteHeaderId = @intSiteHeaderId)
			--		END
			--END

	END
END
