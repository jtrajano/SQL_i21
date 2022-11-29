﻿CREATE PROCEDURE [dbo].[uspAPImportVoucherSupplierInvoice]
	@file NVARCHAR(500) = NULL,
	@userId INT,
	@intVendorId INT = NULL,
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
	DELETE FROM tblAPImportVoucherSupplierInvoice

	SET @sql = 'BULK INSERT tblAPImportVoucherSupplierInvoice FROM ''' + @file + ''' WITH
			(
			FIELDTERMINATOR = '','',
			ROWTERMINATOR = ''\n'',
			ROWS_PER_BATCH = 10000, 
			FIRSTROW = 2,
			TABLOCK,
			ERRORFILE = ''' + @errorFile + '''
			)'

	EXEC(@sql)
END

IF OBJECT_ID(N'tempdb..#tmpConvertedSupplierInvoiceData') IS NOT NULL DROP TABLE #tmpConvertedSupplierInvoiceData
DECLARE @voucherTotal DECIMAL(18,2);

SELECT
	DENSE_RANK() OVER(ORDER BY A.strInvoiceNumber, C.intEntityId) AS intPartitionId,
	intEntityVendorId					=	C.intEntityId,
	strVendorId							=	A.strVendorId,
	intAccountId						=	C.intGLAccountExpenseId,
	ysnActive							=	C.ysnPymtCtrlActive,
	dtmDate								=	CONVERT(DATETIME,REPLACE(A.dtmDate,'.','/'), 103),
	dtmBillDate							=	CONVERT(DATETIME,REPLACE(A.dtmSaleDate,'.','/'), 103),
	strVendorOrderNumber				=	A.strInvoiceNumber,
	dtmExpectedDate						=	CONVERT(DATETIME,REPLACE(A.dtmExpectedDate,'.','/'), 103),
    dblQuantityToBill					=	CAST(A.dblQtyReceived AS DECIMAL(38,20)),
    dblCost								=	CAST(A.dblCost AS DECIMAL(38,15)),
	/*Supplier Invoice*/				
	intSaleYear							=	CAST(A.intSaleYear AS INT),
	strSaleNumber						=	CAST(A.strSaleNo AS NVARCHAR(50)),
	strVendorLotNumber					=	CAST(A.strLotNumber AS NVARCHAR(50)),
	dtmSaleDate							=	CONVERT(DATETIME,REPLACE(A.dtmSaleDate,'.','/'), 103),
	strPreInvoiceGarden					=	CAST(A.strPreInvoiceGarden AS NVARCHAR(50)),
	intGardenMarkId						=	G.intGardenMarkId,
	strPreInvoiceGardenNumber			=	CAST(A.strPreInvoiceGardenNumber AS NVARCHAR(50)),
	strBook								=	CAST(A.strBook AS NVARCHAR(50)),
	strSubBook							=	CAST(A.strSubBook AS NVARCHAR(50)),
	/*Others*/		
	strStorageLocation					=	CAST(A.strStorageLocation AS NVARCHAR(50)),
	intStorageLocationId				=	D.intStorageLocationId,
	strLotNumber						=	CAST(A.strLotNumber AS NVARCHAR(50)),
	intLotId							=	E.intLotId,
	/*Not exists in i21*/		
	strCatalogueType					=	A.strCatalogueType,
	strChannel							=	A.strChannel,
	dblPackageBreakups					=	CAST(A.strPackageBreakups AS DECIMAL(18,6)),
	strPurchaseType						=	A.strPurchaseType,
	intTransactionType					=	CASE WHEN A.strPurchaseType = 'I' THEN 1 ELSE 3 END,
	strDocumentNumber					=	A.strDocumentNumber,
	strPurchasingGroup					=	A.strStorageLocation,
	intNumOfPackagesUOM					=	CAST(A.dblWeightBreakup1 AS INT),
	dblWeightBreakup1Bags				=	CAST(A.dblWeightBreakup1Bags AS DECIMAL(18,6)),
	intNumOfPackagesUOM2				=	CAST(A.dblWeightBreakup2 AS INT),
	dblWeightBreakup2Bags				=	CAST(A.dblWeightBreakup2Bags AS DECIMAL(18,6)),
	intNumOfPackagesUOM3				=	CAST(A.dblWeightBreakup3 AS INT),
	dblWeightBreakup3Bags				=	CAST(A.dblWeightBreakup3Bags AS DECIMAL(18,6)),
	dblWeightBreakup4					=	A.dblWeightBreakup4,
	dblWeightBreakup4Bags				=	A.dblWeightBreakup4Bags,
	dblWeightBreakup5					=	A.dblWeightBreakup5,
	dblWeightBreakup5Bags				=	A.dblWeightBreakup5Bags
INTO #tmpConvertedSupplierInvoiceData
FROM tblAPImportVoucherSupplierInvoice A
LEFT JOIN tblAPVendor C ON C.strVendorId = A.strVendorId
LEFT JOIN tblICStorageLocation D ON A.strStorageLocation = D.strName
LEFT JOIN tblICLot E ON A.strLotNumber = E.strLotNumber
LEFT JOIN tblSMPurchasingGroup F ON F.strName = A.strStorageLocation
LEFT JOIN tblQMGardenMark G ON G.strGardenMark = A.strPreInvoiceGarden

DECLARE @voucherPayables AS VoucherPayable
INSERT INTO @voucherPayables
(
	intPartitionId
    ,intEntityVendorId
	,intAccountId
    ,intTransactionType
	-- ,intPurchasingGroupId
	-- ,strPurchasingGroup
	,dtmDate
	,dtmVoucherDate
	,dblOrderQty
    ,dblQuantityToBill
    ,dblCost
	,strVendorOrderNumber
	,intStorageLocationId	
	,intLotId
	,intSaleYear						
	,strSaleNumber						
	,dtmSaleDate						
	,strVendorLotNumber		
	,intGardenMarkId				
	,strPreInvoiceGardenNumber			
	,strBook							
	,strSubBook			
	,dblPackageBreakups
	,intNumOfPackagesUOM
	,dblNumberOfPackages
	,intNumOfPackagesUOM2
	,dblNumberOfPackages2
	,intNumOfPackagesUOM3
	,dblNumberOfPackages3
	,ysnStage
)
SELECT
	intPartitionId
    ,intEntityVendorId
	,A.intAccountId
    ,A.intTransactionType
	-- ,intPurchasingGroupId
	-- ,strPurchasingGroup
	,A.dtmDate
	,A.dtmBillDate
	,dblQuantityToBill
    ,dblQuantityToBill
    ,dblCost
	,strVendorOrderNumber
	,intStorageLocationId
	,intLotId
	,intSaleYear						
	,strSaleNumber						
	,dtmSaleDate						
	,strVendorLotNumber					
	,intGardenMarkId				
	,strPreInvoiceGardenNumber			
	,strBook							
	,strSubBook		
	,dblPackageBreakups
	,intNumOfPackagesUOM = A.intNumOfPackagesUOM
	,dblNumberOfPackages = A.dblWeightBreakup1Bags
	,intNumOfPackagesUOM2 = A.intNumOfPackagesUOM2
	,dblNumberOfPackages2 = A.dblWeightBreakup2Bags
	,intNumOfPackagesUOM3 = A.intNumOfPackagesUOM3
	,dblNumberOfPackages3 = A.dblWeightBreakup3Bags
	,0
FROM #tmpConvertedSupplierInvoiceData A

IF NOT EXISTS(SELECT 1 FROM @voucherPayables)
BEGIN
	RAISERROR('No valid record to import.', 16, 1);
	RETURN;
END

--vendor do not have default expense account
--vendor do not exists

DECLARE @createdVoucher NVARCHAR(MAX);
EXEC uspAPCreateVoucher @voucherPayables = @voucherPayables, @userId = @userId, @throwError = 1, @createdVouchersId = @createdVoucher OUT

IF @createdVoucher IS NULL 
BEGIN 
	RAISERROR('No valid record to create the voucher.', 16, 1);
	RETURN;
END

--COUNT VALID IMPORTS
INSERT INTO @vouchers SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@createdVoucher) WHERE intID > 0
SET @totalVoucherCreated = @@ROWCOUNT;

--COUNT INVALID IMPORTS AND RECORD ALL ERRORS
SELECT @totalIssues = COUNT(*)
FROM #tmpConvertedSupplierInvoiceData A
WHERE 
	A.intEntityVendorId IS NULL
OR A.intTransactionType IS NULL
OR (A.dblQuantityToBill IS NULL)
OR (A.intAccountId IS NULL)
OR A.ysnActive = 0

DECLARE @invalidPayables AS TABLE (strVendorOrderNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, strError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS)
INSERT INTO @invalidPayables
SELECT strVendorOrderNumber, strError
FROM (
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find vendor ' + strVendorId AS strError FROM #tmpConvertedSupplierInvoiceData WHERE intEntityVendorId IS NULL AND strVendorId IS NOT NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Vendor ' + strVendorId + ' is not an active vendor.' AS strError FROM #tmpConvertedSupplierInvoiceData WHERE ysnActive = 0
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find transaction type ' + strPurchaseType FROM #tmpConvertedSupplierInvoiceData WHERE intTransactionType IS NULL
	-- UNION ALL
	-- SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find distribution type  ' + strDetailInfo FROM #tmpConvertedSupplierInvoiceData WHERE dblQuantityToBill IS NULL AND strDetailInfo IS NOT NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': No default vendor expense account setup ' FROM #tmpConvertedSupplierInvoiceData WHERE intAccountId IS NULL --AND strDateOrAccount IS NOT NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid vendor format ' + strVendorId AS strError FROM #tmpConvertedSupplierInvoiceData WHERE intEntityVendorId IS NULL AND strVendorId IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid transaction type ' + strPurchaseType FROM #tmpConvertedSupplierInvoiceData WHERE intTransactionType IS NULL --AND CAST(intVoucherType AS NVARCHAR) IS NULL
	-- UNION ALL
	-- SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid distribution type  ' + strDetailInfo FROM #tmpConvertedSupplierInvoiceData WHERE dblQuantityToBill IS NULL AND strDetailInfo IS NULL
	-- UNION ALL
	-- SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid account format ' FROM #tmpConvertedSupplierInvoiceData WHERE intAccountId IS NULL AND strDateOrAccount IS NULL
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
	FROM #tmpConvertedSupplierInvoiceData A
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
-- IF @failedPostCount > 0
-- BEGIN
-- 	INSERT INTO tblAPImportLogDetail
-- 	(
-- 		intImportLogId,
-- 		strEventDescription
-- 	)
-- 	SELECT 
-- 		@logId,
-- 		A.strDescription
-- 	FROM tblGLPostResult A
-- 	WHERE 
-- 		A.strBatchId = @batchIdUsed
-- 	AND A.strDescription NOT LIKE '%success%'
-- END