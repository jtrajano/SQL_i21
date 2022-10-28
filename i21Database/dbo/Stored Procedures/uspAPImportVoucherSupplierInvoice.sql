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
	strPackageBreakups					=	A.strPackageBreakups,
	strPurchaseType						=	A.strPurchaseType,
	strDocumentNumber					=	A.strDocumentNumber,
	dblWeightBreakup1					=	A.dblWeightBreakup1,
	dblWeightBreakup1Bags				=	A.dblWeightBreakup1Bags,
	dblWeightBreakup2					=	A.dblWeightBreakup2,
	dblWeightBreakup2Bags				=	A.dblWeightBreakup2Bags,
	dblWeightBreakup3					=	A.dblWeightBreakup3,
	dblWeightBreakup3Bags				=	A.dblWeightBreakup3Bags,
	dblWeightBreakup4					=	A.dblWeightBreakup4,
	dblWeightBreakup4Bags				=	A.dblWeightBreakup4Bags,
	dblWeightBreakup5					=	A.dblWeightBreakup5,
	dblWeightBreakup5Bags				=	A.dblWeightBreakup5Bags
INTO #tmpConvertedSupplierInvoiceData
FROM tblAPImportVoucherSupplierInvoice A
LEFT JOIN tblAPVendor C ON C.strVendorId = A.strVendorId
LEFT JOIN tblICStorageLocation D ON A.strStorageLocation = D.strName
LEFT JOIN tblICLot E ON A.strLotNumber = E.strLotNumber

DECLARE @voucherPayables AS VoucherPayable
INSERT INTO @voucherPayables
(
	intPartitionId
    ,intEntityVendorId
    ,intTransactionType
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
	,strPreInvoiceGarden				
	,strPreInvoiceGardenNumber			
	,strBook							
	,strSubBook			
	,ysnStage
)
SELECT
	intPartitionId
    ,intEntityVendorId
    ,CASE WHEN A.strPurchaseType = 'I' THEN 1 ELSE 3 END
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
	,strPreInvoiceGarden				
	,strPreInvoiceGardenNumber			
	,strBook							
	,strSubBook		
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