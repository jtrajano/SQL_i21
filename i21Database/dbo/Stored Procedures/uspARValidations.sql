CREATE PROCEDURE uspARValidations
	@Sucess BIT = 0 OUTPUT,
	@Message NVARCHAR(100) = '' OUTPUT

	AS

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
		
		
	DECLARE @termCount INT
	DECLARE @originTermCount INT
	
	SELECT 
	@originTermCount = COUNT(DISTINCT agivc_terms_code) 
	FROM agivcmst 
	WHERE agivc_terms_code IS NOT NULL
	
	SELECT
	@termCount = COUNT(DISTINCT strTerm)
	FROM agivcmst
		INNER JOIN tblSMTerm ON agivcmst.agivc_bill_to_cus COLLATE Latin1_General_CI_AS = tblSMTerm.strTerm COLLATE Latin1_General_CI_AS
	
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
		