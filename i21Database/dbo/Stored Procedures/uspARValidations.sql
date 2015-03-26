CREATE PROCEDURE [dbo].[uspARValidations]
	@Sucess BIT = 0 OUTPUT,
	@Message NVARCHAR(100) = '' OUTPUT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL

	AS

	--==========================
	--	CUSTOMER
	--==========================
	DECLARE @customerCount INT
	DECLARE @originCustomerCount INT
	
	IF (@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0)
	BEGIN
		SET @StartDate = NULL
		SET @EndDate = NULL
	END	

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
		RETURN;
	END
	
	--==========================
	--	SALESPERSON
	--==========================	
	DECLARE @salespersonCount INT
	DECLARE @originSalespersonCount INT
	
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
	
	IF(@originSalespersonCount = @salespersonCount)
	BEGIN
		SET @Sucess = 1
	END
	IF(@originSalespersonCount <> @salespersonCount)
	BEGIN
		SET @Sucess = 0
		SET @Message = 'There is a discrepancy on Salesperson records.'
		RETURN;	
	END
		
	--==========================
	--	TERM
	--==========================	
	DECLARE @termCount INT
	DECLARE @originTermCount INT
	
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

	IF(@originTermCount = @termCount)
	BEGIN
		SET @Sucess = 1
	END
	IF(@originTermCount <> @termCount)
	BEGIN
		SET @Sucess = 0
		SET @Message = 'There is a discrepancy on Term records.'
		RETURN;	
	END


	--==========================
	--	Company Location Setup
	--==========================		
	DECLARE @CompanyLocation VARCHAR(250)
	--AR Account
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
	AND (CL.intARAccount IS NULL OR CL.intARAccount = 0))

	IF(@CompanyLocation IS NULL)
	BEGIN
		SET @Sucess = 1
	END
	IF(@CompanyLocation IS NOT NULL)
	BEGIN
		SET @Sucess = 0
		SET @Message = 'The AR Account of Company Location - ' + @CompanyLocation + 'was not set.'
		RETURN;	
	END

	--Service Charge Account
	SET @CompanyLocation = NULL
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
		SET @Message = 'The Service Charge Account of Company Location - ' + @CompanyLocation + 'was not set.'
		RETURN;	
	END