﻿CREATE PROCEDURE [dbo].[uspCCTransactionToAPBill]
	 @intSiteHeaderId	INT
	,@userId			INT	
	,@post				BIT
	,@recap				BIT
	,@success			BIT = NULL OUTPUT
	,@errorMessage NVARCHAR(MAX) = NULL OUTPUT
	,@createdBillId INT = NULL OUTPUT

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
			DECLARE @voucherDetailCC AS VoucherDetailCC
			DECLARE @shipTo INT
			DECLARE @dtmDate DATETIME
			DECLARE @ccdReference NVARCHAR(50)
			DECLARE @vendorId INT
				DECLARE @CCRItemToAPItem TABLE
				(
					intSiteHeaderId int, 
					strItem nvarchar(100)
				)

				INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Sites Net')
				INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Gross')
				INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Fees')
				INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Sites Shared Fees')

				SELECT @ccdReference = ccSiteHeader.strCcdReference
					, @dtmDate = ccSiteHeader.dtmDate
					, @shipTo = ccSiteHeader.intCompanyLocationId
					, @vendorId = ccVendorDefault.intVendorId
				FROM tblCCSiteHeader ccSiteHeader
				INNER JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
				WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId

			INSERT INTO @voucherDetailCC([intAccountId] 
				,[intSiteDetailId] 
				,[strMiscDescription] 
				,[dblCost]
				,[dblQtyReceived])
			SELECT [intAccountId] = intAccountId
				,[intSiteDetailId] = intSiteDetailId
				,[strMiscDescription] = strItem
				,[dblCost] = SUM(dblCost)
				,[dblQtyReceived]  = CASE WHEN strItem = 'Company Owned Fees' THEN -1 ELSE 1 END
			FROM(
			SELECT 
				 ccSiteDetail.intSiteDetailId
				 ,ccItem.strItem
				 ,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSite.intAccountId 
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intCreditCardReceivableAccountId  
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intFeeExpenseAccountId
					WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSite.intAccountId 
					WHEN ccItem.strItem = 'Dealer Sites Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSite.intFeeExpenseAccountId
					ELSE null END) AS intAccountId
				 ,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSiteDetail.dblNet 
					WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblGross 
					WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblFees
					WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblNet
					WHEN ccItem.strItem = 'Dealer Sites Shared Fees' AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblFees - (ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100))
					ELSE null END) AS dblCost
			FROM tblCCSiteHeader ccSiteHeader
			LEFT JOIN tblCCSiteDetail ccSiteDetail ON ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
			LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
			LEFT JOIN @CCRItemToAPItem ccItem ON ccItem.intSiteHeaderId = ccSiteHeader.intSiteHeaderId 
			WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId) A
			WHERE intAccountId IS NOT NULL AND dblCost != 0
			GROUP BY  intAccountId, intSiteDetailId, strItem 

			DECLARE @intCountDetail INT = 0

			SELECT @intCountDetail = COUNT(*) FROM @voucherDetailCC

			IF(@intCountDetail > 0)
			BEGIN
				EXEC [dbo].[uspAPCreateBillData]
					 @userId	= @userId
					,@vendorId = @vendorId
					,@type = 3	
					,@shipTo = @shipTo
					,@vendorOrderNumber = @ccdReference
					,@voucherDate = @dtmDate
					,@voucherDetailCC = @voucherDetailCC
					,@billId = @createdBillId OUTPUT

				UPDATE tblAPBill SET strComment = @ccdReference WHERE intBillId = @createdBillId

				EXEC [dbo].[uspAPPostBill]
					@post = @post
					,@recap = @recap
					,@isBatch = 0
					,@param = @createdBillId
					,@userId = @userId
					,@success = @success OUTPUT
			END

		END
	ELSE IF (@post = 0)
		BEGIN
			
			DECLARE @billId	INT = NULL
			DECLARE @paymentTrans INT = NULL
			
			--Find AP Info
			SELECT @billId = C.intBillId FROM tblCCSiteHeader A 
			INNER JOIN tblCCSiteDetail B ON B.intSiteHeaderId = A.intSiteHeaderId
			INNER JOIN tblAPBillDetail C ON C.intCCSiteDetailId = B.intSiteDetailId
			WHERE A.intSiteHeaderId = @intSiteHeaderId
			GROUP BY C.intBillId

			--SELECT @isPaid = ysnPaid FROM tblAPBill WHERE intBillId = @billId
			SELECT @paymentTrans = COUNT(A.intPaymentId) FROM tblAPPayment A JOIN
			tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId 
			WHERE intBillId = @billId

			IF(@billId IS NOT NULL)
			BEGIN

				IF(@paymentTrans > 0)
					BEGIN
						RAISERROR('Cannot unpost this transaction. There is already payment made on the associated Voucher/Invoice.', 16, 1)
					END
				ELSE
					BEGIN
						EXEC [dbo].[uspAPPostBill]
							@post = @post
							,@recap = 0
							,@isBatch = 0
							,@param = @billId
							,@userId = @userId
							,@success = @success OUTPUT

						--DELETE Bill Transaction
						DELETE FROM tblAPBill WHERE intBillId = 
						(SELECT DISTINCT intBillId 
							FROM tblAPBillDetail A
						JOIN  tblCCSiteDetail B ON A.intCCSiteDetailId = B.intSiteDetailId
							WHERE B.intSiteHeaderId = @intSiteHeaderId)
					END
			END

		END
END
