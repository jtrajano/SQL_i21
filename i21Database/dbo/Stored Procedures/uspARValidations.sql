CREATE PROCEDURE [dbo].[uspARValidations]
	@UserId INT = 0 ,
	@Sucess BIT = 0 OUTPUT,
	@Message NVARCHAR(100) = '' OUTPUT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@LogKey NVARCHAR(100) = NULL OUTPUT

	AS

	--==========================
	--	CUSTOMER
	--==========================
	DECLARE @customerCount INT
	DECLARE @originCustomerCount INT
	DECLARE @ysnAG BIT = 0
    DECLARE @ysnPT BIT = 0
	DECLARE @key NVARCHAR(100) = NEWID()
	DECLARE @logDate DATETIME = GETDATE()

	SELECT TOP 1 @ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst	
	
	IF (@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0)
	BEGIN
		SET @StartDate = NULL
		SET @EndDate = NULL
	END	

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SELECT
			@originCustomerCount = COUNT(DISTINCT agivc_bill_to_cus)
			FROM
			agivcmst
			WHERE
			(
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)

		 END

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT
			@originCustomerCount = COUNT(DISTINCT ptivc_sold_to)
			FROM
			ptivcmst
			WHERE
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)

		 END

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SELECT
			@customerCount = COUNT(DISTINCT strCustomerNumber)
			FROM agivcmst
				INNER JOIN tblARCustomer ON agivcmst.agivc_bill_to_cus COLLATE Latin1_General_CI_AS = tblARCustomer.strCustomerNumber COLLATE Latin1_General_CI_AS
			WHERE
			(
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
		 END	
			
	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT
			@customerCount = COUNT(DISTINCT strCustomerNumber)
			FROM ptivcmst
				INNER JOIN tblARCustomer ON ptivcmst.ptivc_sold_to COLLATE Latin1_General_CI_AS = tblARCustomer.strCustomerNumber COLLATE Latin1_General_CI_AS
			WHERE
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
		 END	
			
	--SELECT
	--@customerCount = COUNT(DISTINCT agivc_bill_to_cus)
	--FROM
	--agivcmst
	--WHERE agivc_bill_to_cus COLLATE Latin1_General_CI_AS  not in 
	--(
	--	SELECT DISTINCT strCustomerNumber 
	--	FROM tblARCustomer 
	--	WHERE strCustomerNumber COLLATE Latin1_General_CI_AS not in 
	--		(
	--			SELECT
	--			DISTINCT agivc_bill_to_cus
	--			FROM
	--			agivcmst
	--		)
	--)
	
	IF(@originCustomerCount = @customerCount)
	BEGIN
		SET @Sucess = 1
	END
	IF(@originCustomerCount <> @customerCount)
	BEGIN
		SET @Sucess = 0
		SET @Message = 'There is a discrepancy on Customer records.'
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT DISTINCT (agivc_bill_to_cus) 
				,'Customer'
				,'Customers Missing in i21'
				,@UserId
				,@logDate
				,@key 
			FROM agivcmst WHERE agivc_bill_to_cus COLLATE Latin1_General_CI_AS  NOT IN 
					(select strCustomerNumber COLLATE Latin1_General_CI_AS FROM tblARCustomer)
		 END

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT DISTINCT (ptivc_sold_to) 
				,'Customer'
				,'Customers Missing in i21'
				,@UserId
				,@logDate
				,@key 
			FROM ptivcmst WHERE ptivc_sold_to COLLATE Latin1_General_CI_AS  NOT IN 
					(select strCustomerNumber COLLATE Latin1_General_CI_AS FROM tblARCustomer)
		 END
			
		RETURN;
	END
	
	--==========================
	--	SALESPERSON
	--==========================	
	DECLARE @salespersonCount INT
	DECLARE @originSalespersonCount INT
	
	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SELECT 
			@originSalespersonCount = COUNT(DISTINCT agivc_slsmn_no) 
			FROM agivcmst 
			WHERE agivc_slsmn_no IS NOT NULL
			AND 
			(
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
		 END

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT 
			@originSalespersonCount = COUNT(DISTINCT ptivc_sold_by) 
			FROM ptivcmst 
			WHERE ptivc_sold_by IS NOT NULL
			AND 
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
		 END

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SELECT
			@salespersonCount = COUNT(DISTINCT strSalespersonId)
			FROM agivcmst
				INNER JOIN tblARSalesperson ON agivcmst.agivc_slsmn_no COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
			WHERE 
			(
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
		 END
		 	
	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT
			@salespersonCount = COUNT(DISTINCT strSalespersonId)
			FROM ptivcmst
				INNER JOIN tblARSalesperson ON ptivcmst.ptivc_sold_by COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
			WHERE 
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
		 END
	
	IF(@originSalespersonCount = @salespersonCount)
	BEGIN
		SET @Sucess = 1
	END
	IF(@originSalespersonCount <> @salespersonCount)
	BEGIN
		SET @Sucess = 0
		SET @Message = 'There is a discrepancy on Salesperson records.'
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT DISTINCT (agivc_slsmn_no) 
				,'Salesperson'
				,'Salesperson Missing in i21'
				,@UserId
				,@logDate
				,@key 
			FROM agivcmst WHERE agivc_slsmn_no COLLATE SQL_Latin1_General_CP1_CS_AS  NOT IN 
					(select strSalespersonId  COLLATE SQL_Latin1_General_CP1_CS_AS from tblARSalesperson) 
		 END

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT DISTINCT (ptivc_sold_by) 
				,'Salesperson'
				,'Salesperson Missing in i21'
				,@UserId
				,@logDate
				,@key 
			FROM ptivcmst WHERE ptivc_sold_by COLLATE SQL_Latin1_General_CP1_CS_AS  NOT IN 
					(select strSalespersonId  COLLATE SQL_Latin1_General_CP1_CS_AS from tblARSalesperson) 
		 END
		RETURN;	
	END
		
	--==========================
	--	TERM
	--==========================	
	DECLARE @termCount INT
	DECLARE @originTermCount INT
	
	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SELECT 
			@originTermCount = COUNT(DISTINCT agivc_terms_code) 
			FROM agivcmst 
			WHERE agivc_terms_code IS NOT NULL
			AND 
			(
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)

		 END
	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT 
			@originTermCount = COUNT(DISTINCT ptivc_terms_code) 
			FROM ptivcmst 
			WHERE ptivc_terms_code IS NOT NULL
			AND 
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)

		 END

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SELECT
			@termCount = COUNT(DISTINCT strTerm)
			FROM tblSMTerm
			WHERE strTermCode COLLATE Latin1_General_CI_AS in (SELECT 
					DISTINCT (CASE WHEN SUBSTRING(agivc_terms_code,1, 1) = 0 THEN SUBSTRING(agivc_terms_code,2,1) ELSE agivc_terms_code END) COLLATE Latin1_General_CI_AS
					FROM agivcmst 
					WHERE agivc_terms_code IS NOT NULL
					AND 
						(
							((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
							OR
							((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
						))
		 END 

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT
			@termCount = COUNT(DISTINCT strTerm)
			FROM tblSMTerm
			WHERE strTermCode COLLATE Latin1_General_CI_AS in (SELECT 
					DISTINCT (CASE WHEN SUBSTRING(ptivc_terms_code,1, 1) = 0 THEN SUBSTRING(ptivc_terms_code,2,1) ELSE ptivc_terms_code END) COLLATE Latin1_General_CI_AS
					FROM ptivcmst 
					WHERE ptivc_terms_code IS NOT NULL
					AND 
						(
							((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
							OR
							((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
						))
		 END 

	IF(@originTermCount = @termCount)
	BEGIN
		SET @Sucess = 1
	END
	IF(@originTermCount <> @termCount)
	BEGIN
		SET @Sucess = 0
		SET @Message = 'There is a discrepancy on Term records.'
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT DISTINCT (CAST(Cast(agivc_terms_code AS INTEGER) AS VARCHAR)) 
				,'Term'
				,'Term code Missing in i21'
				,@UserId
				,@logDate
				,@key  
			FROM agivcmst WHERE agivc_terms_code  IS NOT NULL AND CAST(Cast(agivc_terms_code AS INTEGER) AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CS_AS 
			NOT IN (select strTermCode SQL_Latin1_General_CP1_CS_AS from tblSMTerm)
		 END

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT DISTINCT (CAST(Cast(ptivc_terms_code AS INTEGER) AS VARCHAR)) 
				,'Term'
				,'Term code Missing in i21'
				,@UserId
				,@logDate
				,@key  
			FROM ptivcmst WHERE ptivc_terms_code  IS NOT NULL AND CAST(Cast(ptivc_terms_code AS INTEGER) AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CS_AS 
			NOT IN (select strTermCode SQL_Latin1_General_CP1_CS_AS from tblSMTerm)				
		 END
			
		RETURN;	
	END


	--==========================
	--	Company Location Setup
	--==========================		
	DECLARE @CompanyLocation VARCHAR(250)
	--AR Account
	SET @CompanyLocation = 
	(
		--SELECT strValue FROM tblSMPreferences WHERE strPreference = 'DefaultARAccount'
		SELECT [intARAccountId] FROM tblARCompanyPreference

	)

	IF NOT(@CompanyLocation IS NULL OR LTRIM(RTRIM(@CompanyLocation)) = '' OR @CompanyLocation = 0)
	BEGIN
		SET @Sucess = 1
	END
	ELSE
	BEGIN
		SET @Sucess = 0
		SET @Message = 'The AR Account in the Company Configuration was not set.'
		RETURN;	
	END

	--Service Charge Account
	SET @CompanyLocation = NULL

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SET @CompanyLocation = 
			(SELECT TOP 1 CL.strLocationName
			FROM agivcmst
			LEFT JOIN tblARInvoice Inv ON agivcmst.agivc_ivc_no COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = agivc_bill_to_cus COLLATE Latin1_General_CI_AS
			INNER JOIN tblARSalesperson Salesperson ON strSalespersonId COLLATE Latin1_General_CI_AS = agivc_slsmn_no COLLATE Latin1_General_CI_AS
			INNER JOIN tblSMCompanyLocation CL ON agivcmst.agivc_loc_no COLLATE Latin1_General_CI_AS = CL.strLocationNumber  COLLATE Latin1_General_CI_AS
			WHERE Inv.strInvoiceNumber IS NULL AND agivcmst.agivc_ivc_no = UPPER(agivcmst.agivc_ivc_no) COLLATE Latin1_General_CS_AS
			AND (
					((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
				)
			AND (CL.intServiceCharges IS NULL OR CL.intServiceCharges = 0))
			IF(@CompanyLocation IS NULL)
			BEGIN
				SET @Sucess = 1
			END
			IF(@CompanyLocation IS NOT NULL)
			BEGIN
				SET @Sucess = 0
				SET @Message = 'The Service Charge Account of Company Location - ' + @CompanyLocation + ' was not set.'
				RETURN;	
			END

		 END

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SET @CompanyLocation = (SELECT intServiceChargeAccountId FROM tblARCompanyPreference)
			IF(@CompanyLocation IS NOT NULL)
			BEGIN
				SET @Sucess = 1
			END
			IF(@CompanyLocation IS NULL)
			BEGIN
				SET @Sucess = 0
				SET @Message = 'The Service Charge Account in the Company Configuration was not set.'
				RETURN;	
			END
		 END

	IF @Sucess = 0
		SET @LogKey = @key

