CREATE PROCEDURE uspAPBalanceCheck
(
	@startDate DATETIME = NULL
	,@endDate DATETIME = NULL
	,@intInterval INT = NULL
	,@type INT = 0
)
AS

DECLARE @intPayablesCategory INT, @prepaymentCategory INT;
DECLARE @APglBalance DECIMAL(18,6) = 0, @APBalance DECIMAL(18,6) = 1;
DECLARE @beginDate DATETIME = '1/1/1900', @checkStartDate DATETIME, @checkEndDate DATETIME, @currentEndDate DATETIME;
DECLARE @results TABLE(strDateRange NVARCHAR(200), dblAPGLBalance DECIMAL(18,6), dblAPBalance DECIMAL(18,6), dblDifference DECIMAL(18,6));
DECLARE @interval INT = @intInterval;
DECLARE @lastDayOfMonth INT;
DECLARE @nextCurrentEndDate DATETIME;
DECLARE @isOriginTransaction INT = @type;

SET @checkStartDate = ISNULL(@startDate,GETDATE());
SET @checkEndDate = ISNULL(@endDate,GETDATE());

IF @checkEndDate < @checkStartDate
BEGIN
	RAISERROR('Invalid date start and end', 16, 1);
END

--PRINT @checkStartDate
--PRINT @currentEndDate
--PRINT @checkEndDate

--SETUP THE INITIAL START DATE, END DATE AND CURRENT END DATE
IF @interval = 1 --YEARLY
BEGIN 
	IF YEAR(@checkStartDate) = YEAR(@checkEndDate) -- if on same year
	BEGIN
		SET @checkStartDate = '1/1/' + CAST(YEAR(@checkStartDate) AS NVARCHAR)
		SET @checkEndDate = '12/31/' + CAST(YEAR(@checkStartDate) AS NVARCHAR)
	END
	ELSE
	BEGIN
		SET @checkStartDate = '1/1/' + CAST(YEAR(@checkStartDate) AS NVARCHAR)
		SET @checkEndDate = '12/31/' + CAST(YEAR(@checkEndDate) AS NVARCHAR)
	END
	--initial
	SET @currentEndDate = '12/31/' + CAST(YEAR(@checkStartDate) -1 AS NVARCHAR);
END
ELSE IF @interval = 2 --MONTHLY
BEGIN
	IF MONTH(@checkStartDate) = MONTH(@checkEndDate) AND YEAR(@checkStartDate) = YEAR(@checkEndDate) --if on same year and month
	BEGIN
		SET @lastDayOfMonth = DATEPART(DAY,DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @checkStartDate) + 1, 0))) --get the last day of the starting date
		SET @checkStartDate = CAST(MONTH(@checkStartDate) AS NVARCHAR) + '/1/' + CAST(YEAR(@checkStartDate) AS NVARCHAR)
		SET @checkEndDate = CAST(MONTH(@checkStartDate) AS NVARCHAR) + '/' + CAST(@lastDayOfMonth AS NVARCHAR) + '/' + CAST(YEAR(@checkStartDate) AS NVARCHAR)
	END
	ELSE
	BEGIN
		SET @lastDayOfMonth = DATEPART(DAY,DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @checkEndDate) + 1, 0))) --get the last day of the end date
		SET @checkStartDate = CAST(MONTH(@checkStartDate) AS NVARCHAR) + '/1/' + CAST(YEAR(@checkStartDate) AS NVARCHAR)
		SET @checkEndDate = CAST(MONTH(@checkEndDate) AS NVARCHAR) + '/' + CAST(@lastDayOfMonth AS NVARCHAR) + '/' + CAST(YEAR(@checkEndDate) AS NVARCHAR)
	END
	--initial
	SET @lastDayOfMonth = DATEPART(DAY,DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @checkStartDate) + 1, 0))) --get the last day of the starting date
	SET @currentEndDate = DATEADD(DAY, -1, @checkStartDate);
END
ELSE IF @interval = 3
BEGIN
	SET @currentEndDate = DATEADD(DAY, -1, @checkStartDate)
END
ELSE
BEGIN
	SET @currentEndDate = '1/1/1900'; --set this to any date not equal to current date
END

SELECT @intPayablesCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'
SELECT @prepaymentCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments'


WHILE (@checkEndDate != @currentEndDate)
BEGIN

	IF @interval = 1
	BEGIN
		SET @currentEndDate = DATEADD(YEAR, 1, @currentEndDate);
	END
	ELSE IF @interval = 2
	BEGIn
		SET @nextCurrentEndDate = DATEADD(MONTH, 1, @currentEndDate);
		SET @lastDayOfMonth = DATEPART(DAY,DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @nextCurrentEndDate) + 1, 0))) --get the last day of the starting date
		SET @currentEndDate = CAST(MONTH(@nextCurrentEndDate) AS NVARCHAR) + '/' + CAST(@lastDayOfMonth AS NVARCHAR) + '/' + CAST(YEAR(@nextCurrentEndDate) AS NVARCHAR);

		--IF @lastDayOfMonth = 29 --IF LEAP YEAR
		--BEGIN
		--	SET @currentEndDate = '3/31/' + CAST(YEAR(@currentEndDate) AS NVARCHAR);
		--END
		--ELSE
		--BEGIN
		--	SET @currentEndDate = DATEADD(MONTH, 1, @currentEndDate);
		--END
	END
	ELSE IF @intInterval = 3
	BEGIN
		SET @currentEndDate = DATEADD(DAY, 1, @currentEndDate);
	END
	ELSE
	BEGIN
		SET @currentEndDate = @checkEndDate;
	END

	PRINT @beginDate
	PRINT @currentEndDate

	SELECT @APglBalance = SUM(dblBalance)
	FROM (
		SELECT
			B.strAccountId,
			CAST(SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit, 0)) AS DECIMAL(18,2)) AS dblBalance
		FROM tblGLDetail A
		INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
		INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
		WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
		AND A.ysnIsUnposted = 0
		AND CONVERT(DATE, CAST(A.dtmDate AS CHAR(12)), 112) BETWEEN @beginDate AND @currentEndDate
		-- AND 1 = (CASE WHEN @isOriginTransaction = 0 THEN 1
		-- 				WHEN @isOriginTransaction = 1 
		-- 						THEN (CASE WHEN A.strModuleName != 'Accounts Payable' THEN 1 ELSE 0 END)
		-- 				WHEN @isOriginTransaction = 2
		-- 						THEN (CASE WHEN A.strModuleName = 'Accounts Payable' 
		-- 									--AND NOT EXISTS (SELECT 1 FROM tblAPBill E WHERE E.intBillId = A.intJournalLineNo AND E.strBillId = A.strTransactionId AND E.ysnOrigin = 0)
		-- 								THEN 1 ELSE 0 END)
		-- 			END)
		GROUP BY B.strAccountId
	) tmp
	--WHERE dblBalance != 0

	PRINT @APglBalance

	SELECT @APBalance = SUM(dblBalance)
	FROM (
		SELECT 
			A.intBillId
			,CAST(SUM(A.dblTotal) + SUM(A.dblInterest) - SUM(A.dblAmountPaid) - SUM(A.dblDiscount) AS DECIMAL(18,2)) AS dblBalance
		FROM (
			SELECT
				 B1.dtmDate
				,B1.intBillId
				,B1.strBillId
				,B1.dblAmountPaid
				,B1.dblTotal
				,B1.dblAmountDue
				,B1.dblWithheld
				,B1.dblDiscount
				,B1.dblInterest
				,B1.dblPrepaidAmount
				,B1.strVendorId
				,B1.strVendorIdName
				,B1.dtmDueDate
				,B1.ysnPosted
				,B1.ysnPaid
				,B1.intAccountId
				,B1.strClass
			FROM vyuAPPayables B1
			INNER JOIN tblAPBill B ON B1.intBillId = B.intBillId
			WHERE CONVERT(DATE, CAST(B1.dtmDate AS CHAR(12)), 112) BETWEEN @beginDate AND @currentEndDate
			-- AND 1 = (CASE WHEN @isOriginTransaction = 0 THEN 1
			-- 		WHEN @isOriginTransaction = 1 
			-- 				THEN (CASE WHEN B.ysnOrigin = 1 AND
			-- 							NOT EXISTS (SELECT 1 FROM tblGLDetail D WHERE D.strTransactionId = B.strBillId AND D.intTransactionId = B.intBillId AND D.ysnIsUnposted = 0)
			-- 							THEN 1 
			-- 							ELSE 0 END)
			-- 		WHEN @isOriginTransaction = 2
			-- 				THEN (CASE WHEN B.ysnOrigin = 0  
			-- 						OR (B.ysnOrigin = 1 AND EXISTS (SELECT 1 FROM tblGLDetail D WHERE D.strTransactionId = B.strBillId AND D.intTransactionId = B.intBillId AND D.ysnIsUnposted = 0)) --posted in i21
			-- 						THEN 1 ELSE 0 END)
			-- 		END)
			UNION ALL
			SELECT
				B1.dtmDate
				,B1.intBillId
				,B1.strBillId
				,B1.dblAmountPaid
				,B1.dblTotal
				,B1.dblAmountDue
				,B1.dblWithheld
				,B1.dblDiscount
				,B1.dblInterest
				,B1.dblPrepaidAmount
				,B1.strVendorId
				,B1.strVendorIdName
				,B1.dtmDueDate
				,B1.ysnPosted
				,B1.ysnPaid
				,B1.intAccountId
				,B1.strClass
			FROM vyuAPPrepaidPayables B1
			INNER JOIN tblAPBill B ON B1.intBillId = B.intBillId
			WHERE CONVERT(DATE, CAST(B1.dtmDate AS CHAR(12)), 112) BETWEEN @beginDate AND @currentEndDate
			-- AND 1 = (CASE WHEN @isOriginTransaction = 0 THEN 1
			-- 		WHEN @isOriginTransaction = 1 
			-- 				THEN (CASE WHEN B.ysnOrigin = 1 AND
			-- 							NOT EXISTS (SELECT 1 FROM tblGLDetail D WHERE D.strTransactionId = B.strBillId AND D.intTransactionId = B.intBillId AND D.ysnIsUnposted = 0)
			-- 							THEN 1 
			-- 							ELSE 0 END)
			-- 		WHEN @isOriginTransaction = 2
			-- 				THEN (CASE WHEN B.ysnOrigin = 0  
			-- 						OR (B.ysnOrigin = 1 AND EXISTS (SELECT 1 FROM tblGLDetail D WHERE D.strTransactionId = B.strBillId AND D.intTransactionId = B.intBillId AND D.ysnIsUnposted = 0)) --posted in i21
			-- 						THEN 1 ELSE 0 END)
			-- 		END)
			UNION ALL
			SELECT
				B1.dtmDate
				,B1.intBillId
				,B1.strBillId
				,B1.dblAmountPaid
				,B1.dblTotal
				,B1.dblAmountDue
				,B1.dblWithheld
				,B1.dblDiscount
				,B1.dblInterest
				,B1.dblPrepaidAmount
				,B1.strVendorId
				,B1.strVendorIdName
				,B1.dtmDueDate
				,B1.ysnPosted
				,B1.ysnPaid
				,B1.intAccountId
				,B1.strClass
			FROM vyuAPPayablesForeign B1
			INNER JOIN tblAPBill B ON B1.intBillId = B.intBillId
			WHERE CONVERT(DATE, CAST(B1.dtmDate AS CHAR(12)), 112) BETWEEN @beginDate AND @currentEndDate
			-- AND 1 = (CASE WHEN @isOriginTransaction = 0 THEN 1
			-- 		WHEN @isOriginTransaction = 1 
			-- 				THEN (CASE WHEN B.ysnOrigin = 1 AND
			-- 							NOT EXISTS (SELECT 1 FROM tblGLDetail D WHERE D.strTransactionId = B.strBillId AND D.intTransactionId = B.intBillId AND D.ysnIsUnposted = 0)
			-- 							THEN 1 
			-- 							ELSE 0 END)
			-- 		WHEN @isOriginTransaction = 2
			-- 				THEN (CASE WHEN B.ysnOrigin = 0  
			-- 						OR (B.ysnOrigin = 1 AND EXISTS (SELECT 1 FROM tblGLDetail D WHERE D.strTransactionId = B.strBillId AND D.intTransactionId = B.intBillId AND D.ysnIsUnposted = 0)) --posted in i21
			-- 						THEN 1 ELSE 0 END)
			-- 		END)
		) A
		INNER JOIN tblAPBill B ON B.intBillId = A.intBillId
		INNER JOIN tblGLAccount C ON B.intAccountId = C.intAccountId
		GROUP BY A.intBillId
		UNION ALL
		SELECT
			A.intInvoiceId
			,CAST(SUM(A.dblTotal) + SUM(A.dblInterest) - SUM(A.dblAmountPaid) - SUM(A.dblDiscount) AS DECIMAL(18,2)) AS dblBalance
		FROM vyuAPSalesForPayables A
		LEFT JOIN dbo.vyuGLAccountDetail D ON  A.intAccountId = D.intAccountId
		WHERE D.strAccountCategory = 'AP Account' --there are old data where cash refund have been posted to non AP account
		AND CONVERT(DATE, CAST(A.dtmDate AS CHAR(12)), 112) BETWEEN @beginDate AND @currentEndDate
		GROUP BY A.intInvoiceId
		--WHERE 1 = (CASE WHEN @isOriginTransaction = 0 THEN 1
		--				WHEN @isOriginTransaction = 1 
		--						THEN (CASE WHEN B.ysnOrigin = 1 THEN 1 ELSE 0 END)
		--				WHEN @isOriginTransaction = 2
		--						THEN (CASE WHEN B.ysnOrigin = 0 
		--								OR EXISTS (SELECT 1 FROM tblGLDetail D WHERE D.strTransactionId = B.strBillId AND D.intTransactionId = B.intBillId AND D.ysnIsUnposted = 0) --posted in i21
		--								THEN 1 ELSE 0 END)
				--END)
		--GROUP BY C.strAccountId
	) tmp

	PRINT @APBalance

	INSERT INTO @results
	SELECT CONVERT(VARCHAR(10), @beginDate, 110) + ' / ' + CONVERT(VARCHAR(10), @currentEndDate, 110), @APglBalance, @APBalance, @APglBalance - @APBalance

END

SELECT * FROM @results
GO

--EXEC uspAPBalanceCheck '2/15/2004', '2/15/2016', 1, 0
