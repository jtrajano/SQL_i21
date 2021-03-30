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

--PARTITION DATA IMPORTED RECORDS
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
    dblQuantityToBill	=	1 * 
							(CASE WHEN CAST(details.dblDebit AS DECIMAL(18,2)) - CAST(details.dblCredit AS DECIMAL(18,2))
								--If amount is on 'Credit' AND voucher type, make it negative
								< 0 THEN (CASE WHEN A.intVoucherType = 1 THEN -1 ELSE 1 END)
								--If amount is on 'Debit' AND debit memo type, make it negative
								ELSE (CASE WHEN A.intVoucherType = 5 THEN -1 ELSE 1 END) 
								END),
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

--PASS VALID PAYABLES
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

--VOUCHER AND POST VALID PAYABLES
DECLARE @createdVoucher NVARCHAR(MAX);
IF EXISTS(SELECT 1 FROM @voucherPayables)
BEGIN
	EXEC uspAPCreateVoucher @voucherPayables = @voucherPayables, @userId = @userId, @throwError = 1, @createdVouchersId = @createdVoucher OUT

	IF @createdVoucher IS NOT NULL 
	BEGIN 
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
	END
END

--COUNT VALID IMPORTS
INSERT INTO @vouchers SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@createdVoucher) WHERE intID > 0
SET @totalVoucherCreated = @@ROWCOUNT;

--COUNT INVALID IMPORTS AND RECORD ALL ERRORS
SELECT @totalIssues = COUNT(*)
FROM #tmpConvertedLassusData A
WHERE 
	A.intEntityVendorId IS NULL
OR A.intTransactionType IS NULL
OR (A.dblQuantityToBill IS NULL)
OR (A.intAccountId IS NULL)

DECLARE @invalidPayables AS TABLE (strVendorOrderNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, strError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS)
INSERT INTO @invalidPayables
SELECT strVendorOrderNumber, strError
FROM (
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find vendor ' + strVendorId AS strError FROM #tmpConvertedLassusData WHERE intEntityVendorId IS NULL AND strVendorId IS NOT NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find transaction type ' + CAST(intVoucherType AS NVARCHAR) FROM #tmpConvertedLassusData WHERE intTransactionType IS NULL AND CAST(intVoucherType AS NVARCHAR) IS NOT NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find distribution type  ' + strDetailInfo FROM #tmpConvertedLassusData WHERE dblQuantityToBill IS NULL AND strDetailInfo IS NOT NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find account ' + strDateOrAccount FROM #tmpConvertedLassusData WHERE intAccountId IS NULL AND strDateOrAccount IS NOT NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid vendor format ' + strVendorId AS strError FROM #tmpConvertedLassusData WHERE intEntityVendorId IS NULL AND strVendorId IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid transaction type ' + CAST(intVoucherType AS NVARCHAR) FROM #tmpConvertedLassusData WHERE intTransactionType IS NULL AND CAST(intVoucherType AS NVARCHAR) IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid distribution type  ' + strDetailInfo FROM #tmpConvertedLassusData WHERE dblQuantityToBill IS NULL AND strDetailInfo IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid account format ' FROM #tmpConvertedLassusData WHERE intAccountId IS NULL AND strDateOrAccount IS NULL
) tblErrors
ORDER BY intPartitionId

--LOG ALL
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

	--SUCCESS
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

	--FAILED
	INSERT INTO tblAPImportLogDetail
	(
		intImportLogId,
		strEventDescription
	)
	SELECT
		@logId,
		strError
	FROM @invalidPayables A
END


--INSERT FAILED LOG HEADER ONLY IF THERE ARE NO CREATED VOUCHER
--INSERT ERROR LOG
IF @totalIssues > 0 AND @totalVoucherCreated <= 0
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

	INSERT INTO tblAPImportLogDetail
	(
		intImportLogId,
		strEventDescription
	)
	SELECT
		@logId,
		strError
	FROM @invalidPayables
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

