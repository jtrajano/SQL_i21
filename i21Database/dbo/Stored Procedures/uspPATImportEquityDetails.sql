CREATE PROCEDURE [dbo].[uspPATImportEquityDetails]
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

SELECT @isImported = ysnIsImported FROM tblPATImportOriginFlag WHERE intImportOriginLogId = 8;

IF(@isImported = 0)
BEGIN
	
	IF EXISTS(SELECT 1 FROM tblPATImportOriginFlag WHERE intImportOriginLogId = 4 AND ysnIsImported = 0)
	BEGIN
		SET @isDisabled = 1;
		RETURN @isDisabled;
	END

	DECLARE @EquityType_Undistributed AS NVARCHAR(50) = 'Undistributed' COLLATE Latin1_General_CI_AS;
	DECLARE @EquityType_Reserve AS NVARCHAR(50) = 'Reserve' COLLATE Latin1_General_CI_AS;
	DECLARE @EntityType_Customer AS NVARCHAR(50) = 'Customer' COLLATE Latin1_General_CI_AS;

	DECLARE @FiscalYear_Oldest AS INT;
	SELECT TOP 1 @FiscalYear_Oldest = intFiscalYearId FROM tblGLFiscalYear ORDER BY dtmDateFrom ASC;


	CREATE TABLE #customerEquityOriginStaging(
		[intTempId]			INT IDENTITY PRIMARY KEY,
		[strCustomerNo]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
		[strFiscalYear]		NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL, 
		[strEquityType]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strRefundType]		CHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
		[dblEquity]			NUMERIC(18,6) NOT NULL DEFAULT 0
	)

	CREATE TABLE #customerEquityi21Staging(
		[intTempId]			INT IDENTITY PRIMARY KEY,
		[intEntityId]		INT NULL,
		[strCustomerNo]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
		[strEntityType]		NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
		[intFiscalYearId]	INT NULL,
		[strFiscalYear]		NVARCHAR (10) COLLATE Latin1_General_CI_AS NULL, 
		[strEquityType]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intRefundTypeId]	INT NULL,
		[strRefundType]		CHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
		[dblEquity]			NUMERIC(18,6) NOT NULL DEFAULT 0
	)

	INSERT INTO #customerEquityOriginStaging(strCustomerNo, strFiscalYear, strRefundType, strEquityType, dblEquity)
	SELECT pahst_cus_no COLLATE Latin1_General_CI_AS, CAST(pahst_ccyy AS NVARCHAR(10)) COLLATE Latin1_General_CI_AS, CAST(pahst_rfd_type AS CHAR(5)) COLLATE Latin1_General_CI_AS, @EquityType_Undistributed as EquityType, sum(pahst_undist_equity) pahst_undist_equity FROM pahstmst
	group by pahst_cus_no, pahst_ccyy, pahst_rfd_type
	having sum(pahst_undist_equity) > 0
	UNION ALL
	SELECT pahst_cus_no COLLATE Latin1_General_CI_AS, CAST(pahst_ccyy AS NVARCHAR(10)) COLLATE Latin1_General_CI_AS, CAST(pahst_rfd_type AS CHAR(5)) COLLATE Latin1_General_CI_AS, @EquityType_Reserve as EquityType, sum(pahst_undist_res) pahst_undist_res FROM pahstmst
	group by pahst_cus_no, pahst_ccyy, pahst_rfd_type
	having sum(pahst_undist_res) > 0

	------------------- BEGIN - RETURN COUNT TO BE IMPORTED ----------------------------
	SELECT @total = COUNT(*) FROM #customerEquityOriginStaging

	IF(@checking = 1)
	BEGIN
		RETURN @total;
	END
	------------------- END - RETURN COUNT TO BE IMPORTED ----------------------------


	------------------- BEGIN - MATCH ORIGIN VALUES TO i21 VALUES ----------------------------
	INSERT INTO #customerEquityi21Staging(
		intEntityId,
		strCustomerNo,
		strEntityType,
		intFiscalYearId,
		strFiscalYear,
		strEquityType,
		intRefundTypeId,
		strRefundType,
		dblEquity)
	SELECT 
		CustomerEntity.intEntityId,
		originStaging.strCustomerNo,
		CustomerEntity.strType,
		FiscalYear.intFiscalYearId,
		originStaging.strFiscalYear,
		originStaging.strEquityType,
		RefundRate.intRefundTypeId,
		originStaging.strRefundType,
		originStaging.dblEquity		
	FROM #customerEquityOriginStaging originStaging
	LEFT JOIN vyuEMEntity CustomerEntity
		ON CustomerEntity.strEntityNo = originStaging.strCustomerNo AND CustomerEntity.strType = @EntityType_Customer
	LEFT JOIN tblPATRefundRate RefundRate
		ON RefundRate.strRefundType = originStaging.strRefundType
	LEFT JOIN tblGLFiscalYear FiscalYear
		ON FiscalYear.strFiscalYear = originStaging.strFiscalYear
	------------------- END - MATCH ORIGIN VALUES TO i21 VALUES ----------------------------


	------------------- BEGIN - MERGE/INSERT ORIGIN ROWS INTO CUSTOMER EQUITY TABLE ----------------------------
	MERGE
	INTO dbo.tblPATCustomerEquity
	WITH (HOLDLOCK)
	AS CustomerEquity
	USING (SELECT * FROM #customerEquityi21Staging WHERE intEntityId IS NOT NULL AND intRefundTypeId IS NOT NULL) AS StagingCustomerEquity
		ON StagingCustomerEquity.intEntityId = CustomerEquity.intCustomerId
		AND StagingCustomerEquity.intRefundTypeId = CustomerEquity.intRefundTypeId
		AND StagingCustomerEquity.strEquityType = CustomerEquity.strEquityType
	WHEN MATCHED THEN
		UPDATE	SET
				CustomerEquity.dblEquity = CustomerEquity.dblEquity + StagingCustomerEquity.dblEquity
	WHEN NOT MATCHED THEN
		INSERT (
			intCustomerId,
			intFiscalYearId,
			strEquityType,
			intRefundTypeId,
			dblEquity
		)
		VALUES(
			StagingCustomerEquity.intEntityId,
			CASE WHEN StagingCustomerEquity.intFiscalYearId IS NOT NULL THEN StagingCustomerEquity.intFiscalYearId ELSE @FiscalYear_Oldest END,
			StagingCustomerEquity.strEquityType,
			StagingCustomerEquity.intRefundTypeId,
			StagingCustomerEquity.dblEquity
		)
	;
	------------------- END - INSERT ORIGIN ROWS INTO CUSTOMER EQUITY TABLE ----------------------------

	------------------- BEGIN - UPDATE ORIGIN FLAGGING TABLE ----------------------------
	UPDATE tblPATImportOriginFlag
	SET ysnIsImported = 1, intImportCount = @total
	WHERE intImportOriginLogId = 8

	SET @isImported = CAST(1 AS BIT);
	------------------- END - UPDATE ORIGIN FLAGGING TABLE ----------------------------

	
END
END