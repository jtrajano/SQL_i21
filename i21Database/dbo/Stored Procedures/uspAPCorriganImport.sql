CREATE PROCEDURE [dbo].[uspAPCorriganImport]
	@dir NVARCHAR(500),
	@userName NVARCHAR(50)
AS
--BEGIN TRAN

--DECLARE @dir NVARCHAR(200) = 'D:\SQLDBs\Files'
--DECLARE @file NVARCHAR(500) --= 'D:\Chrome Downloads\Invoice Extract - 5.31.23.txt'
--DECLARE @userId INT = (SELECT TOP 1 intEntityId FROM tblEMEntityCredential WHERE strUserName = 'irelyadmin')

DECLARE @file NVARCHAR(500)
DECLARE @importLogId INT
DECLARE @userId INT = (SELECT TOP 1 intEntityId FROM tblEMEntityCredential WHERE strUserName = @userName)

IF OBJECT_ID('tempdb..#DirTree') IS NOT NULL
	DROP TABLE #DirTree

CREATE TABLE #DirTree (
	Id int identity(1,1),
	SubDirectory nvarchar(255),
	Depth smallint,
	FileFlag bit,
	ParentDirectoryID int
)

INSERT INTO #DirTree (SubDirectory, Depth, FileFlag)
EXEC master..xp_dirtree @dir, 0, 1

SELECT @file = @dir + '\' + (SELECT TOP 1 SubDirectory FROM #DirTree)

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF --ON TO AVOID UNHANDLED NULL, DIVIDE ZERO ERROR, STRING TRUNCATION

IF OBJECT_ID(N'tempdb..#tmpVoucherCorrigonStage') IS NOT NULL DROP TABLE #tmpVoucherCorrigonStage
CREATE TABLE #tmpVoucherCorrigonStage(strData NVARCHAR(MAX));

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
	,strVendorOrderNumber NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
	,intTransactionType INT NULL
	,intEntityVendorId INT NULL
	,strVendorId NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL
	,intShipToId INT NULL
	,strShipToName NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL
	,intShipFromId INT NULL
	,strShipFromName NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL
	,intPayToId INT NULL
	,strPayTo NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL
	,intCurrencyId INT NULL
	,dblCost DECIMAL(38,20) NOT NULL DEFAULT(0)
	,dblQuantityToBill DECIMAL(38,20) NOT NULL DEFAULT(0)
	,strBilledUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intBilledUOM INT NULL
	,dblQuantityOrdered DECIMAL(38,20) NOT NULL DEFAULT(0)
	,strOrderedUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intOrderedUOM INT NULL
	,intShipViaId INT NULL
	,strShipVia NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strContactName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intContactId INT NULL
	,intAPAccount INT NULL
	,strAPAccount NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strAPAccountCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intFreightTermId INT NULL
	,strFreightTerm NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intItemId INT NULL
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intDetailAccountId INT NULL
	,strDetailAccountId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strDetailAccountIdCategory NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intBankAccountId INT NULL
	,strBankAccount NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,ysnOverrideBank BIT NULL
	,intPayFromBankAccount INT NULL
	,strPayFromBankAccount NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,intPayToBankAccount INT NULL
	,strPayToBankAccount NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,dtmDate DATETIME
	,dtmDueDate DATETIME
	,dtmVoucherDate DATETIME
	,dtmExpectedDate DATETIME
	,intTermId INT NULL
	,strTerm NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,strComment NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,strRemarks NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,strDetailComment NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	,strLoadNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intLoadId INT NULL
	,strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intContractHeaderId INT NULL
	,strPONumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,intPurchaseDetailId INT NULL
	,dblRate DECIMAL(18, 6) NULL
	,intCurrencyExchangeRateTypeId INT NULL
	,strCurrencyExchangeRateType NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	--,strDistributionType NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
	,strOverrideForexRate NVARCHAR(1) COLLATE Latin1_General_CI_AS NULL
	,strBOL NVARCHAR(1) COLLATE Latin1_General_CI_AS NULL
	,strReference NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL
	,ysnHold BIT DEFAULT(0)
	,ysnGenerateTax BIT DEFAULT(0)
	,intLineNo INT
)

-- SET @lastIndex = (LEN(@file)) -  CHARINDEX('/', REVERSE(@file)) 
-- SET @path = SUBSTRING(@file, 0, @lastindex + 1)
SET @errorFile = REPLACE(@file, '.txt', CAST(FLOOR(RAND()*(100-10+1))+10 AS NVARCHAR) + '.txt');

IF @file IS NOT NULL
BEGIN
	
	DELETE FROM #tmpVoucherCorrigonStage

	SET @sql = 'BULK INSERT #tmpVoucherCorrigonStage FROM ''' + @file + ''' WITH
			(
			FIELDTERMINATOR = ''|'',
			ROWTERMINATOR = ''\n'',
			FIRSTROW = 0,
			TABLOCK,
			ERRORFILE = ''' + @errorFile + '''
			)'

	EXEC(@sql)
END
ELSE
BEGIN
	RAISERROR('File not found or permission denied.', 16, 1);
END

--SELECT '' [tmpVoucherCorrigonStage], * FROM #tmpVoucherCorrigonStage
--DROP TABLE #tmpVoucherCorrigonStage

IF EXISTS(SELECT 1 FROM #tmpVoucherCorrigonStage)
BEGIN
	SET @defaultCurrency = (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency = 'USD')

	IF OBJECT_ID(N'tempdb..#tmpVoucherCorrigonHeader') IS NOT NULL DROP TABLE #tmpVoucherCorrigonHeader
	IF OBJECT_ID(N'tempdb..#tmpVoucherCorrigonDetail') IS NOT NULL DROP TABLE #tmpVoucherCorrigonDetail

	--ADD IDENTITY ON TEMP TABLE TO AVOID DEFAULT SORTING OF CTE
	ALTER TABLE #tmpVoucherCorrigonStage
	ADD intId INT IDENTITY(1,1)

	BEGIN TRY

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
			CONVERT(XML,'<strData><data><![CDATA[' + REPLACE([strData],CHAR(124), ']]></data><data><![CDATA[') + ']]></data></strData>') AS xmlData
		FROM #tmpVoucherCorrigonStage
	),
	DTNHeader AS (
		--HEADER
		SELECT 
			xmlData.value('/strData[1]/data[1]','VARCHAR(2)') AS strRecordCode,
			xmlData.value('/strData[1]/data[2]','VARCHAR(10)') AS strDocNum,
			xmlData.value('/strData[1]/data[3]','VARCHAR(25)') AS strCustVendNum,
			xmlData.value('/strData[1]/data[4]','VARCHAR(25)') AS strVendorOrderNumber,
			xmlData.value('/strData[1]/data[5]','DATE') AS dtmInvDate,
			xmlData.value('/strData[1]/data[6]','VARCHAR(12)') AS strInvoiceType,
			xmlData.value('/strData[1]/data[7]','VARCHAR(50)') AS strPONumber,
			xmlData.value('/strData[1]/data[8]','VARCHAR(3)') AS strCurrency,
			xmlData.value('/strData[1]/data[9]','DECIMAL(18,2)') AS dblTotal,
			xmlData.value('/strData[1]/data[10]','DECIMAL(18,2)') AS dblTax,
			xmlData.value('/strData[1]/data[11]','DECIMAL(18,2)') AS dblTotalTax,
			xmlData.value('/strData[1]/data[12]','DECIMAL(18,2)') AS dblFreightAmount,
			xmlData.value('/strData[1]/data[13]','DECIMAL(18,2)') AS dblTotalFreightAmount,
			xmlData.value('/strData[1]/data[14]','DECIMAL(18,2)') AS dblAuthorizedPaymentAmt,
			xmlData.value('/strData[1]/data[15]','VARCHAR(15)') AS strSource,
			xmlData.value('/strData[1]/data[16]','DATE') AS dtmEntryDate,
			xmlData.value('/strData[1]/data[17]','VARCHAR(500)') AS strImportFileName,
			xmlData.value('/strData[1]/data[18]','DATE') AS dtmSubmitDate,
			xmlData.value('/strData[1]/data[19]','VARCHAR(1000)') AS strNotes,
			xmlData.value('/strData[1]/data[20]','VARCHAR(4)') AS strStatus,
			xmlData.value('/strData[1]/data[21]','VARCHAR(20)') AS strPaymentRefNum,
			xmlData.value('/strData[1]/data[22]','DATE') AS dtmScheduledPayDate,
			xmlData.value('/strData[1]/data[23]','DECIMAL(18,2)') AS dblDiscAmnt,
			xmlData.value('/strData[1]/data[24]','DECIMAL(18,2)') AS dblLineSum,
			xmlData.value('/strData[1]/data[25]','VARCHAR(10)') AS strBusinessUnitId,
			xmlData.value('/strData[1]/data[26]','VARCHAR(1024)') AS strApproverNotes,
			xmlData.value('/strData[1]/data[27]','INT') AS intIssueCount,
			xmlData.value('/strData[1]/data[28]','VARCHAR(4)') AS strPaymentMethod,
			xmlData.value('/strData[1]/data[29]','DATE') AS dtmApprovalDate,
			xmlData.value('/strData[1]/data[30]','VARCHAR(1024)') AS strExternalLink
		--INTO #tmpVoucherStandardHeader
		FROM Split_Names
		WHERE xmlData.value('/strData[1]/data[1]','VARCHAR(2)') = '01'
	),
	DTNHeader2_tmp AS (
		--HEADER
		SELECT 
			xmlData.value('/strData[1]/data[1]','VARCHAR(2)') AS strRecordCode,
			xmlData.value('/strData[1]/data[2]','VARCHAR(10)') AS strDocNum,
			xmlData.value('/strData[1]/data[3]','INT') AS intCFNbrId,
			xmlData.value('/strData[1]/data[4]','VARCHAR(40)') AS strCFNbr
		FROM Split_Names A
		WHERE 
			xmlData.value('/strData[1]/data[1]','VARCHAR(2)') = '02'
		AND xmlData.value('/strData[1]/data[3]', 'INT') IN (2,3,5,7,11)
	),
	DTNHeader2 AS (
		SELECT
			A.strDocNum,
			A.strCFNbr AS strPayTo,
			B.strCFNbr AS strCheckComments,
			C.strCFNbr AS ysnGenerateTax,
			D.strCFNbr AS ysnHold,
			E.strCFNbr AS strShipTo
		FROM DTNHeader2_tmp A
		LEFT JOIN DTNHeader2_tmp B ON A.strDocNum = B.strDocNum AND B.intCFNbrId = 3
		LEFT JOIN DTNHeader2_tmp C ON A.strDocNum = C.strDocNum AND C.intCFNbrId = 5
		LEFT JOIN DTNHeader2_tmp D ON A.strDocNum = D.strDocNum AND D.intCFNbrId = 7
		LEFT JOIN DTNHeader2_tmp E ON A.strDocNum = E.strDocNum AND E.intCFNbrId = 11
		WHERE A.intCFNbrId = 2
	),
	DTNHeader3_Payment AS (
		SELECT
			xmlData.value('/strData[1]/data[1]','VARCHAR(2)') AS strRecordCode,
			xmlData.value('/strData[1]/data[2]','VARCHAR(10)') AS strDocNum,
			xmlData.value('/strData[1]/data[4]','VARCHAR(10)') AS strTermCode,
			xmlData.value('/strData[1]/data[6]','VARCHAR(50)') AS strTermDesc,
			xmlData.value('/strData[1]/data[9]','DATE') AS dtmDueDate,
			xmlData.value('/strData[1]/data[13]','DATE') AS dtmDiscountDate
		FROM Split_Names
		WHERE xmlData.value('/strData[1]/data[1]','VARCHAR(2)') = '05'
	),
	DTNDetail AS (
		SELECT
			xmlData.value('/strData[1]/data[1]','VARCHAR(2)') AS strRecordCode,
			xmlData.value('/strData[1]/data[2]','VARCHAR(10)') AS strDocNum,
			xmlData.value('/strData[1]/data[3]','INT') AS intLineNo,
			xmlData.value('/strData[1]/data[4]','INT') AS intDistributionNo,
			xmlData.value('/strData[1]/data[5]','DECIMAL(18,2)') AS dblQuantity,
			xmlData.value('/strData[1]/data[6]','DECIMAL(18,2)') AS dblTotal
		FROM Split_Names
		WHERE xmlData.value('/strData[1]/data[1]','VARCHAR(2)') = '41'
	),
	DTNDetail_GLtmp AS (
		SELECT
			xmlData.value('/strData[1]/data[1]','VARCHAR(2)') AS strRecordCode,
			xmlData.value('/strData[1]/data[2]','VARCHAR(10)') AS strDocNum,
			xmlData.value('/strData[1]/data[3]','INT') AS intLineNo,
			xmlData.value('/strData[1]/data[4]','INT') AS intDistributionNo,
			xmlData.value('/strData[1]/data[5]','INT') AS intCFNbrId,
			xmlData.value('/strData[1]/data[6]','VARCHAR(10)') AS strCFNbr
		FROM Split_Names
		WHERE 
			xmlData.value('/strData[1]/data[1]','VARCHAR(2)') = '42'
		AND xmlData.value('/strData[1]/data[5]','INT') IN (1,2,3,4)
	),
	DTNDetail_GL AS (
		SELECT
			A.strDocNum,
			A.intDistributionNo,
			A.strCFNbr + '-' + B.strCFNbr + '-' + C.strCFNbr + '-' + D.strCFNbr AS strDetailAccount
		FROM DTNDetail_GLtmp A
		LEFT JOIN DTNDetail_GLtmp B ON A.strDocNum = B.strDocNum AND B.intCFNbrId = 2 AND A.intDistributionNo = B.intDistributionNo
		LEFT JOIN DTNDetail_GLtmp C ON A.strDocNum = C.strDocNum AND C.intCFNbrId = 3 AND A.intDistributionNo = C.intDistributionNo
		LEFT JOIN DTNDetail_GLtmp D ON A.strDocNum = D.strDocNum AND D.intCFNbrId = 4 AND A.intDistributionNo = D.intDistributionNo
		WHERE A.intCFNbrId = 1
	)
	
	INSERT INTO #tmppayablesInfo(
		intPartitionId
		,intTransactionType
		,strVendorOrderNumber
		,intEntityVendorId
		,intShipToId
		,strShipToName
		,intShipFromId
		,strShipFromName
		,strReference
		,intPayToId
		,strPayTo
		,intCurrencyId
		,dblCost
		,dblQuantityToBill
		,dblQuantityOrdered
		,intContactId
		,strCurrency
		,intDetailAccountId
		,strDetailAccountId
		,dtmDate
		,dtmDueDate
		,dtmVoucherDate
		,intTermId
		,strTerm
		,strComment
		,strRemarks
		--,strPONumber
		--,intPurchaseDetailId
		,ysnHold
		,ysnGenerateTax
		,intLineNo
	)
	SELECT --*
		intPartitionId					= 	DENSE_RANK() OVER(ORDER BY A.strDocNum)
		,intTransactionType				=	CASE WHEN A.dblTotal < 0 THEN 3 ELSE 1 END
		,strVendorOrderNumber			=	A.strVendorOrderNumber
		,intEntityVendorId				=	C.intEntityId
		,intShipToId					=	E.intCompanyLocationId
		,strShipToName					=	A2.strShipTo
		,intShipFromId					=	F.intEntityLocationId
		,strShipFromName				=	A2.strPayTo
		,strReference					=	NULL
		,intPayToId						=	F.intEntityLocationId	
		,strPayTo						=	A2.strPayTo
		,intCurrencyId					=	H.intCurrencyID
		,dblCost						=	A4.dblTotal
		,dblQuantityToBill				=	IIF(A4.dblQuantity=0,1,A4.dblQuantity)
		,dblQuantityOrdered				=	IIF(A4.dblQuantity=0,1,A4.dblQuantity)
		,intContactId					=	C3.intEntityId
		,strCurrency					=	A.strCurrency
		,intDetailAccountId				=	I.intAccountId
		,strDetailAccountId				=	I.strAccountId
		,dtmDate						=	A.dtmSubmitDate
		,dtmDueDate						=	A3.dtmDueDate
		,dtmVoucherDate					=	A.dtmInvDate
		,intTermId						=	G.intTermID
		,strTerm						=	A3.strTermDesc
		,strComment						=	A2.strCheckComments
		,strRemarks						=	A.strNotes
		--,strPONumber					=	B.strPONo
		--,intPurchaseDetailId			=	S2.intPurchaseDetailId
		,ysnHold						=	A2.ysnHold
		,ysnGenerateTax					=	A2.ysnGenerateTax
		,intLineNo						=	A4.intDistributionNo
	FROM DTNHeader A
	INNER JOIN DTNHeader2 A2 ON A.strDocNum = A2.strDocNum
	INNER JOIN DTNHeader3_Payment A3 ON A.strDocNum = A3.strDocNum
	INNER JOIN DTNDetail A4 ON A.strDocNum = A4.strDocNum
	INNER JOIN DTNDetail_GL A5 ON A.strDocNum = A5.strDocNum AND A4.intDistributionNo = A5.intDistributionNo
	LEFT JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON C.intEntityId = D.intEntityId) ON A.strCustVendNum = D.strEntityNo
	LEFT JOIN (tblEMEntityToContact C2 INNER JOIN tblEMEntity C3 ON C2.intEntityId = C3.intEntityId)
		ON C2.ysnDefaultContact = 1 AND C2.intEntityId = C.intEntityId
	LEFT JOIN tblEMEntityLocation F ON F.strLocationName = A2.strPayTo AND D.intEntityId = F.intEntityId
	LEFT JOIN tblEMEntityLocation F2 ON F.strLocationName = A2.strPayTo AND D.intEntityId = F2.intEntityId
	LEFT JOIN tblSMCompanyLocation E ON E.strLocationNumber = A2.strShipTo
	LEFT JOIN tblSMTerm G ON G.strTermCode = A3.strTermCode
	LEFT JOIN tblSMCurrency H ON H.strCurrency = A.strCurrency
	LEFT JOIN vyuGLAccountDetail I ON I.strAccountId = A5.strDetailAccount
	LEFT JOIN (tblPOPurchase S INNER JOIN tblPOPurchaseDetail S2 ON S.intPurchaseId = S2.intPurchaseId)
		ON S.strPurchaseOrderNumber = A.strPONumber 

	--SELECT * FROM #tmppayablesInfo

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(2000)
		DECLARE @err NVARCHAR(100) = 'Invalid data found.'
		SET @ErrorMessage = ERROR_MESSAGE() + ' ' + @err;
		RAISERROR(@ErrorMessage, 16, 1);
	END CATCH
END

	INSERT INTO @voucherPayables(
		intPartitionId
		,strVendorOrderNumber
		,intTransactionType
		,intEntityVendorId
		,intLocationId
		,intShipToId
		,intShipFromId
		,intCurrencyId
		--,strMiscDescription
		,strCheckComment
		,strRemarks
		--,intItemId
		,dblCost
		,dblOrderQty
		,dblQuantityToBill
		,dtmDate
		,dtmDueDate
		,dtmVoucherDate
		,intTermId
		,intPayToAddressId
		,intAccountId
		,intLineNo
		,ysnStage
	)
	SELECT
		intPartitionId			= 	intPartitionId, --1 voucher per 1 payable
		strVendorOrderNumber	=	strVendorOrderNumber,
		intTransactionType 		=	intTransactionType,
		intEntityVendorId		=	intEntityVendorId,
		intLocationId			=	intShipToId,
		intShipToId				=	intShipToId,
		intShipFromId			=	intShipFromId,
		intCurrencyId			=	intCurrencyId,
		strCheckComment			=	strComment,
		strRemarks				=	strRemarks,
		--intItemId				=	intItemId,
		dblCost					=	dblCost,
		dblOrderQty				=	dblQuantityOrdered,
		dblQuantityToBill		=	dblQuantityToBill,
		dtmDate					=	dtmDate,
		dtmDueDate				=	dtmDueDate,
		dtmVoucherDate			=	dtmVoucherDate,
		intTermId				=	intTermId,
		intPayToAddressId		=	intPayToId,
		intAccountId			=	intDetailAccountId,
		intLineNo				=	intLineNo,
		ysnStage				=	0
	FROM #tmppayablesInfo
	WHERE
		intEntityVendorId IS NOT NULL

	--SELECT '' [tmppayablesInfo], * FROM #tmppayablesInfo
	--SELECT ''[voucherPayables],* FROM @voucherPayables

	--VALIDATE
	DECLARE @totalIssues INT;
	
	SELECT @totalIssues = COUNT(*)
	FROM #tmppayablesInfo
	WHERE 
		intEntityVendorId IS NULL --NO VENDOR

	DECLARE @invalidPayables AS TABLE (strVendorOrderNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS, strError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS)
	INSERT INTO @invalidPayables
	SELECT strVendorOrderNumber, strError
	FROM (
		SELECT intPartitionId, strVendorOrderNumber, 'Cannot find vendor ' + strVendorId + ' for Invoice No. ' + strVendorOrderNumber AS strError 
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
		WHERE A.intShipToId IS NULL AND (A.strShipToName != '' AND A.strShipToName IS NOT NULL)
		--UNION ALL
		--SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find PO number ' + strPONumber AS strError 
		--FROM #tmppayablesInfo A
		--WHERE A.intPurchaseDetailId IS NULL AND (A.strPONumber != '' AND A.strPONumber IS NOT NULL)
		UNION ALL
		SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find pay to name ' + strPayTo AS strError 
		FROM #tmppayablesInfo A
		WHERE A.intPayToId IS NULL AND (A.strPayTo != '' AND A.strPayTo IS NOT NULL)
		UNION ALL
		SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Cannot find Currency ' + strCurrency AS strError 
		FROM #tmppayablesInfo A
		WHERE A.intCurrencyId IS NULL AND (A.strCurrency != '' AND A.strCurrency IS NOT NULL)
		UNION ALL
		SELECT intPartitionId, strVendorOrderNumber, 'Line with Invoice No. ' + strVendorOrderNumber + ': Invalid detail account ' + strDetailAccountId AS strError 
		FROM #tmppayablesInfo A
		WHERE intDetailAccountId IS NULL
	) tblErrors
	ORDER BY intPartitionId

	--VOUCHER AND POST VALID PAYABLES
	DECLARE @createdVoucher NVARCHAR(MAX);
	IF EXISTS(SELECT 1 FROM @voucherPayables)
	BEGIN

		SELECT ''[@voucherPayables],* FROM @voucherPayables
		EXEC uspAPCreateVoucher @voucherPayables = @voucherPayables, @userId = @userId, @throwError = 1, @createdVouchersId = @createdVoucher OUT

		IF @createdVoucher IS NULL 
		BEGIN 
			--DECLARE @batchIdUsed NVARCHAR(50);
			--DECLARE @failedPostCount INT;

			--EXEC uspAPPostBill
			--	@post				= 1,
			--	@recap				= 0,
			--	@isBatch			= 1,
			--	@param				= @createdVoucher,
			--	@userId				= @userId,
			--	@invalidCount		= @failedPostCount OUTPUT,
			--	@batchIdUsed		= @batchIdUsed OUTPUT
			RAISERROR('Unable to create voucher.', 16, 1);
		END
		ELSE
		BEGIN
			DECLARE @ids AS Id

			INSERT INTO @ids
			SELECT * FROM [dbo].fnGetRowsFromDelimitedValues(@createdVoucher)

			UPDATE A
			SET
				A.strHold = CASE WHEN C.ysnHold = 1 THEN 'Soft Hold' ELSE 'No Hold' END
			FROM tblAPBill A
			INNER JOIN @ids B ON A.intBillId = B.intId
			INNER JOIN #tmppayablesInfo C ON A.strVendorOrderNumber = C.strVendorOrderNumber

			--SELECT A.strReference, C.strAccountId, A.strComment, A.*
			--FROM tblAPBill A
			--INNER JOIN @ids B ON A.intBillId = B.intId
			--INNER JOIN vyuGLAccountDetail C ON A.intAccountId = C.intAccountId

			--REMOVE TAX IF NOT REQUIRED BY THE TEXT FILE

			UPDATE A
			SET
				A.intTaxGroupId = CASE WHEN C.ysnGenerateTax = 1 THEN tg.intTaxGroupId ELSE NULL END
			FROM tblAPBillDetail A
			INNER JOIN tblAPBill A2 ON A.intBillId = A2.intBillId
			INNER JOIN @ids B ON A.intBillId = B.intId
			INNER JOIN #tmppayablesInfo C ON A2.strVendorOrderNumber = C.strVendorOrderNumber
			CROSS APPLY (
				SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = 'Use Taxes'
			) tg

			--FORCE DELETE THE DETAIL TAX, IF NOT REQUIRED
			DELETE A 
			FROM tblAPBillDetailTax A
			INNER JOIN tblAPBillDetail B ON A.intBillDetailId = B.intBillDetailId
			INNER JOIN @ids C ON B.intBillId = C.intId
			WHERE B.intTaxGroupId IS NULL

			--SELECT A.intAccountId, C.strAccountId, A.dblRate, A.*
			--FROM tblAPBillDetail A
			--INNER JOIN @ids B ON A.intBillId = B.intId
			--LEFT JOIN vyuGLAccountDetail C ON A.intAccountId = C.intAccountId

			DECLARE @billDetailIds AS Id

			INSERT INTO @billDetailIds
			SELECT
				A.intBillDetailId
			FROM tblAPBillDetail A
			INNER JOIN @ids B ON A.intBillId = B.intId

			EXEC uspAPUpdateVoucherDetailTax  @billDetailIds

		END
	--END

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

	--SELECT @totalIssues [totalIssues]
	--SELECT @totalVoucherCreated [totalVoucherCreated]

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
	--IF @failedPostCount > 0
	--BEGIN
	--	INSERT INTO tblAPImportLogDetail
	--	(
	--		intImportLogId,
	--		strEventDescription
	--	)
	--	SELECT 
	--		@logId,
	--		A.strDescription
	--	FROM tblGLPostResult A
	--	WHERE 
	--		A.strBatchId = @batchIdUsed
	--	AND A.strDescription NOT LIKE '%success%'
	--END

	SELECT * FROM tblAPImportLog WHERE intImportLogId = @importLogId
	SELECT * FROM tblAPImportLogDetail WHERE intImportLogId = @importLogId

	SELECT * FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM @vouchers)
	SELECT * FROM tblAPBillDetail WHERE intBillId IN (SELECT intBillId FROM @vouchers)
	SELECT * FROM tblAPBillDetailTax WHERE intBillDetailId IN (SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId IN (SELECT intBillId FROM @vouchers))
	
END
ELSE
BEGIN
	RAISERROR('No record(s) imported.', 16, 1);
END

--ROLLBACK TRAN