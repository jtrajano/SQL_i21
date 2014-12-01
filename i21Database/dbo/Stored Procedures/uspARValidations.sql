CREATE PROCEDURE [dbo].[uspARValidations]
	@Sucess BIT = 0 OUTPUT,
	@Message NVARCHAR(100) = '' OUTPUT

	AS

	--==========================
	--	CUSTOMER
	--==========================
	DECLARE @customerCount INT
	DECLARE @originCustomerCount INT

	SELECT
	@originCustomerCount = COUNT(DISTINCT agivc_bill_to_cus)
	FROM
	agivcmst
	
	SELECT
	@customerCount = COUNT(DISTINCT strCustomerNumber)
	FROM agivcmst
		INNER JOIN tblARCustomer ON agivcmst.agivc_bill_to_cus COLLATE Latin1_General_CI_AS = tblARCustomer.strCustomerNumber COLLATE Latin1_General_CI_AS

			
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
	
	SELECT
	@salespersonCount = COUNT(DISTINCT strSalespersonId)
	FROM agivcmst
		INNER JOIN tblARSalesperson ON agivcmst.agivc_slsmn_no COLLATE Latin1_General_CI_AS = tblARSalesperson.strSalespersonId COLLATE Latin1_General_CI_AS
	
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
 
	SELECT
	@termCount = COUNT(DISTINCT strTerm)
	FROM tblSMTerm
	WHERE strTermCode COLLATE Latin1_General_CI_AS in (SELECT 
			DISTINCT (CASE WHEN SUBSTRING(agivc_terms_code,1, 1) = 0 THEN SUBSTRING(agivc_terms_code,2,1) ELSE agivc_terms_code END) COLLATE Latin1_General_CI_AS
			FROM agivcmst 
			WHERE agivc_terms_code IS NOT NULL)

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