CREATE PROCEDURE [dbo].[uspAPImportVoucherSupplierInvoice]
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
DECLARE @totalVoucherCreated INT = 0;
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
	intLocationId						=	K.intCompanyLocationId,
	strLocationName						=	A.strSubBook,
	strVendorId							=	A.strVendorId,
	intAccountId						=	C.intGLAccountExpenseId,
	ysnActive							=	C.ysnPymtCtrlActive,
	dtmDate								=	CASE WHEN A.dtmDate LIKE '%.%' THEN CONVERT(DATETIME,A.dtmDate, 103) ELSE CONVERT(DATETIME,A.dtmDate, 101) END,
	dtmBillDate							=	CASE WHEN A.dtmDate LIKE '%.%' THEN CONVERT(DATETIME,A.dtmDate, 103) ELSE CONVERT(DATETIME,A.dtmDate, 101) END,
	strVendorOrderNumber				=	A.strInvoiceNumber,
	dtmExpectedDate						=	CASE WHEN A.dtmExpectedDate LIKE '%.%' THEN CONVERT(DATETIME,A.dtmExpectedDate, 103) ELSE CONVERT(DATETIME,A.dtmExpectedDate, 101) END,
    dblQuantityToBill					=	CAST(A.dblQtyReceived AS DECIMAL(38,20)),
    dblCost								=	CAST(A.dblCost AS DECIMAL(38,15)),
	/*Supplier Invoice*/				
	intSaleYear							=	CAST(A.intSaleYear AS INT),
	intSaleYearId						=	J.intSaleYearId,
	strSaleNumber						=	CAST(A.strSaleNo AS NVARCHAR(50)),
	strVendorLotNumber					=	CAST(A.strLotNumber AS NVARCHAR(50)),
	dtmSaleDate							=	CASE WHEN A.dtmSaleDate LIKE '%.%' THEN CONVERT(DATETIME,A.dtmSaleDate, 103) ELSE CONVERT(DATETIME,A.dtmSaleDate, 101) END,
	strPreInvoiceGarden					=	CAST(A.strPreInvoiceGarden AS NVARCHAR(50)),
	intGardenMarkId						=	G.intGardenMarkId,
	strPreInvoiceGardenNumber			=	CAST(A.strPreInvoiceGardenNumber AS NVARCHAR(50)),
	strPreInvoiceGrade					=	A.strPreInvoiceGrade,
	strBook								=	CAST(A.strBook AS NVARCHAR(50)),
	strSubBook							=	CAST(A.strSubBook AS NVARCHAR(50)),
	intMarketZoneId						=	H.intMarketZoneId,
	/*Others*/		
	strSubLocationName					=	CAST(A.strStorageLocation AS NVARCHAR(50)),
	intSubLocationId					=	D.intCompanyLocationSubLocationId,
	strLotNumber						=	CAST(A.strLotNumber AS NVARCHAR(50)),
	intLotId							=	E.intLotId,
	/*Not exists in i21*/		
	strCatalogueType					=	A.strCatalogueType,
	intCatalogueTypeId					=	I.intCatalogueTypeId,
	strChannel							=	A.strChannel,
	dblPackageBreakups					=	CAST(A.strPackageBreakups AS DECIMAL(18,6)),
	strPurchaseType						=	A.strPurchaseType,
	intTransactionType					=	1, --CASE WHEN A.strPurchaseType = 'I' THEN 1 ELSE 3 END,
	strDocumentNumber					=	A.strDocumentNumber,
	intPurchasingGroupId				=	F.intPurchasingGroupId,
	strPurchasingGroup					=	A.strBook,
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
LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity C2 ON C.intEntityId = C2.intEntityId) ON C2.strName = A.strVendorId
LEFT JOIN tblSMCompanyLocation K ON K.strLocationName = A.strSubBook
LEFT JOIN tblICLot E ON A.strLotNumber = E.strLotNumber
LEFT JOIN tblSMPurchasingGroup F ON F.strName = A.strBook
LEFT JOIN tblQMGardenMark G ON G.strGardenMark = A.strPreInvoiceGarden
LEFT JOIN tblARMarketZone H ON H.strMarketZoneCode = A.strChannel
LEFT JOIN tblQMCatalogueType I ON I.strCatalogueType = A.strCatalogueType
LEFT JOIN tblQMSaleYear J ON J.strSaleYear = A.intSaleYear
OUTER APPLY (
	SELECT TOP 1 intCompanyLocationSubLocationId FROM tblSMCompanyLocationSubLocation sl WHERE A.strStorageLocation = strSubLocationName
) D

DECLARE @voucherPayables AS VoucherPayable
INSERT INTO @voucherPayables
(
	intPartitionId
    ,intEntityVendorId
	,intLocationId
	,intAccountId
    ,intTransactionType
	,intPurchasingGroupId
	,dtmDate
	,dtmExpectedDate
	,dtmVoucherDate
	,dblOrderQty
    ,dblQuantityToBill
    ,dblCost
	,strVendorOrderNumber
	,intSubLocationId	
	,intLotId
	,intSaleYear						
	,strSaleNumber						
	,dtmSaleDate						
	,strVendorLotNumber		
	,intGardenMarkId				
	,strPreInvoiceGardenNumber			
	,strBook							
	,strSubBook		
	,strComments
	,strBillOfLading
	,intMarketZoneId
	,intCatalogueTypeId	
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
	,intLocationId
	,A.intAccountId
    ,A.intTransactionType
	,A.intPurchasingGroupId
	,A.dtmDate
	,A.dtmExpectedDate
	,A.dtmBillDate
	,dblQuantityToBill
    ,dblQuantityToBill
    ,dblCost
	,strVendorOrderNumber
	,intSubLocationId
	,intLotId
	,intSaleYear						
	,strSaleNumber						
	,dtmSaleDate						
	,strVendorLotNumber					
	,intGardenMarkId				
	,strPreInvoiceGardenNumber			
	,strBook							
	,strSubBook	
	,A.strPreInvoiceGrade
	,A.strDocumentNumber
	,intMarketZoneId
	,intCatalogueTypeId	
	,dblPackageBreakups
	,intNumOfPackagesUOM = A.intNumOfPackagesUOM
	,dblNumberOfPackages = A.dblWeightBreakup1Bags
	,intNumOfPackagesUOM2 = A.intNumOfPackagesUOM2
	,dblNumberOfPackages2 = A.dblWeightBreakup2Bags
	,intNumOfPackagesUOM3 = A.intNumOfPackagesUOM3
	,dblNumberOfPackages3 = A.dblWeightBreakup3Bags
	,0
FROM #tmpConvertedSupplierInvoiceData A
WHERE
	A.intEntityVendorId > 0

IF NOT EXISTS(SELECT 1 FROM @voucherPayables)
BEGIN
	-- RAISERROR('No valid record to import.', 16, 1);
	-- RETURN;
	GOTO IMPORTFAILED
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

IMPORTFAILED:
--COUNT VALID IMPORTS
INSERT INTO @vouchers SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@createdVoucher) WHERE intID > 0
SET @totalVoucherCreated = @@ROWCOUNT;

--COUNT INVALID IMPORTS AND RECORD ALL ERRORS
SELECT @totalIssues = COUNT(*)
FROM #tmpConvertedSupplierInvoiceData A
WHERE 
	A.intEntityVendorId IS NULL
OR A.intLocationId IS NULL
OR (A.dblQuantityToBill IS NULL)
OR (A.intAccountId IS NULL)
OR A.ysnActive = 0
OR A.intSaleYearId IS NULL
OR A.intCatalogueTypeId IS NULL
OR A.intPurchasingGroupId IS NULL
OR A.intSubLocationId IS NULL
OR A.intMarketZoneId IS NULL


DECLARE @invalidPayables AS TABLE (strVendorOrderNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, strError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS)
INSERT INTO @invalidPayables
SELECT strVendorOrderNumber, strError
FROM (
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find Company Location ' + strLocationName AS strError FROM #tmpConvertedSupplierInvoiceData WHERE intLocationId IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find vendor ' + strVendorId AS strError FROM #tmpConvertedSupplierInvoiceData WHERE intEntityVendorId IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Vendor ' + strVendorId + ' is not an active vendor.' AS strError FROM #tmpConvertedSupplierInvoiceData WHERE ysnActive = 0
	UNION ALL
	-- SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find transaction type ' + strPurchaseType FROM #tmpConvertedSupplierInvoiceData WHERE intTransactionType IS NULL
	-- UNION ALL
	-- SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find distribution type  ' + strDetailInfo FROM #tmpConvertedSupplierInvoiceData WHERE dblQuantityToBill IS NULL AND strDetailInfo IS NOT NULL
	-- UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': No default vendor expense account setup ' FROM #tmpConvertedSupplierInvoiceData WHERE intAccountId IS NULL --AND strDateOrAccount IS NOT NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid vendor format ' + strVendorId AS strError FROM #tmpConvertedSupplierInvoiceData WHERE intEntityVendorId IS NULL AND strVendorId IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid transaction type ' + strPurchaseType FROM #tmpConvertedSupplierInvoiceData WHERE intTransactionType IS NULL --AND CAST(intVoucherType AS NVARCHAR) IS NULL
	-- UNION ALL
	-- SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid distribution type  ' + strDetailInfo FROM #tmpConvertedSupplierInvoiceData WHERE dblQuantityToBill IS NULL AND strDetailInfo IS NULL
	-- UNION ALL
	-- SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid account format ' FROM #tmpConvertedSupplierInvoiceData WHERE intAccountId IS NULL AND strDateOrAccount IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid Sale Year ' + CAST(intSaleYear AS NVARCHAR) FROM #tmpConvertedSupplierInvoiceData WHERE intSaleYearId IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid Catalogue Type ' + strCatalogueType FROM #tmpConvertedSupplierInvoiceData WHERE intCatalogueTypeId IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid Purchase Group ' + strPurchasingGroup FROM #tmpConvertedSupplierInvoiceData WHERE intPurchasingGroupId IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid Market Zone ' + strChannel FROM #tmpConvertedSupplierInvoiceData WHERE intMarketZoneId IS NULL
	UNION ALL
	SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid Storage Location ' + strSubLocationName FROM #tmpConvertedSupplierInvoiceData WHERE intSubLocationId IS NULL
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
IF @totalIssues > 0 
BEGIN
	IF @totalVoucherCreated <= 0
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
		OR A.intLocationId IS NULL
		OR (A.dblQuantityToBill IS NULL)
		OR (A.intAccountId IS NULL)
		OR A.ysnActive = 0
		OR A.intSaleYearId IS NULL
		OR A.intCatalogueTypeId IS NULL
		OR A.intPurchasingGroupId IS NULL
		OR A.intSubLocationId IS NULL
		OR A.intMarketZoneId IS NULL

		
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