CREATE PROCEDURE [dbo].[uspAPImportVoucherSupplierInvoice]
	@file NVARCHAR(500) = NULL,
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

DECLARE @voucherTotal DECIMAL(18,2);

SELECT
	DENSE_RANK() OVER(ORDER BY A.strInvoiceNumber, C.intEntityId) AS intPartitionId,
	intEntityVendorId					=	C.intEntityId,
	dtmDate								=	CAST(REPLACE(A.dtmDate,'.','/') AS DATETIME),
	dtmBillDate							=	CAST(REPLACE(A.dtmSaleDate,'.','/') AS DATETIME),
	strVendorOrderNumber				=	A.strInvoiceNumber,
	dtmExpectedDate						=	CAST(REPLACE(A.dtmExpectedDate,'.','/') AS DATETIME),
    dblQuantityToBill					=	CAST(A.dblQtyReceived AS DECIMAL(38,20)),
    dblCost								=	CAST(A.dblCost AS DECIMAL(38,15)),
	/*Supplier Invoice*/				
	intSaleYear							=	CAST(A.intSaleYear AS INT),
	strSaleNumber						=	CAST(A.strSaleNo AS NVARCHAR(50)),
	strVendorLotNumber					=	CAST(A.strLotNumber AS NVARCHAR(50)),
	strPreInvoiceGarden					=	CAST(A.strPreInvoiceGarden AS NVARCHAR(50)),
	strPreInvoiceGardenInvoiceNumber	=	CAST(A.strPreInvoiceGardenInvoiceNumber AS NVARCHAR(50)),
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
	dblWeightBreakup4Bags				=	A.dblWeightBreakup4Bags,
	dblWeightBreakup5					=	A.dblWeightBreakup5,
	dblWeightBreakup5Bags				=	A.dblWeightBreakup5Bags
INTO #tmpConvertedSupplierInvoiceData
FROM tblAPImportVoucherSupplierInvoice A
LEFT JOIN tblAPVendor C ON C.strVendorId = A.strVendorId
LEFT JOIN tblICStorageLocation D ON A.strStorageLocation = D.strName
LEFT JOIN tblICLot E ON A.strLotNumber = E.strLotNumber