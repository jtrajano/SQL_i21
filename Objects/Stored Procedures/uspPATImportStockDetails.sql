CREATE PROCEDURE [dbo].[uspPATImportStockDetails]
	@checking BIT = 0,
	@isImported BIT = 0 OUTPUT,
	@isDisabled BIT = 0 OUTPUT,
	@total INT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


SELECT @isImported = ysnIsImported FROM tblPATImportOriginFlag WHERE intImportOriginLogId = 6;

IF(@isImported = 0)
BEGIN

	IF EXISTS(SELECT 1 FROM tblPATImportOriginFlag WHERE intImportOriginLogId = 3 AND ysnIsImported = 0)
	BEGIN
		SET @isDisabled = 1;
		RETURN @isDisabled;
	END

	DECLARE @customerStockTable TABLE(
		[intTempId] INT IDENTITY PRIMARY KEY,
		[intCustomerPatronId] INT NOT NULL, 
		[intStockId] INT,
		[strCertificateNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,		
		[strIssueNo] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
		[strRetireNo] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
		[strStockStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
		[dblSharesNo] NUMERIC(18, 6),
		[dtmIssueDate] DATETIME, 
		[strActivityStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
		[dtmRetireDate] DATETIME,
		[intTransferredFrom] INT,
		[dtmTransferredDate] DATETIME,
		[dblParValue] NUMERIC(18, 6),
		[dblFaceValue] NUMERIC(18, 6)
	)

	DECLARE @stockClassTemp TABLE(
		[intId] INT,
		[strStockName] NVARCHAR(50)
	);

	---------------------------- BEGIN - GET STOCK CLASSIFICATION FROM ORIGIN -----------------------
	INSERT INTO @stockClassTemp(intId, strStockName)
	SELECT 1, pactl_stock_desc_1 FROM pactlmst WHERE pactl_key ='01'
	UNION
	SELECT 2, pactl_stock_desc_2 FROM pactlmst WHERE pactl_key ='01'
	UNION
	SELECT 3, pactl_stock_desc_3 FROM pactlmst WHERE pactl_key ='01'
	UNION
	SELECT 4, pactl_stock_desc_4 FROM pactlmst WHERE pactl_key ='01'
	UNION
	SELECT 5, pactl_stock_desc_5 FROM pactlmst WHERE pactl_key ='01'
	UNION
	SELECT 6, pactl_stock_desc_6 FROM pactlmst WHERE pactl_key ='01'
	UNION
	SELECT 7, pactl_stock_desc_7 FROM pactlmst WHERE pactl_key ='01'
	UNION
	SELECT 8, pactl_stock_desc_8 FROM pactlmst WHERE pactl_key ='01'
	UNION
	SELECT 9, pactl_stock_desc_9 FROM pactlmst WHERE pactl_key ='01'
	UNION
	SELECT 10, pactl_stock_desc_10 FROM pactlmst WHERE pactl_key ='01'
	---------------------------- END - GET STOCK CLASSIFICATION FROM ORIGIN -----------------------
	

	---------------------------- BEGIN - INSERT INTO CUSTOMER STOCK TEMPORARY TABLE -----------------------
	INSERT INTO @customerStockTable(intCustomerPatronId, intStockId, strCertificateNo, strStockStatus, dblSharesNo, dtmIssueDate, strActivityStatus, dtmRetireDate, intTransferredFrom, dtmTransferredDate, dblParValue, dblFaceValue)
	SELECT	EM.intEntityId AS intCustomerPatronId,
			SC.intStockId AS intStockId,
			PAST.pastk_cert_no AS strCertificateNo, 
			CASE UPPER(PAST.pastk_stock_status) WHEN 'V' THEN 'Voting' WHEN 'N' THEN 'Non-Voting' WHEN 'O' THEN 'Other' END AS strStockStatus, 
			PAST.pastk_no_shares AS dblSharesNo,
			CASE WHEN PAST.pastk_issue_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PAST.pastk_issue_rev_dt AS CHAR (12)), 112)) ELSE NULL END AS dtmIssueDate,
			CASE WHEN PAST.pastk_activity_cd = 'R' THEN 'Retired' WHEN PAST.pastk_activity_cd = 'X' THEN 'Xferred' ELSE 'Open' END AS strActivityStatus,
			NULL,
			EMX.intEntityId AS intTransferredFrom,
			CASE WHEN PAST.pastk_xfer_from_rev_dt != 0 THEN (CONVERT (DATETIME, CAST (PAST.pastk_xfer_from_rev_dt AS CHAR (12)), 112)) ELSE NULL END AS dtmTransferredDate,
			SC.dblParValue,
			(SC.dblParValue * PAST.pastk_no_shares) AS dblFaceValue
	FROM pastkmst PAST
	INNER JOIN vyuEMEntity EM
		ON EM.strEntityNo = RTRIM(PAST.pastk_cus_no) COLLATE Latin1_General_CI_AS AND (EM.strType = 'Customer' OR EM.strType = 'Vendor')
	LEFT OUTER JOIN vyuEMEntity EMX
		ON EMX.strEntityNo = RTRIM(PAST.pastk_xfer_from_cus_no) COLLATE Latin1_General_CI_AS AND (EMX.strType = 'Customer' OR EMX.strType = 'Vendor')
	INNER JOIN @stockClassTemp tempSC
		ON tempSC.intId = PAST.pastk_stock_type
	INNER JOIN tblPATStockClassification SC
		ON SC.strStockName = tempSC.strStockName COLLATE Latin1_General_CI_AS 
	---------------------------- END - INSERT INTO CUSTOMER STOCK TEMPORARY TABLE -----------------------
	

	---------------------------- BEGIN - COUNT ORIGIN DATA TO BE IMPORTED -----------------------
	IF(@checking = 1)
	BEGIN
		SELECT @total = COUNT(*) FROM @customerStockTable tempCS
		WHERE strCertificateNo NOT IN (SELECT strCertificateNo FROM tblPATIssueStock)
		RETURN @total;
	END
	---------------------------- END - COUNT ORIGIN DATA TO BE IMPORTED -----------------------
	
	---------------------------- BEGIN - ASSIGN ISSUE & RETIRE STARTING NUMBER -----------------------
	WHILE EXISTS(SELECT 1 FROM @customerStockTable tempCS WHERE strIssueNo IS NULL OR strRetireNo IS NULL)
	BEGIN
		DECLARE @customerStockId INT;
		DECLARE @strIssueNo NVARCHAR(50) = NULL;
		DECLARE @strRetireNo NVARCHAR(50) = NULL;

		SELECT TOP 1 @customerStockId = intTempId FROM @customerStockTable;
		EXEC [dbo].[uspSMGetStartingNumber] 126, @strIssueNo out;

		IF EXISTS(SELECT 1 FROM @customerStockTable WHERE intTempId = @customerStockId AND strActivityStatus = 'Retired')
		BEGIN
			EXEC [dbo].[uspSMGetStartingNumber] 126, @strRetireNo out;
		END
		UPDATE @customerStockTable
		SET strIssueNo = @strIssueNo, strRetireNo = @strRetireNo
		WHERE intTempId = @customerStockId;
	END
	---------------------------- END - ASSIGN ISSUE & RETIRE STARTING NUMBER -----------------------

	---------------------------- BEGIN - INSERT INTO ISSUE STOCK TABLE -----------------------
	INSERT INTO tblPATIssueStock(intCustomerPatronId, strIssueNo, intStockId, strCertificateNo, strStockStatus, dblSharesNo, dblParValue, dblFaceValue)
	SELECT	tempCS.intCustomerPatronId, tempCS.strIssueNo, tempCS.intStockId, tempCS.strCertificateNo, tempCS.strStockStatus, tempCS.dblSharesNo, tempCS.dblParValue, tempCS.dblFaceValue
	FROM @customerStockTable tempCS
	WHERE strCertificateNo NOT IN (SELECT strCertificateNo FROM tblPATIssueStock)
	---------------------------- END - INSERT INTO ISSUE STOCK TABLE -----------------------

	---------------------------- BEGIN - INSERT INTO CUSTOMER STOCK TABLE -----------------------
	INSERT INTO tblPATCustomerStock(intCustomerPatronId, intStockId, strCertificateNo, strStockStatus, dblSharesNo, strActivityStatus, intTransferredFrom, dtmTransferredDate, dblParValue, dblFaceValue)
	SELECT	tempCS.intCustomerPatronId, tempCS.intStockId, tempCS.strCertificateNo, tempCS.strStockStatus, tempCS.dblSharesNo, tempCS.strActivityStatus, tempCS.intTransferredFrom, tempCS.dtmTransferredDate, tempCS.dblParValue, tempCS.dblFaceValue
	FROM @customerStockTable tempCS
	WHERE strCertificateNo NOT IN (SELECT strCertificateNo FROM tblPATIssueStock)
	---------------------------- END - INSERT INTO CUSTOMER STOCK TABLE -----------------------

	---------------------------- BEGIN - INSERT INTO CUSTOMER STOCK TABLE -----------------------
	INSERT INTO tblPATRetireStock(intCustomerPatronId, strRetireNo, dblSharesNo, dtmRetireDate, dblParValue, dblFaceValue)
	SELECT	tempCS.intCustomerPatronId, tempCS.strRetireNo, tempCS.dblSharesNo, tempCS.dtmRetireDate, tempCS.dblParValue, tempCS.dblFaceValue
	FROM @customerStockTable tempCS
	WHERE strCertificateNo NOT IN (SELECT strCertificateNo FROM tblPATIssueStock)
	AND strActivityStatus = 'Retire'
	---------------------------- END - INSERT INTO CUSTOMER STOCK TABLE -----------------------

	UPDATE tblPATImportOriginFlag
	SET ysnIsImported = 1
	WHERE intImportOriginLogId = 6

	SET @isImported = CAST(1 AS BIT);

END
END