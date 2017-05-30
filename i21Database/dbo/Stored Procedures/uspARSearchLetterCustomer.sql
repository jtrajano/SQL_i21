CREATE PROCEDURE [dbo].[uspARSearchLetterCustomer]
(
	@intLetterId INT
)
AS
DECLARE @strLetterName			NVARCHAR(MAX),
	    @intCompanyLocationId	INT,
		@strCompanyName			NVARCHAR(100),
		@strCompanyAddress		NVARCHAR(100),
		@strCompanyPhone		NVARCHAR(50)

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

SELECT 
	@strLetterName = strName 
FROM 
	tblSMLetter 
WHERE 
	intLetterId = CAST(@intLetterId AS NVARCHAR(10))
SET NOCOUNT OFF;

SET NOCOUNT ON;
SELECT TOP 1 
	@intCompanyLocationId	= intCompanySetupID,
	@strCompanyName			= strCompanyName,
	@strCompanyAddress		= [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL),
	@strCompanyPhone		= strPhone
FROM 
	tblSMCompanySetup WITH (NOLOCK)
SET NOCOUNT OFF;

DECLARE @temp_aging_table TABLE(
	 [strCustomerName]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[strCustomerNumber]		NVARCHAR(15)	COLLATE Latin1_General_CI_AS
	,[strInvoiceNumber]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[strRecordNumber]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[intInvoiceId]				INT	
	,[strBOLNumber]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[intEntityCustomerId]		INT				
	,[dblCreditLimit]			NUMERIC(18,6)
	,[dblTotalAR]				NUMERIC(18,6)
	,[dblFuture]				NUMERIC(18,6)
	,[dbl0Days]					NUMERIC(18,6)
	,[dbl10Days]				NUMERIC(18,6)
	,[dbl30Days]				NUMERIC(18,6)
	,[dbl60Days]				NUMERIC(18,6)
	,[dbl90Days]				NUMERIC(18,6)
	,[dbl120Days]				NUMERIC(18,6) 
	,[dbl121Days]				NUMERIC(18,6) 
	,[dblTotalDue]				NUMERIC(18,6)
	,[dblAmountPaid]			NUMERIC(18,6)
	,[dblInvoiceTotal]			NUMERIC(18,6)
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmDate]					DATETIME
	,[dtmDueDate]				DATETIME
	,[dtmAsOfDate]				DATETIME
	,[strSalespersonName]		NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[intCompanyLocationId]		INT
)

DECLARE @temp_availablecustomer_table TABLE(
	[intEntityCustomerId]		INT 
)

IF @strLetterName <> 'Service Charge Invoices Letter'
BEGIN
	INSERT INTO @temp_aging_table
	EXEC uspARCollectionOverdueDetailReport NULL, NULL  

	DELETE FROM @temp_aging_table
	WHERE [strInvoiceNumber] IN (SELECT [strInvoiceNumber] FROM tblARInvoice WITH (NOLOCK) WHERE strType IN ('CF Tran'))

	DELETE FROM tblARCollectionOverdueDetail
	INSERT INTO tblARCollectionOverdueDetail
	(
		intCompanyLocationId		 
		,strCompanyName				 
		,strCompanyAddress			 
		,strCompanyPhone			 
		,intEntityCustomerId		 
		,strCustomerNumber			 
		,strCustomerName			 
		,strCustomerAddress			 
		,strCustomerPhone			 
		,strAccountNumber			 
		,intInvoiceId				 
		,strInvoiceNumber			 
		,strBOLNumber				 
		,dblCreditLimit				 
		,intTermId					 
		,strTerm					 
		,dblTotalAR					 
		,dblFuture					 
		,dbl0Days					 
		,dbl10Days					 
		,dbl30Days					 
		,dbl60Days					 
		,dbl90Days					 
		,dbl120Days					 
		,dbl121Days					 
		,dblTotalDue				 
		,dblAmountPaid				 
		,dblInvoiceTotal			 		 
		,dblCredits					 	
		,dblPrepaids				 	
		,dtmDate					 
		,dtmDueDate					 
	)
	SELECT intCompanyLocationId		=	@intCompanyLocationId
		, strCompanyName			=	@strCompanyName
		, strCompanyAddress			=	@strCompanyAddress
		, strCompanyPhone			=	@strCompanyPhone
		, intEntityCustomerId		=	 Aging.intEntityCustomerId
		, strCustomerNumber			=	 Aging.strCustomerName
 		, strCustomerName			=	Cus.strName
		, strCustomerAddress		=	[dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, Cus.strBillToAddress, Cus.strBillToCity, Cus.strBillToState, Cus.strBillToZipCode, Cus.strBillToCountry, Cus.strName, NULL)
		, strCustomerPhone			=	EnPhoneNo.strPhone 
		, strAccountNumber			=	(SELECT strAccountNumber FROM tblARCustomer WITH (NOLOCK) WHERE intEntityCustomerId = Cus.intEntityCustomerId) 
		, intInvoiceId				=	Aging.intInvoiceId	
		, strInvoiceNumber			=	Aging.strInvoiceNumber		 
		, strBOLNumber				=	Aging.strBOLNumber
		, dblCreditLimit			=	Aging.dblCreditLimit				 
		, intTermId					=	Cus.intTermsId			 
		, strTerm					=	Cus.strTerm			 
		, dblTotalAR				=	Aging.dblTotalAR	 
		, dblFuture					=	Aging.dblFuture	 					 
		, dbl0Days					=	Aging.dbl0Days	 					 
		, dbl10Days					=	Aging.dbl10Days	 					 
		, dbl30Days					=	Aging.dbl30Days	 					 
		, dbl60Days					=	Aging.dbl60Days	 					 
		, dbl90Days					=	Aging.dbl90Days	 				 
		, dbl120Days				=	Aging.dbl120Days	 					 
		, dbl121Days				=	Aging.dbl121Days	 					 
		, dblTotalDue				=	Aging.dblTotalDue	 			 
		, dblAmountPaid				=	Aging.dblAmountPaid				 
		, dblInvoiceTotal			=	Aging.dblInvoiceTotal		 
		, dblCredits				=	Aging.dblCredits						 	
		, dblPrepaids				=	Aging.dblPrepaids					 	
		, dtmDate					=	Aging.dtmDate						 
		, dtmDueDate				=	Aging.dtmDueDate		 
	FROM 
		(
		SELECT 
			* 
		FROM 
			@temp_aging_table 
		WHERE 
			intInvoiceId NOT IN (SELECT 
									intInvoiceId 
								FROM 
									tblARInvoice WITH (NOLOCK)
								WHERE 
									strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') AND ysnPaid = 1) 
		)  Aging
	INNER JOIN (
				SELECT 
					ARC.intEntityCustomerId
					, strCustomerNumber					= ISNULL(ARC.strCustomerNumber, EME.strEntityNo)
					, EME.strName
					, BillToLoc.strBillToAddress
					, BillToLoc.strBillToCity
					, BillToLoc.strBillToCountry
					, BillToLoc.strBillToLocationName
					, BillToLoc.strBillToState
					, BillToLoc.strBillToZipCode
					, ARC.intTermsId
					, ARC.strTerm
				FROM 
					(SELECT 
						intEntityCustomerId, 
						strCustomerNumber, 
						intBillToId,		
						ARC.intTermsId,
						SMT.strTerm								
					FROM 
						tblARCustomer ARC WITH (NOLOCK)
					INNER JOIN (
								SELECT 
									intTermID,
									strTerm 
								FROM 
									tblSMTerm WITH (NOLOCK)) SMT ON ARC.intTermsId = SMT.intTermID ) ARC
					INNER JOIN (
								SELECT 
									intEntityId, 
									strEntityNo, 
									strName								 
								FROM 
									tblEMEntity WITH (NOLOCK)
								) EME ON ARC.intEntityCustomerId = EME.intEntityId
					LEFT JOIN (
								SELECT 
									Loc.intEntityId, 
									Loc.intEntityLocationId,
									Loc.intTermsId,
									SMT.strTerm																
								FROM 
									tblEMEntityLocation Loc WITH (NOLOCK)
								INNER JOIN (
											SELECT 
												intTermID,
												strTerm 
											FROM 
												tblSMTerm WITH (NOLOCK)) SMT ON Loc.intTermsId = SMT.intTermID
								WHERE ysnDefaultLocation = 1
								) EMEL ON ARC.intEntityCustomerId = EMEL.intEntityId
					LEFT JOIN (
								SELECT 
									intEntityId, 
									intEntityLocationId,
									strBillToAddress		= strAddress,
									strBillToCity			= strCity,
									strBillToLocationName	= strLocationName,
									strBillToCountry		= strCountry,
									strBillToState			= strState,
									strBillToZipCode		= strZipCode
								FROM 
									tblEMEntityLocation WITH (NOLOCK)
								) BillToLoc ON ARC.intEntityCustomerId = BillToLoc.intEntityId AND ARC.intBillToId = BillToLoc.intEntityLocationId
				) Cus ON Aging.intEntityCustomerId = Cus.intEntityCustomerId
	INNER JOIN (
				SELECT 
					intEntityId
						, [intEntityContactId]
						, ysnDefaultContact 
				FROM 
					[tblEMEntityToContact] WITH (NOLOCK)
				WHERE 
					ysnDefaultContact = 1) CusToCon ON Aging.intEntityCustomerId = CusToCon.intEntityId  
	 LEFT JOIN (
				SELECT 
					intEntityId
					, strPhone 
				FROM 
					tblEMEntityPhoneNumber WITH (NOLOCK)) EnPhoneNo ON CusToCon.[intEntityContactId] = EnPhoneNo.[intEntityId]
			
	DELETE FROM tblARCollectionOverdue				
	INSERT INTO tblARCollectionOverdue
	(
		intEntityCustomerId 				 
		,dblCreditLimitSum	  				 
		,dblTotalARSum 						 
		,dblFutureSum 				 
		,dbl0DaysSum 						 
		,dbl10DaysSum 					 
		,dbl30DaysSum  						 
		,dbl60DaysSum 					 
		,dbl90DaysSum 						 
		,dbl120DaysSum  						 
		,dbl121DaysSum 						 
		,dblTotalDueSum 				 
		,dblAmountPaidSum  					 
		,dblInvoiceTotalSum	 			 		 
		,dblCreditsSum 					 	
		,dblPrepaidsSum  	
	)
	SELECT 			 
		intEntityCustomerId 				 
		,dblCreditLimitSum		= SUM(dblCreditLimit) 				 
		,dblTotalARSum			= SUM(dblTotalAR) 						 
		,dblFutureSum			= SUM(dblFuture) 						 
		,dbl0DaysSum			= SUM(dbl0Days) 						 
		,dbl10DaysSum			= SUM(dbl10Days) 						 
		,dbl30DaysSum			= SUM(dbl30Days) 						 
		,dbl60DaysSum			= SUM(dbl60Days) 						 
		,dbl90DaysSum			= SUM(dbl90Days) 						 
		,dbl120DaysSum			= SUM(dbl120Days) 						 
		,dbl121DaysSum			= SUM(dbl121Days) 						 
		,dblTotalDueSum			= SUM(dblTotalDue) 					 
		,dblAmountPaidSum		= SUM(dblAmountPaid) 					 
		,dblInvoiceTotalSum		= SUM(dblInvoiceTotal) 				 		 
		,dblCreditsSum			= SUM(dblCredits) 						 	
		,dblPrepaidsSum			= SUM(dblPrepaids) 					 	
	FROM 
		@temp_aging_table
	GROUP BY 
		intEntityCustomerId
END
	
IF @strLetterName = 'Recent Overdue Collection Letter'
BEGIN

	INSERT INTO @temp_availablecustomer_table
	(
		intEntityCustomerId
	)
	SELECT 
		ARCO.intEntityCustomerId
	FROM 
		tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT 
					intEntityCustomerId
				FROM 
					(SELECT
						intEntityCustomerId
					FROM 
						(SELECT 
							intEntityId 
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
										ARC.intEntityCustomerId									 
									FROM 
										tblARCustomer ARC WITH (NOLOCK)
									INNER JOIN (SELECT 
													intEntityCustomerId
												FROM 
													tblARCollectionOverdue WITH (NOLOCK)) ARCO ON ARC.intEntityCustomerId = ARCO.intEntityCustomerId
									WHERE
										ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus
			) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl10DaysSum,0) <> 0 OR ISNULL(dbl30DaysSum,0) <> 0 OR ISNULL(dbl60DaysSum,0) <> 0 OR  ISNULL(dbl90DaysSum,0) <> 0 OR  ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)

	DELETE 
	FROM 
		tblARCollectionOverdueDetail 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	DELETE 
	FROM 
		tblARCollectionOverdue 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT 
		ARCO.intEntityCustomerId
		, strCustomerNumber
		, strCustomerName 		
	FROM 
		tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT 
					intEntityCustomerId
					, strCustomerNumber
					, strCustomerName 
				FROM 
					(SELECT
						intEntityCustomerId,
						strCustomerNumber		= ISNULL(ARC.strCustomerNumber, EME.strEntityNo),
						strCustomerName
					 FROM 
						(SELECT 
							intEntityId,
							strEntityNo,
							strCustomerName		= strName
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
										ARC.intEntityCustomerId
										, ARC.strCustomerNumber
									FROM 
										tblARCustomer ARC WITH (NOLOCK)
									INNER JOIN (SELECT 
													intEntityCustomerId 
												FROM 
													@temp_availablecustomer_table) TempCustomer ON ARC.intEntityCustomerId = TempCustomer.intEntityCustomerId
									 WHERE
										ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus
			) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl10DaysSum,0) <> 0 OR ISNULL(dbl30DaysSum,0) <> 0 OR ISNULL(dbl60DaysSum,0) <> 0 OR  ISNULL(dbl90DaysSum,0) <> 0 OR  ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)
	ORDER BY 
		strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF @strLetterName = '30 Day Overdue Collection Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	(
		intEntityCustomerId
	)
	SELECT 
		ARCO.intEntityCustomerId
	FROM 
		tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT 
					intEntityCustomerId
				FROM 
					(SELECT
						intEntityCustomerId
					 FROM 
						(SELECT 
							intEntityId
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
										ARC.intEntityCustomerId									 
									FROM 
										tblARCustomer ARC WITH (NOLOCK)
									INNER JOIN (SELECT 
													intEntityCustomerId
												FROM 
													tblARCollectionOverdue WITH (NOLOCK)) ARCO ON ARC.intEntityCustomerId = ARCO.intEntityCustomerId
									 WHERE
										ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus
			) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl60DaysSum,0) <> 0 OR  ISNULL(dbl90DaysSum,0) <> 0 OR  ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)

	DELETE 
	FROM 
		tblARCollectionOverdueDetail 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	DELETE 
	FROM 
		tblARCollectionOverdue 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT 
		ARCO.intEntityCustomerId
		, strCustomerNumber
		, strCustomerName 		
	FROM 
		tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT 
					intEntityCustomerId
					, strCustomerNumber
					, strCustomerName 
				FROM 
					(SELECT
						intEntityCustomerId,
						strCustomerNumber		= ISNULL(ARC.strCustomerNumber, EME.strEntityNo),
						strCustomerName
					 FROM 
						(SELECT 
							intEntityId,
							strEntityNo,
							strCustomerName		= strName
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
										ARC.intEntityCustomerId
										, ARC.strCustomerNumber
									FROM 
										tblARCustomer ARC WITH (NOLOCK)
									INNER JOIN (SELECT 
													intEntityCustomerId 
												FROM 
													@temp_availablecustomer_table) TempCustomer ON ARC.intEntityCustomerId = TempCustomer.intEntityCustomerId
									 WHERE
										ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus
			) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl60DaysSum,0) <> 0 OR  ISNULL(dbl90DaysSum,0) <> 0 OR  ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)
	ORDER BY 
		strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF @strLetterName = '60 Day Overdue Collection Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	(
		intEntityCustomerId
	)
	SELECT 
		ARCO.intEntityCustomerId
	FROM 
		tblARCollectionOverdue ARCO
	INNER JOIN (SELECT 
					intEntityCustomerId
				FROM 
					(SELECT
						intEntityCustomerId
					 FROM 
						(SELECT 
							intEntityId
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
										ARC.intEntityCustomerId									 
									FROM 
										tblARCustomer ARC WITH (NOLOCK)
									INNER JOIN (SELECT 
													intEntityCustomerId
												FROM 
													tblARCollectionOverdue WITH (NOLOCK)) ARCO ON ARC.intEntityCustomerId = ARCO.intEntityCustomerId
									 WHERE
										ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus
			) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl90DaysSum,0) <> 0 OR  ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)

	DELETE 
	FROM 
		tblARCollectionOverdueDetail 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	DELETE 
	FROM 
		tblARCollectionOverdue 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT 
		ARCO.intEntityCustomerId
		, strCustomerNumber
		, strCustomerName 
	FROM 
		tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT 
					intEntityCustomerId
					, strCustomerNumber
					, strCustomerName 
				FROM 
					(SELECT
						intEntityCustomerId,
						strCustomerNumber		= ISNULL(ARC.strCustomerNumber, EME.strEntityNo),
						strCustomerName
					 FROM 
						(SELECT 
							intEntityId,
							strEntityNo,
							strCustomerName		= strName
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
									ARC.intEntityCustomerId
										, ARC.strCustomerNumber
									FROM 
										tblARCustomer ARC WITH (NOLOCK)
									INNER JOIN (SELECT 
													intEntityCustomerId 
												FROM 
													@temp_availablecustomer_table) TempCustomer ON ARC.intEntityCustomerId = TempCustomer.intEntityCustomerId
									 WHERE
										ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus
			) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl90DaysSum,0) <> 0 OR  ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)
	ORDER BY 
		strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF @strLetterName = '90 Day Overdue Collection Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	(
		intEntityCustomerId
	)
	SELECT 
		ARCO.intEntityCustomerId
	FROM 
		tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT 
					intEntityCustomerId
				FROM 
					(SELECT
						intEntityCustomerId
					 FROM 
						(SELECT 
							intEntityId
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
										ARC.intEntityCustomerId									 
									FROM 
										tblARCustomer ARC WITH (NOLOCK)
									INNER JOIN (SELECT 
													intEntityCustomerId
												FROM 
													tblARCollectionOverdue WITH (NOLOCK)) ARCO ON ARC.intEntityCustomerId = ARCO.intEntityCustomerId
									 WHERE
										ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus
			  ) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)

	DELETE 
	FROM 
		tblARCollectionOverdueDetail 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	DELETE 
	FROM 
		tblARCollectionOverdue 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT 
		ARCO.intEntityCustomerId
		, strCustomerNumber
		, strCustomerName 
	FROM 
		tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT 
					intEntityCustomerId
					, strCustomerNumber
					, strCustomerName 
				FROM 
					(SELECT
						intEntityCustomerId,
						strCustomerNumber		= ISNULL(ARC.strCustomerNumber, EME.strEntityNo),
						strCustomerName
					 FROM 
						(SELECT 
							intEntityId,
							strEntityNo,
							strCustomerName		= strName
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
										ARC.intEntityCustomerId
										, ARC.strCustomerNumber
									FROM 
										tblARCustomer ARC WITH (NOLOCK)
									INNER JOIN (SELECT 
													intEntityCustomerId 
												FROM 
													@temp_availablecustomer_table) TempCustomer ON ARC.intEntityCustomerId = TempCustomer.intEntityCustomerId
									 WHERE
										ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus
			  ) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)
	ORDER BY 
		strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF @strLetterName = 'Final Overdue Collection Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	(
		intEntityCustomerId
	)
	SELECT 
		ARCO.intEntityCustomerId
	FROM 
		tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT 
					intEntityCustomerId
				FROM 
					(SELECT
						intEntityCustomerId
					 FROM 
						(SELECT 
							intEntityId
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
										ARC.intEntityCustomerId									 
									FROM 
										tblARCustomer ARC
									INNER JOIN (SELECT 
													intEntityCustomerId
												FROM 
													tblARCollectionOverdue WITH (NOLOCK)) ARCO ON ARC.intEntityCustomerId = ARCO.intEntityCustomerId
									 WHERE
										ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus						
				) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl121DaysSum,0) <> 0)

	DELETE 
	FROM 
		tblARCollectionOverdueDetail 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	DELETE 
	FROM 
		tblARCollectionOverdue 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT 
		ARCO.intEntityCustomerId
		, strCustomerNumber
		, strCustomerName 
	FROM 
		tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT 
					intEntityCustomerId
					, strCustomerNumber
					, strCustomerName 
				FROM 
					(SELECT
						intEntityCustomerId,
						strCustomerNumber		= ISNULL(ARC.strCustomerNumber, EME.strEntityNo),
						strCustomerName
					 FROM 
						(SELECT 
							intEntityId,
							strEntityNo,
							strCustomerName		= strName
						FROM 
							tblEMEntity WITH (NOLOCK)) EME
						INNER JOIN (SELECT 
										ARC.intEntityCustomerId
										, ARC.strCustomerNumber
									FROM 
										tblARCustomer ARC WITH (NOLOCK)
									INNER JOIN (SELECT 
													intEntityCustomerId 
												FROM 
													@temp_availablecustomer_table) TempCustomer ON ARC.intEntityCustomerId = TempCustomer.intEntityCustomerId
									 WHERE
										ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
					) Cus						
				) ARC ON ARCO.intEntityCustomerId = ARC.intEntityCustomerId
	WHERE 
		(ISNULL(dbl121DaysSum,0) <> 0)
	ORDER BY 
		strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF @strLetterName = 'Credit Suspension'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	(
		intEntityCustomerId
	)
	SELECT 
		intEntityCustomerId
	FROM 
		(SELECT
			intEntityCustomerId
		 FROM 
			(SELECT 
				intEntityId
			FROM 
				tblEMEntity WITH (NOLOCK)) EME
			INNER JOIN (SELECT 
							ARC.intEntityCustomerId									 
						FROM 
							tblARCustomer ARC WITH (NOLOCK)
			            WHERE
							dblCreditLimit = 0 AND ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
		) Cus

	DELETE 
	FROM 
		tblARCollectionOverdueDetail 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	DELETE 
	FROM 
		tblARCollectionOverdue 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT 
		intEntityCustomerId
		, strCustomerNumber
		, strCustomerName 
	FROM 
		(SELECT
			intEntityCustomerId,
			strCustomerNumber		= ISNULL(ARC.strCustomerNumber, EME.strEntityNo),
			strCustomerName
		 FROM 
			(SELECT 
				intEntityId,
				strEntityNo,
				strCustomerName		= strName
			FROM 
				tblEMEntity WITH (NOLOCK)) EME
			INNER JOIN (SELECT 
							ARC.intEntityCustomerId
							, ARC.strCustomerNumber
						FROM 
							tblARCustomer ARC WITH (NOLOCK)
						INNER JOIN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table) TempCustomer ON ARC.intEntityCustomerId = TempCustomer.intEntityCustomerId
						 WHERE
							ARC.dblCreditLimit = 0 AND ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
		) Cus
	ORDER BY 
		strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF @strLetterName = 'Expired Credit Card'  
BEGIN
	GetActiveCustomers:
	INSERT INTO @temp_availablecustomer_table
	(
		intEntityCustomerId
	)
	SELECT intEntityCustomerId
	FROM 
		(SELECT
			intEntityCustomerId
		 FROM 
			(SELECT 
				intEntityId
			FROM 
				tblEMEntity WITH (NOLOCK)) EME
			INNER JOIN (SELECT 
							ARC.intEntityCustomerId									 
						FROM 
							tblARCustomer ARC WITH (NOLOCK)
						 WHERE
							ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
		) Cus
			
	DELETE 
	FROM 
		tblARCollectionOverdueDetail 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	DELETE 
	FROM 
		tblARCollectionOverdue 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT intEntityCustomerId
		, strCustomerNumber
		, strCustomerName 
	FROM 
		(SELECT
			intEntityCustomerId,
			strCustomerNumber		= ISNULL(ARC.strCustomerNumber, EME.strEntityNo),
			strCustomerName
		 FROM 
			(SELECT 
				intEntityId,
				strEntityNo,
				strCustomerName		= strName
			FROM 
				tblEMEntity WITH (NOLOCK)) EME
			INNER JOIN (SELECT 
							ARC.intEntityCustomerId
							, ARC.strCustomerNumber
						FROM 
							tblARCustomer ARC WITH (NOLOCK)
						INNER JOIN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table) TempCustomer ON ARC.intEntityCustomerId = TempCustomer.intEntityCustomerId
						 WHERE
							ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
		) Cus		
	ORDER BY 
		strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF @strLetterName = 'Credit Review'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	(
		intEntityCustomerId
	)
	SELECT 
		intEntityCustomerId
	FROM 
		(SELECT
			intEntityCustomerId
		 FROM 
			(SELECT 
				intEntityId
			FROM 
				tblEMEntity WITH (NOLOCK)) EME
			INNER JOIN (SELECT 
							ARC.intEntityCustomerId									 
						FROM 
							tblARCustomer ARC WITH (NOLOCK)						 
						 WHERE
							ARC.dblCreditLimit > 0 AND ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
		) Cus	

	DELETE 
	FROM 
		tblARCollectionOverdueDetail 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	DELETE 
	FROM 
		tblARCollectionOverdue 
	WHERE 
		intEntityCustomerId NOT IN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT 
		intEntityCustomerId
		, strCustomerNumber				 
		, strCustomerName 
	FROM 
		(SELECT
			intEntityCustomerId,
			strCustomerNumber		= ISNULL(ARC.strCustomerNumber, EME.strEntityNo),
			strCustomerName
		 FROM 
			(SELECT 
				intEntityId,
				strEntityNo,
				strCustomerName		= strName
			FROM 
				tblEMEntity WITH (NOLOCK)) EME
			INNER JOIN (SELECT 
							ARC.intEntityCustomerId
							, ARC.strCustomerNumber
						FROM 
							tblARCustomer ARC WITH (NOLOCK)
						INNER JOIN (SELECT 
										intEntityCustomerId 
									FROM 
										@temp_availablecustomer_table) TempCustomer ON ARC.intEntityCustomerId = TempCustomer.intEntityCustomerId
						WHERE
						ARC.dblCreditLimit > 0 AND ARC.ysnActive = 1) ARC ON EME.intEntityId = ARC.intEntityCustomerId
		) Cus	
	ORDER BY 
		strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF  @strLetterName = 'Service Charge Invoices Letter'
BEGIN
	SET NOCOUNT ON;
	SELECT I.intEntityCustomerId
		 , CUST.strCustomerNumber
		 , CUST.strCustomerName
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN (SELECT intEntityCustomerId
					 , strCustomerNumber
					 , strCustomerName  = strName
				FROM dbo.vyuARCustomer WITH (NOLOCK)
				WHERE ysnActive = 1
	) CUST ON I.intEntityCustomerId = CUST.intEntityCustomerId	 
	WHERE I.strType = 'Service Charge'
	GROUP BY I.intEntityCustomerId
		   , CUST.strCustomerNumber
		   , CUST.strCustomerName
	ORDER BY CUST.strCustomerName
	SET NOCOUNT OFF;	
END

ELSE
BEGIN
	GOTO GetActiveCustomers
END