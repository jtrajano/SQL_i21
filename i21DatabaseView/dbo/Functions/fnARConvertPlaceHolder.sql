CREATE FUNCTION [dbo].[fnARConvertPlaceHolder]
(
	  @blbMessage			VARBINARY(MAX)	= NULL
	, @intTransactionId		INT				= NULL
	, @strTransactionType	NVARCHAR(100)	= NULL
)
RETURNS VARBINARY(MAX) AS 
BEGIN
	DECLARE @blbConvertedMessage	VARBINARY(MAX)	= NULL
		  , @strTempMessage			VARCHAR(MAX)	= NULL
		  , @strCustomerName		NVARCHAR(100)	= ''
		  , @strCustomerAddress		NVARCHAR(200)	= ''
		  , @strCustomerPhone		NVARCHAR(100)	= ''
		  , @strCustomerAccount		NVARCHAR(100)	= ''
		  , @dblCustomerAccount		NVARCHAR(100)	= CONVERT(NVARCHAR(100), 0.00)
		  ,	@dtmDate				NVARCHAR(100)	= CONVERT(NVARCHAR(100), GETDATE(), 110)
		  , @dtmExpirationDate		NVARCHAR(100)	= CONVERT(NVARCHAR(100), GETDATE(), 110)
		  , @dtmTransactionDate		NVARCHAR(100)	= CONVERT(NVARCHAR(100), GETDATE(), 110)
		  , @strTransactionNumber	NVARCHAR(100)	= ''
		  , @dblTransactionAmount	NVARCHAR(100)	= CONVERT(NVARCHAR(100), 0.00)
		  , @dblTransactionTotal	NVARCHAR(100)	= CONVERT(NVARCHAR(100), 0.00)
		  , @dblCustomerTotalAR		NVARCHAR(100)	= CONVERT(NVARCHAR(100), 0.00)
		  , @strTerm				NVARCHAR(100)	= ''
		  , @strContactName			NVARCHAR(100)	= ''
		  , @strCurrentUser			NVARCHAR(100)	= ''
		  , @strCompanyName			NVARCHAR(100)	= ''
		  , @strCreatedByName		NVARCHAR(100)	= ''
		  , @strCreatedByPhone		NVARCHAR(100)	= ''
		  , @strCreatedByEmail		NVARCHAR(200)	= ''

	SET @strTempMessage = CAST(@blbMessage AS VARCHAR(MAX))
	
	IF ISNULL(@strTransactionType, '') <> '' AND ISNULL(@intTransactionId, 0) > 0
		BEGIN
			IF @strTransactionType IN ('Sales Order', 'Quote')
				BEGIN
					SELECT TOP 1 @strCustomerName		= CUSTOMER.strName
							   , @strCustomerAddress	= CUSTOMER.strAddress
							   , @strCustomerPhone		= CUSTOMER.strPhone
							   , @strCustomerAccount	= CUSTOMER.strAccountNumber
							   , @dblCustomerAccount	= CONVERT(NVARCHAR(100), ISNULL(CUSTOMER.dblARBalance, 0.00))
							   , @dtmDate				= CONVERT(NVARCHAR(100), ISNULL(SO.dtmDate, GETDATE()), 110)
							   , @dtmExpirationDate		= CONVERT(NVARCHAR(100), ISNULL(SO.dtmExpirationDate, GETDATE()), 110)
							   , @dtmTransactionDate	= CONVERT(NVARCHAR(100), ISNULL(SO.dtmDate, GETDATE()), 110)
							   , @strTransactionNumber	= SO.strSalesOrderNumber
							   , @dblTransactionAmount	= CONVERT(NVARCHAR(100), ISNULL(SO.dblSalesOrderTotal, 0.00))
							   , @dblTransactionTotal	= CONVERT(NVARCHAR(100), ISNULL(SO.dblSalesOrderTotal, 0.00))
							   , @dblCustomerTotalAR	= CONVERT(NVARCHAR(100), ISNULL(CUSTOMER.dblARBalance, 0.00))	
							   , @strTerm				= TERM.strTerm
							   , @strContactName		= CONTACT.strName
							   , @strCompanyName		= COMPANY.strCompanyName
							   , @strCreatedByName		= CREATEDBY.strName
							   , @strCreatedByPhone		= CREATEDBY.strPhone
							   , @strCreatedByEmail		= CREATEDBY.strEmail
					FROM dbo.tblSOSalesOrder SO WITH (NOLOCK)
					LEFT JOIN (
						SELECT intEntityCustomerId
							 , strName
							 , strAddress
							 , strPhone
							 , strAccountNumber
							 , dblARBalance
						FROM dbo.vyuARCustomerSearch
					) CUSTOMER ON SO.intEntityCustomerId = CUSTOMER.intEntityCustomerId
					LEFT JOIN (
						SELECT intEntityId
							 , strName
						FROM dbo.tblEMEntity
					) CONTACT ON SO.intEntityContactId = CONTACT.intEntityId
					INNER JOIN (
						SELECT intEntityId
							 , strName
							 , strPhone = ISNULL(strPhone, strPhone2)
							 , strEmail	= ISNULL(strEmail, strEmail2)
						FROM dbo.tblEMEntity WITH (NOLOCK)
					) CREATEDBY ON SO.intEntityId = CREATEDBY.intEntityId
					INNER JOIN (
						SELECT intTermID
							 , strTerm
						FROM dbo.tblSMTerm WITH (NOLOCK)
					) TERM ON SO.intTermId = TERM.intTermID
					OUTER APPLY (
						SELECT TOP 1 strCompanyName
						FROM dbo.tblSMCompanySetup WITH (NOLOCK)
					) COMPANY
					WHERE intSalesOrderId = @intTransactionId
				END
			ELSE IF @strTransactionType IN ('Invoice', 'Credit Memo', 'Customer Prepayment')
				BEGIN
					SELECT TOP 1 @strCustomerName		= CUSTOMER.strName
							   , @strCustomerAddress	= CUSTOMER.strAddress
							   , @strCustomerPhone		= CUSTOMER.strPhone
							   , @strCustomerAccount	= CUSTOMER.strAccountNumber
							   , @dblCustomerAccount	= CONVERT(NVARCHAR(100), ISNULL(CUSTOMER.dblARBalance, 0.00))
							   , @dtmDate				= CONVERT(NVARCHAR(100), ISNULL(INV.dtmDate, GETDATE()), 110)
							   , @dtmTransactionDate	= CONVERT(NVARCHAR(100), ISNULL(INV.dtmDate, GETDATE()), 110)
							   , @strTransactionNumber	= INV.strInvoiceNumber
							   , @dblTransactionAmount	= CONVERT(NVARCHAR(100), ISNULL(INV.dblInvoiceTotal, 0.00))
							   , @dblTransactionTotal	= CONVERT(NVARCHAR(100), ISNULL(INV.dblInvoiceTotal, 0.00))
							   , @dblCustomerTotalAR	= CONVERT(NVARCHAR(100), ISNULL(CUSTOMER.dblARBalance, 0.00))	
							   , @strTerm				= TERM.strTerm
							   , @strContactName		= CONTACT.strName
							   , @strCompanyName		= COMPANY.strCompanyName
							   , @strCreatedByName		= CREATEDBY.strName
							   , @strCreatedByPhone		= CREATEDBY.strPhone
							   , @strCreatedByEmail		= CREATEDBY.strEmail
					FROM dbo.tblARInvoice INV WITH (NOLOCK)
					LEFT JOIN (
						SELECT intEntityCustomerId
							 , strName
							 , strAddress
							 , strPhone
							 , strAccountNumber
							 , dblARBalance
						FROM dbo.vyuARCustomerSearch
					) CUSTOMER ON INV.intEntityCustomerId = CUSTOMER.intEntityCustomerId
					LEFT JOIN (
						SELECT intEntityId
							 , strName
						FROM dbo.tblEMEntity
					) CONTACT ON INV.intEntityContactId = CONTACT.intEntityId
					INNER JOIN (
						SELECT intEntityId
							 , strName
							 , strPhone = ISNULL(strPhone, strPhone2)
							 , strEmail	= ISNULL(strEmail, strEmail2)
						FROM dbo.tblEMEntity WITH (NOLOCK)
					) CREATEDBY ON INV.intEntityId = CREATEDBY.intEntityId
					INNER JOIN (
						SELECT intTermID
							 , strTerm
						FROM dbo.tblSMTerm WITH (NOLOCK)
					) TERM ON INV.intTermId = TERM.intTermID
					OUTER APPLY (
						SELECT TOP 1 strCompanyName
						FROM dbo.tblSMCompanySetup WITH (NOLOCK)
					) COMPANY					
					WHERE intInvoiceId = @intTransactionId
				END
		END

	SET @strTempMessage = REPLACE(@strTempMessage, '[EntityName]', @strCustomerName)
	SET @strTempMessage = REPLACE(@strTempMessage, '[EntityAddress]', @strCustomerAddress)
	SET @strTempMessage = REPLACE(@strTempMessage, '[EntityPhoneNumber]', @strCustomerPhone)
	SET @strTempMessage = REPLACE(@strTempMessage, '[AccountNumber]', @strCustomerAccount)
	SET @strTempMessage = REPLACE(@strTempMessage, '[AccountBalance]', @dblCustomerAccount)
	SET @strTempMessage = REPLACE(@strTempMessage, '[Date]', @dtmDate)
	SET @strTempMessage = REPLACE(@strTempMessage, '[ExpirationDate]', @dtmExpirationDate)	
	SET @strTempMessage = REPLACE(@strTempMessage, '[TransactionDate]', @dtmTransactionDate)
	SET @strTempMessage = REPLACE(@strTempMessage, '[TransactionNumber]', @strTransactionNumber)
	SET @strTempMessage = REPLACE(@strTempMessage, '[TransactionAmount]', @dblTransactionAmount)
	SET @strTempMessage = REPLACE(@strTempMessage, '[TransactionTotal]', @dblTransactionTotal)
	SET @strTempMessage = REPLACE(@strTempMessage, '[EntityTotal]', @dblCustomerTotalAR)
	SET @strTempMessage = REPLACE(@strTempMessage, '[Term]', @strTerm)
	SET @strTempMessage = REPLACE(@strTempMessage, '[CompanyName]', @strCompanyName)
	SET @strTempMessage = REPLACE(@strTempMessage, '[ContactName]', @strContactName)
	SET @strTempMessage = REPLACE(@strTempMessage, '[CurrentUser]', @strCurrentUser)
	SET @strTempMessage = REPLACE(@strTempMessage, '[CreatedByName]', @strCreatedByName)
	SET @strTempMessage = REPLACE(@strTempMessage, '[CreatedByPhone]', @strCreatedByPhone)
	SET @strTempMessage = REPLACE(@strTempMessage, '[CreatedByEmail]', @strCreatedByEmail)

	SET @blbConvertedMessage = CAST(@strTempMessage AS VARBINARY(MAX))

	RETURN @blbConvertedMessage
END
GO