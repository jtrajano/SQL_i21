CREATE FUNCTION [dbo].[fnAPVendorInquiryFinancialInfo]
(
	@entityId INT
)
RETURNS @returnTable TABLE(
	intEntityVendorId INT PRIMARY KEY,
	strLastVoucher NVARCHAR(50),
	intLastBillId INT,
	dtmLastPaymentDate DATETIME,
	intLastPaymentId INT,
	dblYTDVouchers DECIMAL(18,6),
	dblYTDPayments DECIMAL(18,6)
)
AS
BEGIN

	DECLARE @dayOfMonth TINYINT = 1;
	DECLARE @month TINYINT = 1;
	DECLARE @year INT = YEAR(GETDATE());

	DECLARE @beginDate DATETIME;
	SET @beginDate = DATEADD(DAY, @dayOfMonth - 1, DateADD(MONTH, @month - 1, DATEADD(YEAR, @year-1900,0)));
	
	SET @dayOfMonth = 31;
	SET @month = 12;
	
	DECLARE @endDateDate DATETIME = GETDATE();
	--SET @endDateDate = DATEADD(DAY, @dayOfMonth - 1, DateADD(MONTH, @month - 1, DATEADD(YEAR, @year-1900,0)));

	INSERT INTO @returnTable
	SELECT
		@entityId AS intEntityVendorId
		,lastVoucher.strLastVoucher
		,lastVoucher.intBillId AS intLastBillId
		,lastPayment.dtmLastPaymentDate
		,lastPayment.intPaymentId AS intLastPaymentId
		,voucherTotal.dblYTDVouchers
		,paymentTotal.dblYTDPayments
	FROM (
		SELECT 
			TOP 1 
			A.strBillId AS strLastVoucher
			,A.intBillId
		FROM tblAPBill A
		WHERE A.intEntityVendorId = @entityId AND A.ysnPosted = 1
		ORDER BY dtmDate DESC
	) lastVoucher
	OUTER APPLY (
		SELECT
			TOP 1
			payment.dtmDatePaid AS dtmLastPaymentDate
			,payment.intPaymentId
		FROM tblAPPayment payment
		WHERE payment.intEntityVendorId = @entityId AND payment.ysnPosted = 1
		ORDER BY dtmDatePaid DESC
	) lastPayment
	OUTER APPLY (
		SELECT
			SUM(voucher.dblTotal) AS dblYTDVouchers
		FROM tblAPBill voucher
		WHERE voucher.intEntityVendorId = @entityId AND voucher.ysnPosted = 1
		--AND DATEADD(dd, DATEDIFF(dd, 0, voucher.dtmDate), 0) BETWEEN @beginDate AND @endDateDate
		AND DATEADD(dd, DATEDIFF(dd, 0, voucher.dtmDate), 0) <= @endDateDate
	) voucherTotal
	OUTER APPLY  (
		SELECT
			SUM(dblAmountPaid) AS dblYTDPayments
		FROM tblAPPayment payment
		WHERE payment.intEntityVendorId = @entityId AND payment.ysnPosted = 1
		--AND DATEADD(dd, DATEDIFF(dd, 0, payment.dtmDatePaid), 0) BETWEEN @beginDate AND @endDateDate
		AND DATEADD(dd, DATEDIFF(dd, 0, payment.dtmDatePaid), 0) <= @endDateDate
	) paymentTotal
	RETURN;
END