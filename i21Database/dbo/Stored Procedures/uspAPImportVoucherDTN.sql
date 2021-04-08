CREATE PROCEDURE [dbo].[uspAPImportVoucherDTN]
	@file NVARCHAR(500) = NULL,
	@userId INT,
	@importLogId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF --ON TO AVOID UNHANDLED NULL, DIVIDE ZERO ERROR, STRING TRUNCATION

IF OBJECT_ID(N'tempdb..#tmpVoucherDTNStage') IS NOT NULL DROP TABLE #tmpVoucherTransactions
CREATE TABLE #tmpVoucherDTNStage(strData NVARCHAR(MAX));

DECLARE @sql NVARCHAR(MAX);
DECLARE @path NVARCHAR(500);
DECLARE @errorFile NVARCHAR(500);
DECLARE @lastIndex INT;
DECLARE @vouchers TABLE(intBillId INT);
DECLARE @totalVoucherCreated INT;
DECLARE @voucherPayables AS VoucherPayable;
DECLARE @defaultCurrency AS INT;

IF OBJECT_ID(N'tempdb..#tmppayablesInfo') IS NOT NULL DROP TABLE #tmppayablesInfo
CREATE TABLE #tmppayablesInfo(
	intPartitionId INT
	,intEntityVendorId INT NULL
	,strVendorOrderNumber NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
	,strVendorName NVARCHAR(100) NULL
	,strShipToName NVARCHAR(100) NULL
	,strShipFromName NVARCHAR(100) NULL
	,intShipToId INT NULL
	,intShipFromId INT NULL
	,intCurrencyId INT NULL
	,strMiscDescription NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
	,dblCost DECIMAL(38,20) NOT NULL DEFAULT(0)
	,dblQuantityToBill DECIMAL(38,20) NOT NULL DEFAULT(0)
	,dtmDate DATETIME
	,dtmDueDate DATETIME
	,dtmVoucherDate DATETIME
	,intTermId INT
)

-- SET @lastIndex = (LEN(@file)) -  CHARINDEX('/', REVERSE(@file)) 
-- SET @path = SUBSTRING(@file, 0, @lastindex + 1)
SET @errorFile = REPLACE(@file, 'csv', 'txt');

IF @file IS NOT NULL
BEGIN
	DELETE FROM #tmpVoucherDTNStage

	SET @sql = 'BULK INSERT #tmpVoucherDTNStage FROM ''' + @file + ''' WITH
			(
			FIELDTERMINATOR = '',\n'',
			ROWTERMINATOR = ''\n'',
			FIRSTROW = 1,
			TABLOCK,
			ERRORFILE = ''' + @errorFile + '''
			)'

	EXEC(@sql)
END

IF EXISTS(SELECT 1 FROM #tmpVoucherDTNStage)
BEGIN
	
	SET @defaultCurrency = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD')

	IF OBJECT_ID(N'tempdb..#tmpVoucherDTNHeader') IS NOT NULL DROP TABLE #tmpVoucherDTNHeader
	IF OBJECT_ID(N'tempdb..#tmpVoucherDTNDetail') IS NOT NULL DROP TABLE #tmpVoucherDTNDetail

	--ADD IDENTITY ON TEMP TABLE TO AVOID DEFAULT SORTING OF CTE
	ALTER TABLE #tmpVoucherDTNStage
	ADD intId INT IDENTITY(1,1)

	--https://stackoverflow.com/questions/10581772/how-to-split-a-comma-separated-value-to-columns?page=2&tab=active#tab-top
	;WITH Split_Names (
		intId, [strData], xmlData
	)
	AS
	(
		SELECT 
			intId,
			[strData],
			-- CONVERT(XML,'<strData><data>'  
			-- + REPLACE(strData,',', '</data><data>') + '</data></strData>') AS xmlData,
			--CDATA clears invalid characters in XML
			CONVERT(XML,'<strData><data><![CDATA[' + REPLACE([strData],',', ']]></data><data><![CDATA[') + ']]></data></strData>') AS xmlData
		FROM #tmpVoucherDTNStage
	),
	DTNHeader AS (
		--HEADER
		SELECT 
			xmlData.value('/strData[1]/data[1]','VARCHAR(6)') AS strRecordType,
			xmlData.value('/strData[1]/data[2]','VARCHAR(9)') AS strDTNNum,
			xmlData.value('/strData[1]/data[3]','VARCHAR(5)') AS strVersion,
			xmlData.value('/strData[1]/data[4]','DATE') AS strTransmissionDate,
			xmlData.value('/strData[1]/data[5]','VARCHAR(4)') AS strTransmissionTime, --USE VARCHAR, TIME IS INCORRECT FORMAT
			xmlData.value('/strData[1]/data[6]','VARCHAR(22)') AS strInvoiceNumber,
			xmlData.value('/strData[1]/data[7]','DATE') AS dtmInvoiceDate,
			xmlData.value('/strData[1]/data[8]','VARCHAR(2)') AS strDocumentType,
			xmlData.value('/strData[1]/data[9]','VARCHAR(60)') AS strSellerName,
			xmlData.value('/strData[1]/data[10]','VARCHAR(60)') AS strSoldToName,
			xmlData.value('/strData[1]/data[11]','VARCHAR(30)') AS strSoldToCustomerNumber,
			xmlData.value('/strData[1]/data[12]','VARCHAR(22)') AS strPurchaseOrderNumber,
			xmlData.value('/strData[1]/data[13]','VARCHAR(80)') AS strTermsDescription,
			xmlData.value('/strData[1]/data[14]','DECIMAL(20,10)') AS dblDocumentTotal,
			xmlData.value('/strData[1]/data[15]','DATE') AS dtmInvDueDate,
			xmlData.value('/strData[1]/data[16]','DECIMAL(20,10)') AS dblInvoiceTotal,
			xmlData.value('/strData[1]/data[17]','DATE') AS dtmDiscountDueDate,
			xmlData.value('/strData[1]/data[18]','DECIMAL(20,10)') AS dblDiscount,
			xmlData.value('/strData[1]/data[19]','DECIMAL(20,10)') AS dblDiscountedAmount,
			xmlData.value('/strData[1]/data[20]','VARCHAR(8)') AS strSenderId
		--INTO #tmpVoucherDTNHeader
		FROM Split_Names
		WHERE xmlData.value('/strData[1]/data[1]','VARCHAR(6)') = 'BEGIN'
	),
	DTNDetail AS (
		--DETAIL
		SELECT 
			xmlData.value('/strData[1]/data[1]','VARCHAR(6)') AS strRecordType,
			xmlData.value('/strData[1]/data[2]','VARCHAR(22)') AS strInvoiceNumber,
			xmlData.value('/strData[1]/data[3]','VARCHAR(30)') AS strBOL,
			xmlData.value('/strData[1]/data[4]','VARCHAR(80)') AS strDescription,
			xmlData.value('/strData[1]/data[5]','VARCHAR(48)') AS strDTNProductCode, --USE VARCHAR, TIME IS INCORRECT FORMAT
			xmlData.value('/strData[1]/data[6]','VARCHAR(48)') AS strSupplierProductCode,
			xmlData.value('/strData[1]/data[7]','DECIMAL(15,6)') AS dblQuantityBilled,
			xmlData.value('/strData[1]/data[8]','VARCHAR(1)') AS strQuantityIndicator,
			CASE 
				WHEN xmlData.exist('/strData[1]/data[9]/text()') = 1 --check if xml tag is not empty
				THEN xmlData.value('/strData[1]/data[9]','DECIMAL(15,6)')
			ELSE CAST(1.0 AS DECIMAL(15,6)) END AS dblGrossQty,
			CASE 
				WHEN xmlData.exist('/strData[1]/data[10]/text()') = 1 --check if xml tag is not empty
				THEN xmlData.value('/strData[1]/data[10]','DECIMAL(15,6)')
			ELSE CAST(1.0 AS DECIMAL(15,6)) END AS dblNetQty,
			xmlData.value('/strData[1]/data[11]','VARCHAR(2)') AS strUOM,
			CASE 
				WHEN xmlData.exist('/strData[1]/data[12]/text()') = 1 --check if xml tag is not empty
				THEN xmlData.value('/strData[1]/data[12]','DECIMAL(9,6)')
			ELSE CAST(1.0 AS DECIMAL(15,6)) END AS dblRate,
			xmlData.value('/strData[1]/data[13]','DECIMAL(20,6)') AS dblLineTotal,
			xmlData.value('/strData[1]/data[14]','DATE') AS dtmShipDate,
			xmlData.value('/strData[1]/data[15]','TIME') AS dtmShipTime,
			xmlData.value('/strData[1]/data[16]','VARCHAR(60)') AS strShipFromName,
			xmlData.value('/strData[1]/data[17]','VARCHAR(55)') AS strShipFromAddress,
			xmlData.value('/strData[1]/data[18]','VARCHAR(55)') AS strShipFromAddress2,
			xmlData.value('/strData[1]/data[19]','VARCHAR(30)') AS strShipFromCity,
			xmlData.value('/strData[1]/data[20]','VARCHAR(2)') AS strShipFromState,
			xmlData.value('/strData[1]/data[21]','VARCHAR(15)') AS strShipFromZip,
			xmlData.value('/strData[1]/data[22]','VARCHAR(30)') AS strDTNSPLC,
			xmlData.value('/strData[1]/data[23]','VARCHAR(60)') AS strShipToName,
			xmlData.value('/strData[1]/data[24]','VARCHAR(55)') AS strShipToAddress,
			xmlData.value('/strData[1]/data[25]','VARCHAR(55)') AS strShipToAddress2,
			xmlData.value('/strData[1]/data[26]','VARCHAR(30)') AS strShipToCity,
			xmlData.value('/strData[1]/data[27]','VARCHAR(2)') AS strShipToState,
			xmlData.value('/strData[1]/data[28]','VARCHAR(15)') AS strShipToZip,
			xmlData.value('/strData[1]/data[29]','VARCHAR(35)') AS strCarrierDescription,
			xmlData.value('/strData[1]/data[30]','VARCHAR(10)') AS strCarrierFEIN,
			xmlData.value('/strData[1]/data[31]','VARCHAR(30)') AS strOriginalInvoiceNumber,
			xmlData.value('/strData[1]/data[32]','VARCHAR(15)') AS strContractNumber,
			xmlData.value('/strData[1]/data[33]','VARCHAR(30)') AS strCustomerSalesOrderNumber,
			xmlData.value('/strData[1]/data[34]','VARCHAR(30)') AS strVehicleNumber
		--INTO #tmpVoucherDTNDetail
		FROM Split_Names
		WHERE 
			xmlData.value('/strData[1]/data[1]','VARCHAR(6)') = 'ITM'
		--AND xmlData.value('/strData[1]/data[4]','VARCHAR(80)') != 'DEFERRED TAX' --EXCLUDE THIS, THIS IS 0 LINE TOTAL
	)

	INSERT INTO #tmppayablesInfo(
		intPartitionId
		,strVendorOrderNumber
		,strVendorName
		,strShipToName
		,strShipFromName
		,intEntityVendorId
		,intShipToId
		,intShipFromId
		,intCurrencyId
		,strMiscDescription
		,dblCost
		,dblQuantityToBill
		,dtmDate
		,dtmDueDate
		,dtmVoucherDate
		,intTermId
	)
	SELECT
		intPartitionId			= 	ROW_NUMBER() OVER(ORDER BY A.strInvoiceNumber), --1 voucher per 1 payable
		strVendorOrderNumber	=	A.strInvoiceNumber,
		strVendorName			=	A.strSellerName,
		strShipToName			=	B.strShipToName,
		strShipFromName			=	B.strShipFromName,
		intEntityVendorId		=	C.intEntityId,
		intShipToId				=	E.intCompanyLocationId,
		intShipFromId			=	F.intCompanyLocationId,
		intCurrencyId			=	@defaultCurrency,
		strMiscDescription		=	B.strDescription,
		dblCost					=	B.dblRate,
		dblQuantityToBill		=	B.dblQuantityBilled,
		dtmDate					=	A.dtmInvoiceDate,
		dtmDueDate				=	A.dtmInvDueDate,
		dtmVoucherDate			=	A.dtmInvoiceDate,
		intTermId				=	G.intTermID
	FROM DTNHeader A
	INNER JOIN DTNDetail B ON A.strInvoiceNumber = B.strInvoiceNumber
	LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON C.intEntityId = D.intEntityId) ON A.strSellerName = D.strName
	LEFT JOIN tblSMCompanyLocation E ON E.strLocationName = B.strShipToName
	LEFT JOIN tblSMCompanyLocation F ON E.strLocationName = B.strShipFromName
	LEFT JOIN tblSMTerm G ON G.strTerm = A.strTermsDescription

	INSERT INTO @voucherPayables(
		intPartitionId
		,strVendorOrderNumber
		,intTransactionType
		,intEntityVendorId
		,intShipToId
		,intShipFromId
		,intCurrencyId
		,strMiscDescription
		,dblCost
		,dblQuantityToBill
		,dtmDate
		,dtmDueDate
		,dtmVoucherDate
		,intTermId
	)
	SELECT
		intPartitionId			= 	intPartitionId, --1 voucher per 1 payable
		strVendorOrderNumber	=	strVendorOrderNumber,
		intTransactionType 		=	1,
		intEntityVendorId		=	intEntityVendorId,
		intShipToId				=	intShipToId,
		intShipFromId			=	intShipFromId,
		intCurrencyId			=	intCurrencyId,
		strMiscDescription		=	strMiscDescription,
		dblCost					=	dblCost,
		dblQuantityToBill		=	dblQuantityToBill,
		dtmDate					=	dtmDate,
		dtmDueDate				=	dtmDueDate,
		dtmVoucherDate			=	dtmVoucherDate,
		intTermId				=	intTermId
	FROM #tmppayablesInfo
	WHERE
		intEntityVendorId IS NOT NULL
	AND intShipToId IS NOT NULL
	AND intShipFromId IS NOT NULL

	--VALIDATE
	DECLARE @totalIssues INT;
	
	SELECT @totalIssues = COUNT(*)
	FROM #tmppayablesInfo
	WHERE 
		intEntityVendorId IS NULL --NO VENDOR
	OR	intShipToId IS NULL
	OR	intShipFromId IS NULL

	DECLARE @invalidPayables AS TABLE (strVendorOrderNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, strError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS)
	INSERT INTO @invalidPayables
	SELECT strVendorOrderNumber, strError
	FROM (
		SELECT intPartitionId, strVendorOrderNumber, 'Cannot find vendor ' + strVendorName + ' for Invoice No. ' + strVendorOrderNumber AS strError 
		FROM #tmppayablesInfo 
		WHERE intEntityVendorId IS NULL
		UNION ALL
		SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Vendor ' + B.strVendorId + ' is not an active vendor.' AS strError 
		FROM #tmppayablesInfo A
		INNER JOIN tblAPVendor B ON A.intEntityVendorId = B.intEntityId
		WHERE B.ysnPymtCtrlActive = 0
		UNION ALL
		SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find ship to name ' + strShipToName AS strError 
		FROM #tmppayablesInfo A
		WHERE A.intShipToId IS NULL
		UNION ALL
		SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find ship from name ' + strShipFromName AS strError 
		FROM #tmppayablesInfo A
		WHERE A.intShipFromId IS NULL
	) tblErrors
	ORDER BY intPartitionId

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
		FROM #tmppayablesInfo A
		WHERE 
			A.intEntityVendorId IS NULL
		OR (A.dblQuantityToBill IS NULL)

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
	
END
ELSE
BEGIN
	RAISERROR('No record(s) imported.', 16, 1);
END
