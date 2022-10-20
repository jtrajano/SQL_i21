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
			FIRSTROW = 1,
			TABLOCK,
			ERRORFILE = ''' + @errorFile + '''
			)'

	EXEC(@sql)
END

DECLARE @voucherTotal DECIMAL(18,2);

SELECT
	DENSE_RANK() OVER(ORDER BY A.strInvoiceNumber, C.intEntityId) AS intPartitionId,
	intEntityVendorId	=	C.intEntityId,
	dtmDate				=	CAST(A.dtmDate AS DATETIME),
	dtmBillDate				=	CAST(A.dtmBillDate AS DATETIME),
	strVendorOrderNumber=	A.strInvoiceNumber,
	dtmExpectedDate		=	CAST(A.dtmExpectedDate AS DATETIME),
    dblQuantityToBill	=	CAST(A.dblQtyReceived AS DECIMAL(38,20)),
    dblCost				=	CAST(A.dblCOst AS DECIMAL(38,15)),
	/*Supplier Invoice*/
	intSaleYear			=	CAST(A.intSaleYear AS INT),
	strSaleNumber		=	CAST(A.strSaleNumber AS NVARCHAR(50)),
	dtmSaleDate			=	CAST(A.dtmSaleDate AS DATETIME),
	strVendorLotNumber	=	CAST(A.strLotNumber AS NVARCHAR(50)),
	strPreInvoiceGarden	=	CAST(A.strPreInvoiceGarden AS NVARCHAR(50)),
	strPreInvoiceGardenNumber	=	CAST(A.strPreInvoiceGardenNumber AS NVARCHAR(50)),
	strBook				=	CAST(A.strBook AS NVARCHAR(50)),
	strSubBook			=	CAST(A.strSubBook AS NVARCHAR(50))
INTO #tmpConvertedSupplierInvoiceData
FROM tblAPImportVoucherSupplierInvoice A
LEFT JOIN tblAPVendor C ON C.strVendorId = A.strVendorId