CREATE PROCEDURE [dbo].[uspAPImportVoucherLassusSas]
	@file NVARCHAR(500),
	@userId INT,
	@intVendorId INT,
	@importLogId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @sql NVARCHAR(MAX);
DECLARE @path NVARCHAR(500);
DECLARE @errorFile NVARCHAR(500);
DECLARE @lastIndex INT;
DECLARE @vouchers TABLE(intBillId INT);
DECLARE @totalVoucherCreated INT;
DECLARE @totalIssues INT;

-- SET @lastIndex = (LEN(@file)) -  CHARINDEX('/', REVERSE(@file)) 
-- SET @path = SUBSTRING(@file, 0, @lastindex + 1)
SET @errorFile = REPLACE(@file, 'csv', 'txt');

DELETE FROM tblAPImportVoucherLassusSas

SET @sql = 'BULK INSERT tblAPImportVoucherLassusSas FROM ''' + @file + ''' WITH
        (
        FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		ROWS_PER_BATCH = 10000, 
		FIRSTROW = 1,
		TABLOCK,
		ERRORFILE = ''' + @errorFile + '''
        )'

EXEC(@sql)

DECLARE @voucherTotal DECIMAL(18,2);

SELECT
	DENSE_RANK() OVER(ORDER BY A.strInvoiceNumber, C.intEntityId) AS intPartitionId,
	intEntityVendorId	=	C.intEntityId,
	dtmDate				=	CAST(A.dtmDate AS DATETIME),
    dblQuantityToBill	=	1,
    dblCost				=	ABS(A.dblAmount),
	intAccountId		=	accnt.intAccountId,
	strGLAccount		=	A.strGLAccount,
	strVendorOrderNumber=	A.strInvoiceNumber
INTO #tmpConvertedLassusSasData
FROM tblAPImportVoucherLassusSas A
CROSS APPLY tblAPVendor C
LEFT JOIN tblGLAccount accnt ON accnt.strAccountId = A.strGLAccount
WHERE 
	C.intEntityId = @intVendorId

DECLARE @voucherPayables AS VoucherPayable
INSERT INTO @voucherPayables
(
	intPartitionId,
    intEntityVendorId,
    intTransactionType,
	dtmDate,
	dblOrderQty,
    dblQuantityToBill,
    dblCost,
	intAccountId,
	strVendorOrderNumber
)
SELECT
	intPartitionId,
    intEntityVendorId,
    1,
	dtmDate,
	dblQuantityToBill,
    dblQuantityToBill,
    dblCost,
	intAccountId,
	strVendorOrderNumber
FROM #tmpConvertedLassusSasData A
WHERE 
	A.intAccountId > 0

DECLARE @createdVoucher NVARCHAR(MAX);
EXEC uspAPCreateVoucher @voucherPayables = @voucherPayables, @userId = @userId, @throwError = 1, @createdVouchersId = @createdVoucher OUT

INSERT INTO @vouchers SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@createdVoucher) WHERE intID > 0

SET @totalVoucherCreated = @@ROWCOUNT;

SELECT @totalIssues = COUNT(*)
FROM #tmpConvertedLassusSasData A
WHERE 
	A.intAccountId IS NULL

--LOG SUCCESS
DECLARE @logId INT;
IF @totalVoucherCreated > 0
BEGIN
	INSERT INTO tblAPImportLog
	(
		strEvent,
		strIrelySuiteVersion,
		intEntityId,
		dtmDate,
		intSuccessCount,
		intErrorCount
	)
	SELECT
		CASE 
			WHEN @totalIssues > 0 THEN 'Some voucher(s) successfullly imported from CSV'
		ELSE
			'Successfullly imported voucher(s) from CSV'
		END,
		(SELECT TOP 1 strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),
		@userId,
		GETDATE(),
		@totalVoucherCreated,
		@totalIssues

	SET @logId = SCOPE_IDENTITY();
	SET @importLogId = @logId;

	INSERT INTO tblAPImportLogDetail
	(
		intImportLogId,
		strEventDescription
	)
	SELECT
		@logId,
		'Voucher ' + B.strBillId + ' successfully created'
	FROM @vouchers A
	INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
END

IF @totalIssues > 0
BEGIN
	IF @totalVoucherCreated <= 0
	BEGIN
		--INSERT FAILED LOG HEADER ONLY IF THERE ARE NO CREATED VOUCHER
		--INSERT ERROR LOG
		INSERT INTO tblAPImportLog
		(
			strEvent,
			strIrelySuiteVersion,
			intEntityId,
			dtmDate,
			intSuccessCount,
			intErrorCount
		)
		SELECT TOP 1
			'Importing voucher Failed',
			(SELECT TOP 1 strVersionNo FROM tblSMBuildNumber ORDER BY intVersionID DESC),
			@userId,
			GETDATE(),
			@totalVoucherCreated,
			@totalIssues
		FROM #tmpConvertedLassusSasData A
		WHERE 
			A.intAccountId IS NULL

		SET @logId = SCOPE_IDENTITY();

		SET @importLogId = @logId;
	END

	INSERT INTO tblAPImportLogDetail
	(
		intImportLogId,
		strEventDescription
	)
	SELECT
		@logId,
		CASE
			WHEN A.intAccountId IS NULL THEN 'No account id found for ' + A.strGLAccount
		ELSE NULL
		END
	FROM #tmpConvertedLassusSasData A
	WHERE 
		A.intAccountId IS NULL

END

