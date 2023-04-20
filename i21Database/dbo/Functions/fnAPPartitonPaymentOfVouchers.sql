﻿CREATE FUNCTION [dbo].[fnAPPartitonPaymentOfVouchers]
(
	@voucherIds AS Id READONLY,
	@invoiceIds AS Id READONLY
)
RETURNS TABLE AS RETURN
(
	SELECT
		partitionedVouchers.*
		,DENSE_RANK() OVER(ORDER BY intEntityVendorId, intPayToAddressId, intPayFromBankAccountId, intPayToBankAccountId, intPaymentId) intPartitionId
	FROM (
		
		SELECT
			trans.intBillId
			,trans.intInvoiceId
			,trans.intEntityVendorId
			,trans.intPayToAddressId
			,trans.intPayFromBankAccountId
			,trans.intPayToBankAccountId
			,DENSE_RANK() OVER(ORDER BY trans.intEntityVendorId, trans.intPayToAddressId, trans.intPayFromBankAccountId, trans.intPayToBankAccountId DESC) AS intPaymentId
			,SUM(dblTempPayment)
					OVER(PARTITION BY trans.intEntityVendorId, trans.intPayToAddressId, trans.intPayFromBankAccountId, trans.intPayToBankAccountId) AS dblTempPayment
			,SUM(dblTempWithheld)
				OVER(PARTITION BY trans.intEntityVendorId, trans.intPayToAddressId, trans.intPayFromBankAccountId, trans.intPayToBankAccountId) AS dblTempWithheld
			,trans.strTempPaymentInfo
		FROM (
			SELECT
				voucher.intBillId
				,intInvoiceId = NULL
				,voucher.intEntityVendorId
				,voucher.intPayToAddressId
				,voucher.intPayFromBankAccountId
				,voucher.intPayToBankAccountId
				--DENSE_RANK() OVER(ORDER BY voucher.intEntityVendorId, voucher.intPayToAddressId, voucher.intPayFromBankAccountId, voucher.intPayToBankAccountId DESC) AS intPaymentId
				-- ,SUM(ISNULL((CASE WHEN (voucher.intTransactionType NOT IN (1, 2, 13, 14) OR (voucher.intTransactionType IN (2,13) AND voucher.ysnPrepayHasPayment = 1))
				-- 				THEN -ISNULL(payScheds.dblPayment, voucher.dblTempPayment) --use the payment sched payment amount to compute the total payment
				-- 				ELSE ISNULL(payScheds.dblPayment, voucher.dblTempPayment)
				-- 			END), 0))
				-- 			OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId, voucher.intPayFromBankAccountId, voucher.intPayToBankAccountId) AS dblTempPayment
				,ISNULL((CASE WHEN (voucher.intTransactionType NOT IN (1, 2, 13, 14) OR (voucher.intTransactionType IN (2,13) AND voucher.ysnPrepayHasPayment = 1))
								THEN -ISNULL(payScheds.dblPayment, voucher.dblTempPayment) --use the payment sched payment amount to compute the total payment
								ELSE ISNULL(payScheds.dblPayment, voucher.dblTempPayment)
							END), 0) AS dblTempPayment
				-- ,SUM(ISNULL((CASE WHEN (voucher.intTransactionType NOT IN (1, 2, 13, 14) OR (voucher.intTransactionType IN (2,13) AND voucher.ysnPrepayHasPayment = 1))
				-- 				THEN 
				-- 					-voucher.dblTempWithheld 
				-- 				ELSE voucher.dblTempWithheld 
				-- 				END), 0))
				-- 		OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId, voucher.intPayFromBankAccountId, voucher.intPayToBankAccountId) AS dblTempWithheld
				,ISNULL((CASE WHEN (voucher.intTransactionType NOT IN (1, 2, 13, 14) OR (voucher.intTransactionType IN (2,13) AND voucher.ysnPrepayHasPayment = 1))
								THEN 
									-voucher.dblTempWithheld 
								ELSE voucher.dblTempWithheld 
								END), 0) AS dblTempWithheld
				,NULLIF(voucher.strTempPaymentInfo,'') strTempPaymentInfo
			FROM tblAPBill voucher
			INNER JOIN @voucherIds ids 
				ON voucher.intBillId = ids.intId
			INNER JOIN tblAPVendor vendor 
				ON voucher.intEntityVendorId = vendor.intEntityId
			OUTER APPLY
			(
				SELECT SUM(sched.dblPayment - sched.dblDiscount) dblPayment FROM tblAPVoucherPaymentSchedule sched
				WHERE sched.intBillId = voucher.intBillId AND sched.ysnPaid = 0 AND sched.ysnReadyForPayment = 1
			) payScheds
			-- LEFT JOIN tblAPVoucherPaymentSchedule paySched
			-- 	ON paySched.intBillId = voucher.intBillId AND paySched.ysnPaid = 0 AND paySched.ysnReadyForPayment = 1
			WHERE 
				vendor.ysnOneBillPerPayment = 0
			AND voucher.ysnPosted = 1
			AND voucher.ysnPaid = 0
			-- AND 1 = (CASE WHEN voucher.intTransactionType IN (2,13) AND voucher.ysnPrepayHasPayment = 0 THEN 0 ELSE 1 END) --do not include basis/prepaid w/o actual payment
			-- UNION ALL
			-- --BASIS AND PREPAID WITH NO ACTUAL PAYMENT YET
			-- SELECT
			-- 	voucher.intBillId
			-- 	,voucher.intPayToAddressId
			-- 	,voucher.intEntityVendorId
			-- 	,DENSE_RANK() OVER(ORDER BY voucher.intEntityVendorId, voucher.intPayToAddressId DESC) AS intPaymentId
			-- 	,SUM(ISNULL(voucher.dblTempPayment, 0))
			-- 			OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId) AS dblTempPayment
			-- 	,SUM(ISNULL(voucher.dblTempWithheld, 0))
			-- 			OVER(PARTITION BY voucher.intEntityVendorId, voucher.intPayToAddressId) AS dblTempWithheld
			-- 	,voucher.strTempPaymentInfo
			-- FROM tblAPBill voucher
			-- INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId
			-- INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
			-- WHERE 
			-- 	voucher.intTransactionType IN (2, 13)
			-- AND vendor.ysnOneBillPerPayment = 0
			-- AND voucher.ysnPosted = 1
			-- AND voucher.ysnPaid = 0
			-- AND voucher.ysnPrepayHasPayment = 0
			UNION ALL
			SELECT
				NULL
				,invoice.intInvoiceId
				,invoice.intEntityCustomerId
				,invoice.intBillToLocationId
				,vendor.intPayFromBankAccountId
				,ISNULL(invoice.intPayToCashBankAccountId, invoice.intDefaultPayToBankAccountId)
				--,ROW_NUMBER() OVER(ORDER BY invoice.intEntityCustomerId DESC) AS intPaymentId
				,ISNULL((CASE WHEN invoice.strTransactionType NOT IN ('Cash Refund','Credit Memo') 
						THEN -invoice.dblAmountDue ELSE invoice.dblAmountDue END), 0) AS dblTempPayment
				,0 AS dblTempWithheld
				,NULL
			FROM tblARInvoice invoice
			INNER JOIN @invoiceIds ids ON invoice.intInvoiceId = ids.intId
			INNER JOIN tblAPVendor vendor ON invoice.intEntityCustomerId = vendor.intEntityId
			WHERE 
				vendor.ysnOneBillPerPayment = 0
			AND invoice.ysnPosted = 1
			AND invoice.ysnPaid = 0
		) trans
		UNION ALL
		--ALL TRANSACTIONS WHICH VENDOR IS ONE BILL PER PAYMENT
		SELECT
			voucher.intBillId
			,NULL
			,voucher.intEntityVendorId
			,voucher.intPayToAddressId
			,voucher.intPayFromBankAccountId
			,voucher.intPayToBankAccountId
			--,voucher.intShipToId
			,ROW_NUMBER() OVER(ORDER BY voucher.intEntityVendorId DESC) AS intPaymentId
			,ISNULL((CASE WHEN voucher.intTransactionType NOT IN (1, 14) 
					THEN -voucher.dblTempPayment ELSE voucher.dblTempPayment END), 0) AS dblTempPayment
			,ISNULL((CASE WHEN voucher.intTransactionType NOT IN (1, 14) 
					THEN -voucher.dblTempWithheld ELSE voucher.dblTempWithheld END), 0) AS dblTempWithheld
			,NULLIF(voucher.strTempPaymentInfo,'')
		FROM tblAPBill voucher
		INNER JOIN @voucherIds ids ON voucher.intBillId = ids.intId
		INNER JOIN tblAPVendor vendor ON voucher.intEntityVendorId = vendor.intEntityId
		WHERE 
			vendor.ysnOneBillPerPayment = 1
		AND voucher.ysnPosted = 1
		AND voucher.ysnPaid = 0
		--we will exlcude basis and prepaid that do not have actual payment because we already did that on second union
		AND 1 = CASE WHEN voucher.intTransactionType IN (2, 13) AND voucher.ysnPrepayHasPayment = 1 THEN 0 ELSE 1 END 
		UNION ALL
		--ALL TRANSACTIONS WHICH VENDOR IS ONE BILL PER PAYMENT
		SELECT
			NULL
			,invoice.intInvoiceId
			,invoice.intEntityCustomerId
			,invoice.intBillToLocationId
			,vendor.intPayFromBankAccountId
			,ISNULL(invoice.intPayToCashBankAccountId, invoice.intDefaultPayToBankAccountId)
			,ROW_NUMBER() OVER(ORDER BY invoice.intEntityCustomerId DESC) AS intPaymentId
			,ISNULL((CASE WHEN invoice.strTransactionType NOT IN ('Cash Refund','Credit Memo') 
					THEN -invoice.dblAmountDue ELSE invoice.dblAmountDue END), 0) AS dblTempPayment
			,0 AS dblTempWithheld
			,NULL
		FROM tblARInvoice invoice
		INNER JOIN @invoiceIds ids ON invoice.intInvoiceId = ids.intId
		INNER JOIN tblAPVendor vendor ON invoice.intEntityCustomerId = vendor.intEntityId
		WHERE 
			vendor.ysnOneBillPerPayment = 1
		AND invoice.ysnPosted = 1
		AND invoice.ysnPaid = 0
		--we will exlcude basis and prepaid that do not have actual payment because we already did that on second union
	) partitionedVouchers
)
