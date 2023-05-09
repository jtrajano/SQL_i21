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
		DECLARE @apType NVARCHAR(100) = NULL

		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Site Net')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Site Gross')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Site Fees')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Gross')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Fees')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Site Shared Fees')
		INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Shared Fees')

		SELECT @strCcdReference = ccSiteHeader.strCcdReference
			, @dtmDate = ccSiteHeader.dtmDate
			, @intShipTo = ccSiteHeader.intCompanyLocationId
			, @intVendorId = ccVendorDefault.intVendorId
			, @apType  = ccSiteHeader.strApType
		FROM tblCCSiteHeader ccSiteHeader
		INNER JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
		WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId

		INSERT INTO @Voucher (intTransactionType
			, dtmDate
			, dtmVoucherDate
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
			,dtmVoucherDate = @dtmDate
			,intEntityVendorId = @intVendorId
			,intShipToId = @intShipTo
			,intLocationId = @intShipTo
			,strVendorOrderNumber = @strCcdReference
			,intAccountId
			,intSiteDetailId
			,strItem
			,SUM(dblCost)
			,[dblQtyReceived] = CASE WHEN strItem IN ('Company Owned Fees', 'Dealer Site Shared Fees', 'Dealer Site Fees','Company Owned Shared Fees') THEN -1 ELSE 1 END
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
					--WHEN ccItem.strItem = 'Company Owned Shared Fees' AND ccSite.strSiteType = 'Company Owned Pass Thru' THEN ccSite.intFeeExpenseAccountId

					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru Fees' THEN ccSite.intCreditCardReceivableAccountId  
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru Fees' THEN ccSite.intFeeExpenseAccountId
					WHEN ccItem.strItem = 'Company Owned Shared Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru Fees' THEN ccSite.intFeeExpenseAccountId

					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru' THEN ccSite.intCreditCardReceivableAccountId  
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru' THEN ccSite.intFeeExpenseAccountId
					WHEN ccItem.strItem = 'Company Owned Shared Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru' THEN ccSite.intFeeExpenseAccountId
					
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned Shared Fees' THEN ccSite.intAccountId  
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees' THEN ccSite.intAccountId 
					WHEN ccItem.strItem = 'Company Owned Shared Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees' THEN ccSite.intFeeExpenseAccountId

			
					ELSE null END) AS intAccountId

				 ,(CASE WHEN ccItem.strItem = 'Dealer Site Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSiteDetail.dblNet 
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblGross 
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblFees
					
					WHEN ccItem.strItem = 'Dealer Site Gross' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblGross
					WHEN ccItem.strItem = 'Dealer Site Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100)
					WHEN ccItem.strItem = 'Dealer Site Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblFees - ROUND(ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100), 2)

					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned Pass Thru' THEN ccSiteDetail.dblGross 
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned Pass Thru' THEN ccSiteDetail.dblFees
					
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru Fees' THEN ccSiteDetail.dblGross 
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru Fees' THEN ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100)
					WHEN ccItem.strItem = 'Company Owned Shared Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru Fees' THEN ccSiteDetail.dblFees - ROUND(ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100), 2)

					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru' THEN ccSiteDetail.dblGross
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru' THEN ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100)
					WHEN ccItem.strItem = 'Company Owned Shared Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees/Pass Thru' THEN ccSiteDetail.dblFees - ROUND(ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100), 2)
						--note: company owned shared fees "Site Type" is not being used, added just in case it is needed
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned Shared Fees' THEN ccSiteDetail.dblGross
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees' THEN ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100)
					WHEN ccItem.strItem = 'Company Owned Shared Fees' AND ccSite.strSiteType = 'Company Owned Shared Fees' THEN ccSiteDetail.dblFees - ROUND(ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100), 2)
					ELSE null END) AS dblCost
			FROM tblCCSiteHeader ccSiteHeader
			LEFT JOIN tblCCSiteDetail ccSiteDetail ON ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
			LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
			LEFT JOIN @CCRItemToAPItem ccItem ON ccItem.intSiteHeaderId = ccSiteHeader.intSiteHeaderId 
			WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId --and ccSiteHeader.strApType <> 'Cash Deposited'
			) A  
		WHERE intAccountId IS NOT NULL AND dblCost != 0
		GROUP BY  intAccountId, intSiteDetailId, strItem 

		IF (SELECT SUM(dblCost) FROM @Voucher WHERE strMiscDescription = 'Dealer Site Net') >= 0 
		BEGIN
			UPDATE @Voucher SET dblQuantityToBill = -1, dblCost = dblCost * -1 WHERE dblCost < 0
		END
		ELSE
		BEGIN
			UPDATE @Voucher SET dblCost = dblCost * -1, intTransactionType = 1 WHERE dblCost < 0
		END

		-- 1099K Adjustment
		DECLARE @strInvalidCustomer NVARCHAR(2000) = NULL
		DECLARE @strNo1099Setup NVARCHAR(2000) = NULL

		DECLARE @dtmDate1099K DATETIME = NULL, @dtmVoucherDate1099K DATETIME = NULL, @intCustomerId1099K INT = NULL, @intShipToId1099K INT = NULL
		, @strVendorOrderNumber1099K NVARCHAR(100) = NULL, @intAccountId INT = NULL, @intLocationId1099K INT = NULL
		, @intCCSiteDetailId1099K INT = NULL, @strMiscDescription1099K NVARCHAR(500) = NULL, @dblCost1099K NUMERIC(18,6) = NULL
		, @dblQuantityToBill1099K NUMERIC(18,6) = NULL, @Vendor1099K INT = NULL
		, @strCustomerName NVARCHAR(200) = NULL, @str1099Form NVARCHAR(100) = NULL

		DECLARE @Cursor1099KTran AS CURSOR
		SET @Cursor1099KTran = CURSOR FOR 
		SELECT V.dtmDate
			, V.dtmVoucherDate
			, S.intCustomerId	
			, V.intShipToId
			, V.strVendorOrderNumber
			, V.intAccountId
			, V.intLocationId
			, V.intCCSiteDetailId
			, V.strMiscDescription
			, V.dblCost
			, V.dblQuantityToBill
			, ET.[Vendor]
			, ET.strEntityName
			, E.str1099Form
		FROM @Voucher V INNER JOIN tblCCSiteDetail SD ON SD.intSiteDetailId = V.intCCSiteDetailId
		INNER JOIN tblCCSite S ON S.intSiteId = SD.intSiteId
		LEFT JOIN vyuEMEntityBasicWithType ET ON ET.intEntityId = S.intCustomerId
		LEFT JOIN tblEMEntity E ON E.intEntityId = S.intCustomerId
		WHERE strMiscDescription IN ('Dealer Site Gross', 'Dealer Site Net','Company Owned Gross')
		AND S.intCustomerId IS NOT NULL
		OPEN @Cursor1099KTran
		FETCH NEXT FROM @Cursor1099KTran INTO @dtmDate1099K, @dtmVoucherDate1099K, @intCustomerId1099K, @intShipToId1099K, @strVendorOrderNumber1099K, @intAccountId, @intLocationId1099K
			,@intCCSiteDetailId1099K, @strMiscDescription1099K, @dblCost1099K, @dblQuantityToBill1099K, @Vendor1099K, @strCustomerName, @str1099Form
		WHILE @@FETCH_STATUS = 0
		BEGIN	
			-- VALIDATE THE CUSTOMER
			IF(@Vendor1099K != 1) 
			BEGIN
				IF(ISNULL(@strInvalidCustomer,'') = '')
				BEGIN
					SET @strInvalidCustomer = @strCustomerName
				END
				ELSE
				BEGIN
					SET @strInvalidCustomer = @strInvalidCustomer + ', ' + @strCustomerName 
				END
			END
			ELSE
			BEGIN
				INSERT INTO @Voucher1099K (intTransactionType
					, dtmDate
					, dtmVoucherDate
					, intEntityVendorId
					, intShipToId
					, strVendorOrderNumber
					, intAccountId
					, intLocationId
					, intCCSiteDetailId
					, strMiscDescription
					, dblCost
					, dblQuantityToBill
					, ysnStage
					, dbl1099)
				VALUES(
					9
					, @dtmDate1099K
					, @dtmVoucherDate1099K
					, @intCustomerId1099K
					, @intShipToId1099K
					, @strVendorOrderNumber1099K
					, @intAccountId
					, @intLocationId1099K
					, @intCCSiteDetailId1099K
					, @strMiscDescription1099K
					, @dblCost1099K
					, @dblQuantityToBill1099K
					, 0
					, @dblCost1099K
				)
			END

			IF(ISNULL(@str1099Form,'') = '')
			BEGIN
				IF(ISNULL(@strNo1099Setup,'') = '')
				BEGIN
					SET @strNo1099Setup = @strCustomerName 
				END
				ELSE
				BEGIN
					SET @strNo1099Setup= @strNo1099Setup + ', ' + @strCustomerName 
				END
			END
					
			FETCH NEXT FROM @Cursor1099KTran INTO @dtmDate1099K, @dtmVoucherDate1099K, @intCustomerId1099K, @intShipToId1099K, @strVendorOrderNumber1099K, @intAccountId, @intLocationId1099K
			,@intCCSiteDetailId1099K, @strMiscDescription1099K, @dblCost1099K, @dblQuantityToBill1099K, @Vendor1099K, @strCustomerName, @str1099Form
		END
		CLOSE @Cursor1099KTran
		DEALLOCATE @Cursor1099KTran

		IF(ISNULL(@strInvalidCustomer, '') != '')
		BEGIN
			DECLARE @strMessage1099 NVARCHAR(4000) = 'Dealer Site ' + @strInvalidCustomer + ' must be setup as a Vendor in order for i21 to create the 1099 Adjustment entry.'
			RAISERROR(@strMessage1099, 16, 1)
		END

		IF(ISNULL(@strNo1099Setup, '') != '')
		BEGIN
			SET  @strNo1099Setup =  'Vendor ' + @strNo1099Setup + ' is missing its 1099 Form setup.'
		END
	
		IF EXISTS(SELECT TOP 1 1 FROM @Voucher)
		BEGIN
			
			IF(@apType <> 'Cash Deposited')  
			BEGIN
						EXEC [dbo].[uspAPCreateVoucher] 
						@voucherPayables = @Voucher
						,@userId = @userId
						,@error = @errorMessage OUTPUT
						,@createdVouchersId = @createdVouchersId OUTPUT

						IF(ISNULL(@errorMessage, '') != '')
						BEGIN
							SET @success = 0
							RAISERROR(@errorMessage,16,1)			
						END	

						EXEC [dbo].[uspAPPostBill]
						@post = @post
						,@recap = @recap
						,@isBatch = 0
						,@transactionType = 'Credit Card'
						,@param = @createdVouchersId
						,@userId = @userId
						,@success = @success OUTPUT
			END

			IF(@success = 1 OR @apType = 'Cash Deposited')  
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM @Voucher1099K)
				BEGIN
					EXEC [dbo].[uspAPCreateVoucher] 
					@voucherPayables = @Voucher1099K
					,@userId = @userId
					,@error = @errorMessage OUTPUT
					,@createdVouchersId = @created1099KVouchersId OUTPUT
				END

				IF(ISNULL(@errorMessage, '') = '')  
				BEGIN  
					SET @success = 1  
				END  
				
			END
			ELSE
			BEGIN
				SELECT TOP 1 @errorMessage = strMessage FROM tblAPPostResult WHERE intTransactionId = @createdVouchersId ORDER BY intId DESC
			END

			IF(ISNULL(@errorMessage, '') != '')
			BEGIN
				RAISERROR(@errorMessage,16,1)
			END	
			ELSE
			BEGIN
				-- WARNING MESSAGE FOR 1099K SETUP
				IF(ISNULL(@strNo1099Setup, '') != '')
				BEGIN
					SET @errorMessage = @strNo1099Setup
				END
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

			IF(@success = 1 OR @intTransactionType = 9)
			BEGIN
				BEGIN TRY
				-- DELETE AP
				EXEC [dbo].[uspAPDeleteVoucher]
					@intBillId = @intBillId
					,@UserId = @userId
					,@callerModule = 9
					SET @success = 1
				END TRY  
				BEGIN CATCH  
					SET @success = 0
					RAISERROR('Error deleting voucher!',16,1)
				END CATCH  
			END
			ELSE
			BEGIN
				IF (@intTransactionType != 9)
				BEGIN
					SELECT TOP 1 @errorMessage = strMessage FROM tblAPPostResult WHERE intTransactionId = @intBillId ORDER BY intId DESC
					RAISERROR(@errorMessage,16,1)
				END
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
