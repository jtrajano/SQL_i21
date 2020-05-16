CREATE PROCEDURE [dbo].[uspAPImportVoucherLassus]
	@file NVARCHAR(500) = NULL,
	@userId INT,
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

IF @file IS NOT NULL
BEGIN

	DELETE FROM tblAPImportVoucherLassus

	SET @sql = 'BULK INSERT tblAPImportVoucherLassus FROM ''' + @file + ''' WITH
			(
			FIELDTERMINATOR = '','',
			ROWTERMINATOR = ''\n'',
			ROWS_PER_BATCH = 10000, 
			FIRSTROW = 1,
			TABLOCK,
			ERRORFILE = ''' + @errorFile + '''
			)'

	EXEC(@sql)

END

DECLARE @voucherTotal DECIMAL(18,2);

SELECT
	DENSE_RANK() OVER(ORDER BY A.strInvoiceNumber, A.strVendorId) AS intPartitionId,
	intEntityVendorId	=	C.intEntityId,
	strVendorId			=	A.strVendorId,
    intTransactionType	=	CAST(
							CASE A.intVoucherType
								WHEN '1' THEN 1
								WHEN '5' THEN 3
							ELSE NULL
							END AS INT),
	intVoucherType		=	A.intVoucherType,
	dtmDate				=	CONVERT(DATETIME, SUBSTRING(A.dtmDate,1,2) + '/'+SUBSTRING(A.dtmDate,3,2) + '/'+SUBSTRING(A.dtmDate,5,4)),
	dtmVoucherDate		=	CONVERT(DATETIME, SUBSTRING(A.strDateOrAccount,1,2) + '/'+SUBSTRING(A.strDateOrAccount,3,2) + '/'+SUBSTRING(A.strDateOrAccount,5,4)),
    dblQuantityToBill	=	1,
	strDetailInfo		=	details.strDetailInfo,
    dblCost				=	ABS(CAST(details.dblCredit AS DECIMAL(18,2)) - CAST(details.dblDebit AS DECIMAL(18,2))),
	intAccountId		=	details.intAccountId,
	strDateOrAccount	=	details.strDateOrAccount,
	strReference		=	A.strReference,
	strVendorOrderNumber=	A.strInvoiceNumber,
	strMiscDescription	=	details.strItemDescription
INTO #tmpConvertedLassusData
FROM tblAPImportVoucherLassus A
LEFT JOIN tblAPVendor C ON A.strVendorId = C.strVendorId
OUTER APPLY (
	SELECT
		strDetailInfo,
		strDateOrAccount,
		dblDebit,
		dblCredit,
		strItemDescription,
		D.intAccountId
	FROM tblAPImportVoucherLassus B
	LEFT JOIN tblGLAccount D ON B.strDateOrAccount = D.strAccountId
	WHERE 
		B.strIdentity = 'D'
	AND B.strDetailInfo = '6'
	AND A.strInvoiceNumber = B.strInvoiceNumber
	AND A.strVendorId = B.strVendorId
) details
WHERE 
	A.strIdentity = 'H'

DECLARE @voucherPayables AS VoucherPayable
INSERT INTO @voucherPayables
(
	intPartitionId,
    intEntityVendorId,
    intTransactionType,
	dtmDate,
	dtmVoucherDate,
	dblOrderQty,
    dblQuantityToBill,
    dblCost,
	intAccountId,
	strReference,
	strVendorOrderNumber,
	strMiscDescription,
	ysnStage
)
SELECT
	intPartitionId,
    intEntityVendorId,
    intTransactionType,
	dtmDate,
	dtmDate,
	dblQuantityToBill,
    dblQuantityToBill,
    dblCost,
	intAccountId,
	strReference,
	strVendorOrderNumber,
	strMiscDescription,
	0
FROM #tmpConvertedLassusData A
WHERE 
	A.intEntityVendorId > 0
AND A.intAccountId > 0
AND (A.intTransactionType > 0)
AND (A.dblQuantityToBill != 0)

IF NOT EXISTS(SELECT 1 FROM @voucherPayables)
BEGIN
	RAISERROR('No valid record to import.', 16, 1);
	RETURN;
END

DECLARE @createdVoucher NVARCHAR(MAX);
EXEC uspAPCreateVoucher @voucherPayables = @voucherPayables, @userId = @userId, @throwError = 1, @createdVouchersId = @createdVoucher OUT

IF @createdVoucher IS NULL 
BEGIN 
	RAISERROR('No valid record to create the voucher.', 16, 1);
	RETURN;
END

DECLARE @batchIdUsed NVARCHAR(50);
DECLARE @failedPostCount INT;

EXEC uspAPPostBill
	@post				= 1,
	@recap				= 0,
	@isBatch			= 1,
	@param				= @createdVoucher,
	@userId				= @userId,
	@invalidCount		= @failedPostCount OUTPUT,
	@batchIdUsed		= @batchIdUsed OUTPUT

INSERT INTO @vouchers SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@createdVoucher) WHERE intID > 0

SET @totalVoucherCreated = @@ROWCOUNT;

SELECT @totalIssues = COUNT(*)
FROM #tmpConvertedLassusData A
WHERE 
	A.intEntityVendorId IS NULL
OR A.intTransactionType IS NULL
OR (A.dblQuantityToBill IS NULL)
OR (A.intAccountId IS NULL)

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
			WHEN @totalIssues > 0 THEN 'Some voucher(s) successfully imported from CSV'
		ELSE
			'Successfully imported voucher(s) from CSV'
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

IF @totalIssues >0
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
		FROM #tmpConvertedLassusData A
		WHERE 
			A.intEntityVendorId IS NULL
		OR A.intTransactionType IS NULL
		OR (A.dblQuantityToBill IS NULL)
		OR (A.intAccountId IS NULL)

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
			WHEN A.intEntityVendorId IS NULL THEN 'No vendor found for ' + A.strVendorId
			WHEN A.intTransactionType IS NULL THEN 'Invalid transaction indicator for ' + CAST(A.intVoucherType AS NVARCHAR)
			WHEN A.dblQuantityToBill IS NULL THEN 'Invalid distribution type ' + A.strDetailInfo
			WHEN A.intAccountId IS NULL THEN 'No account id found for ' + A.strDateOrAccount
		ELSE NULL
		END
	FROM #tmpConvertedLassusData A
	WHERE 
		A.intEntityVendorId IS NULL
	OR A.intTransactionType IS NULL
	OR (A.dblQuantityToBill IS NULL)
	OR (A.intAccountId IS NULL)
END

--LOG THE FAILED POSTING
IF @failedPostCount > 0
BEGIN
	INSERT INTO tblAPImportLogDetail
	(
		intImportLogId,
		strEventDescription
	)
	SELECT 
		@logId,
		A.strDescription
	FROM tblGLPostResult A
	WHERE 
		A.strBatchId = @batchIdUsed
	AND A.strDescription NOT LIKE '%success%'
END

