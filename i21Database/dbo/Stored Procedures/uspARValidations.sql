﻿CREATE PROCEDURE [dbo].[uspARValidations]
	@UserId INT = 0 ,
	@Sucess BIT = 0 OUTPUT,
	@Message NVARCHAR(MAX) = '' OUTPUT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL

	AS
	declare @current_date datetime
	set @current_date = getdate()
	--==========================
	--	CUSTOMER
	--==========================
	DECLARE @customerCount INT
	DECLARE @originCustomerCount INT
	DECLARE @ysnAG BIT = 0
    DECLARE @ysnPT BIT = 0
	DECLARE @key NVARCHAR(100) = NEWID()
	DECLARE @logDate DATETIME = @current_date

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
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and agivc_bal_due <> 0

		 END

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT
			@originCustomerCount = COUNT(DISTINCT ptivc_sold_to)
			FROM
			ptivcmst
			WHERE
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and ptivc_bal_due <> 0

		 END

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SELECT
			@customerCount = COUNT(DISTINCT strCustomerNumber)
			FROM agivcmst
				INNER JOIN tblARCustomer ON agivcmst.agivc_bill_to_cus COLLATE Latin1_General_CI_AS = tblARCustomer.strCustomerNumber COLLATE Latin1_General_CI_AS
			WHERE
			(
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and agivc_bal_due <> 0
		 END	
			
	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT
			@customerCount = COUNT(DISTINCT strCustomerNumber)
			FROM ptivcmst
				INNER JOIN tblARCustomer ON ptivcmst.ptivc_sold_to COLLATE Latin1_General_CI_AS = tblARCustomer.strCustomerNumber COLLATE Latin1_General_CI_AS
			WHERE
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and ptivc_bal_due <> 0
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
		SET @Message = @key

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
			and agivc_bal_due <> 0
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
			and ptivc_bal_due <> 0
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
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and agivc_bal_due <> 0
		 END

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT 
			@originSalespersonCount = COUNT(DISTINCT ptivc_sold_by) 
			FROM ptivcmst 
			WHERE ptivc_sold_by IS NOT NULL
			AND 
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and ptivc_bal_due <> 0
		 END

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SELECT
			@salespersonCount = COUNT(DISTINCT strSalespersonId)
			FROM agivcmst
				INNER JOIN tblARSalesperson ON agivcmst.agivc_slsmn_no COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
			WHERE 
			(
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and agivc_bal_due <> 0
		 END
		 	
	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT
			@salespersonCount = COUNT(DISTINCT strSalespersonId)
			FROM ptivcmst
				INNER JOIN tblARSalesperson ON ptivcmst.ptivc_sold_by COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
			WHERE 
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and ptivc_bal_due <> 0
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
					(select strSalespersonId  COLLATE SQL_Latin1_General_CP1_CS_AS from tblARSalesperson where strSalespersonId is not null) 
			and agivc_bal_due <> 0
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
					(select strSalespersonId  COLLATE SQL_Latin1_General_CP1_CS_AS from tblARSalesperson where strSalespersonId is not null) 
			and ptivc_bal_due <> 0
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
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and agivc_bal_due <> 0

		 END
	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			SELECT 
			@originTermCount = COUNT(DISTINCT ptivc_terms_code) 
			FROM ptivcmst 
			WHERE ptivc_terms_code IS NOT NULL
			AND 
			(
				((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
			and ptivc_bal_due <> 0

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
					and agivc_bal_due <> 0
					AND 
						(
							((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
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
					and ptivc_bal_due <> 0
					AND 
						(
							((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
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
		SET @Message = @key
		
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
					and agivc_bal_due <> 0
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
					and ptivc_bal_due <> 0			
		 END
			
		RETURN;	
	END
	--==========================
	--	Company Location Setup
	--==========================		
	DECLARE @intARAccountId 			INT = NULL
		  , @intServiceChargeAccountId	INT = NULL
		  , @CompanyLocationNoAccount	VARCHAR(MAX) = NULL
		  , @strCompanyLocation 		NVARCHAR(200) = NULL
	SELECT TOP 1 @intARAccountId = intARAccountId
			   , @intServiceChargeAccountId = intServiceChargeAccountId
	FROM tblARCompanyPreference

	--Get Companylocation with NULL GL account for prepayment
	SELECT TOP 1 @CompanyLocationNoAccount = LOC.strLocationName
			FROM ptcrdmst CRD
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = ptcrd_cus_no COLLATE Latin1_General_CI_AS
			LEFT JOIN tblARInvoice Inv 
				ON LTRIM(RTRIM(CRD.ptcrd_invc_no))+'_'+CONVERT(CHAR(3),CRD.ptcrd_seq_no) COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
				AND Inv.[dtmDate] = CONVERT(DATE, CAST(CRD.ptcrd_rev_dt AS CHAR(12)), 112)
				AND ISNULL(Inv.[ysnImportedFromOrigin],0) = 1 AND ISNULL(Inv.[ysnImportedAsPosted],0) = 1 AND Inv.strTransactionType = 'Customer Prepayment'
			INNER JOIN tblSMCompanyLocation LOC ON strLocationNumber  COLLATE Latin1_General_CI_AS = CRD.ptcrd_loc_no COLLATE Latin1_General_CI_AS
			LEFT OUTER JOIN [tblSMPaymentMethod] PM	ON CRD.ptcrd_pay_type COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
			WHERE Inv.strInvoiceNumber IS NULL 
			AND Cus.ysnActive = 1 
			AND  CRD.ptcrd_type IN ( 'P','U') 
			AND ROUND(ISNULL((ptcrd_amt-ptcrd_amt_used), 0), [dbo].[fnARGetDefaultDecimal]()) <> 0 --[dblAmountDue] NOT EQUAL TO ZERO
			AND [dbo].[fnARGetInvoiceTypeAccount]('Customer Prepayment', LOC.intCompanyLocationId) IS NULL
    
	

	--AR ACCOUNT
	IF ISNULL(@intARAccountId, 0) <> 0
	BEGIN
		SET @Sucess = 1
	END
	ELSE
	BEGIN
		SET @Sucess = 0
		SET @Message = @key 

		INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT 'The AR Account in the Company Configuration was not set.'
				,'Company Configuration'
				,'The AR Account in the Company Configuration was not set.'
				,@UserId
				,@logDate
				,@key 


		RETURN;	
	END

	--SERVICE CHARGE ACCOUNT
	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
			SET @strCompanyLocation = 
			(SELECT TOP 1 CL.strLocationName
			FROM agivcmst
			LEFT JOIN tblARInvoice Inv ON agivcmst.agivc_ivc_no COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = agivc_bill_to_cus COLLATE Latin1_General_CI_AS
			INNER JOIN tblARSalesperson Salesperson ON strSalespersonId COLLATE Latin1_General_CI_AS = agivc_slsmn_no COLLATE Latin1_General_CI_AS
			INNER JOIN tblSMCompanyLocation CL ON agivcmst.agivc_loc_no COLLATE Latin1_General_CI_AS = CL.strLocationNumber  COLLATE Latin1_General_CI_AS
			WHERE Inv.strInvoiceNumber IS NULL AND agivcmst.agivc_ivc_no = UPPER(agivcmst.agivc_ivc_no) COLLATE Latin1_General_CS_AS
			AND (
					((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
				)
			AND (CL.intServiceCharges IS NULL OR CL.intServiceCharges = 0)
			and agivc_bal_due <> 0)
			
			IF(@strCompanyLocation IS NULL)
			BEGIN
				SET @Sucess = 1
			END
			IF(@strCompanyLocation IS NOT NULL)
			BEGIN
				SET @Sucess = 0
				SET @Message =@key 

				INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT 'The Service Charge Account of Company Location - ' + @strCompanyLocation + ' was not set.'
				,'Company Configuration'
				,'The Service Charge Account of Company Location - ' + @strCompanyLocation + ' was not set.'
				,@UserId
				,@logDate
				,@key 


				RETURN;	
			END

		 END

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
			IF(@intServiceChargeAccountId IS NOT NULL)
			BEGIN
				SET @Sucess = 1
			END
			IF(@intServiceChargeAccountId IS NULL)
			BEGIN
				SET @Sucess = 0
				
				SET @Message =@key 

				INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT 'The Service Charge Account in the Company Configuration was not set.'
				,'Company Configuration'
				,'The Service Charge Account in the Company Configuration was not set.'
				,@UserId
				,@logDate
				,@key 
				RETURN;	
			END


			IF(@CompanyLocationNoAccount IS  NULL)
			BEGIN
				SET @Sucess = 1
			END
			IF(@CompanyLocationNoAccount IS NOT NULL)
			BEGIN
				SET @Sucess = 0
				
				SET @Message =@key 

				DECLARE @ErrorMessage Varchar(Max) = 'Customer Prepayment General Ledger Account Missing in Company Location for ' + @CompanyLocationNoAccount + '.'
	
			INSERT INTO tblARImportInvoiceLog
			(
				[strData],
				[strDataType], 
				[strDescription], 
				[intEntityId], 
				[dtmDate],
				[strLogKey]
			)
			SELECT 'Customer Prepayment General Ledger Account Missing in Company Location. ' + @CompanyLocationNoAccount
				, 'Missing GL Account'
				,@ErrorMessage
				,@UserId
				,@logDate
				,@key 
				RETURN;	
			END

			


		 END

GO