CREATE PROCEDURE [dbo].[uspARSearchLetterCustomer]
(
	  @intLetterId		INT
	, @intEntityUserId	INT
)
AS
DECLARE @strLetterName			NVARCHAR(MAX),
		@ysnSystemDefined		BIT

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

SELECT @strLetterName		= strName
	 , @ysnSystemDefined	= ysnSystemDefined 
FROM dbo.tblSMLetter WITH (NOLOCK)
WHERE intLetterId = CAST(@intLetterId AS NVARCHAR(10))
SET NOCOUNT OFF;

DECLARE @temp_availablecustomer_table TABLE(
	 [intEntityCustomerId]		INT
	,[strCustomerName]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS
	,[strCustomerNumber]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
)

DECLARE @temp_return_table TABLE(
	 [intEntityCustomerId]		INT
	,[strCustomerName]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS
	,[strCustomerNumber]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	,[ysnHasEmailSetup]			BIT
)

IF @strLetterName NOT IN ('Credit Suspension', 'Expired Credit Card', 'Credit Review', 'Service Charge Invoices Letter') AND ISNULL(@ysnSystemDefined, 1) = 1
	BEGIN		
		DECLARE @strCustomerIds NVARCHAR(MAX) = NULL
			  , @dtmAsOfDate    DATETIME = GETDATE()

        SELECT @strCustomerIds = LEFT(intEntityId, LEN(intEntityId) - 1)
        FROM (
            SELECT DISTINCT CAST(intEntityId AS VARCHAR(200))  + ', '
            FROM tblARCustomer WITH(NOLOCK)
            WHERE ISNULL(dblARBalance, 0) <> 0
              AND ysnActive = 1
            FOR XML PATH ('')
        ) C (intEntityId)
		
        EXEC dbo.uspARCustomerAgingDetailAsOfDateReport @dtmDateTo = @dtmAsOfDate													  
                                                      , @ysnInclude120Days = 1
                                                      , @strCustomerIds = @strCustomerIds
                                                      , @intEntityUserId = @intEntityUserId
													  , @ysnPaidInvoice = 0

		DELETE AGING
		FROM tblARCustomerAgingStagingTable AGING
		INNER JOIN (
			SELECT intInvoiceId 
			FROM tblARCustomerAgingStagingTable 
			WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
			GROUP BY intInvoiceId 
			HAVING SUM(ISNULL(dblTotalAR, 0)) = 0
		) ENTITY ON AGING.intInvoiceId = ENTITY.intInvoiceId
		WHERE AGING.intEntityUserId = @intEntityUserId
		  AND AGING.strAgingType = 'Detail'
			
		DELETE FROM tblARCollectionOverdue WHERE intEntityUserId = @intEntityUserId
		INSERT INTO tblARCollectionOverdue
		(
			intEntityCustomerId
			,intEntityUserId
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
			intEntityCustomerId		= intEntityCustomerId 				 
			,intEntityUserId		= @intEntityUserId
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
		FROM tblARCustomerAgingStagingTable
		WHERE intEntityUserId = @intEntityUserId AND strAgingType = 'Detail'
		GROUP BY intEntityCustomerId
	END
	
IF @strLetterName = 'Recent Overdue Collection Letter'
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT ARCO.intEntityCustomerId
			 , ENTITY.strName
			 , ENTITY.strCustomerNumber
		FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
		INNER JOIN (SELECT intEntityId 
						 , strName
						 , strCustomerNumber
					FROM dbo.vyuARCustomer WITH (NOLOCK) 
					WHERE ysnActive = 1
		) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
		WHERE (ISNULL(dbl10DaysSum,0) <> 0 OR ISNULL(dbl30DaysSum,0) <> 0)
		  AND ARCO.intEntityUserId = @intEntityUserId		
	END
ELSE IF @strLetterName = '30 Day Overdue Collection Letter'
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT ARCO.intEntityCustomerId
			 , ENTITY.strName
			 , ENTITY.strCustomerNumber
		FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
		INNER JOIN (SELECT intEntityId 
						 , strName
						 , strCustomerNumber
					FROM dbo.vyuARCustomer WITH (NOLOCK) 
					WHERE ysnActive = 1
		) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
		WHERE (ISNULL(dbl60DaysSum,0) <> 0 OR ISNULL(dbl90DaysSum,0) <> 0 OR ISNULL(dbl120DaysSum,0) <> 0 OR ISNULL(dbl121DaysSum,0) <> 0)
		  AND ARCO.intEntityUserId = @intEntityUserId		
	END
ELSE IF @strLetterName = '60 Day Overdue Collection Letter'
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT ARCO.intEntityCustomerId
			 , ENTITY.strName
			 , ENTITY.strCustomerNumber
		FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
		INNER JOIN (SELECT intEntityId 
						 , strName
						 , strCustomerNumber
					FROM dbo.vyuARCustomer WITH (NOLOCK) 
					WHERE ysnActive = 1
		) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
		WHERE (ISNULL(dbl90DaysSum,0) <> 0 OR ISNULL(dbl120DaysSum,0) <> 0 OR ISNULL(dbl121DaysSum,0) <> 0)
		  AND ARCO.intEntityUserId = @intEntityUserId		
	END
ELSE IF @strLetterName = '90 Day Overdue Collection Letter'
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT ARCO.intEntityCustomerId
			 , ENTITY.strName
			 , ENTITY.strCustomerNumber
		FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
		INNER JOIN (SELECT intEntityId 
						 , strName
						 , strCustomerNumber
					FROM dbo.vyuARCustomer WITH (NOLOCK) 
					WHERE ysnActive = 1
		) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
		WHERE (ISNULL(dbl120DaysSum,0) <> 0 OR ISNULL(dbl121DaysSum,0) <> 0)
		  AND ARCO.intEntityUserId = @intEntityUserId		
	END
ELSE IF @strLetterName = 'Final Overdue Collection Letter'
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT ARCO.intEntityCustomerId
			 , ENTITY.strName
			 , ENTITY.strCustomerNumber
		FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
		INNER JOIN (SELECT intEntityId 
						 , strName
						 , strCustomerNumber
					FROM dbo.vyuARCustomer WITH (NOLOCK) 
					WHERE ysnActive = 1
		) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
		WHERE (ISNULL(dbl121DaysSum,0) <> 0)
		  AND ARCO.intEntityUserId = @intEntityUserId		
	END
ELSE IF @strLetterName = 'Credit Suspension'
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT intEntityId
			 , strName
			 , strCustomerNumber
		FROM dbo.vyuARCustomer WITH (NOLOCK) 
		WHERE ysnActive = 1
		  AND dblCreditLimit = 0
	END
ELSE IF @strLetterName = 'Expired Credit Card'  
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT intEntityId
			 , strName
			 , strCustomerNumber
		FROM dbo.vyuARCustomer WITH (NOLOCK) 
		WHERE ysnActive = 1
		  AND dblCreditLimit = 0
	END
ELSE IF @strLetterName = 'Credit Review'
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT intEntityId
			 , strName
			 , strCustomerNumber
		FROM dbo.vyuARCustomer WITH (NOLOCK) 
		WHERE ysnActive = 1
		  AND dblCreditLimit > 0
	END
ELSE IF @strLetterName = 'Service Charge Invoices Letter'
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT DISTINCT 
			   intEntityCustomerId
			 , strCustomerName
			 , strCustomerNumber
		FROM vyuARServiceChargeInvoiceReport	
	END
ELSE
	BEGIN
		INSERT INTO @temp_availablecustomer_table
		SELECT intEntityId
			 , strName
			 , strCustomerNumber
		FROM dbo.vyuARCustomer WITH (NOLOCK) 
		WHERE ysnActive = 1
	END

IF ISNULL(@strLetterName, '') <> ''
	BEGIN
		INSERT INTO @temp_return_table
		SELECT intEntityCustomerId
			 , strCustomerName
			 , strCustomerNumber
			 , CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
		FROM @temp_availablecustomer_table C
		OUTER APPLY (
			SELECT intEmailSetupCount = COUNT(*) 
			FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
			WHERE CC.intCustomerEntityId = C.intEntityCustomerId 
			  AND ISNULL(CC.strEmail, '') <> '' 
			  AND CC.strEmailDistributionOption LIKE '%Letter%'
		) EMAILSETUP

		IF @strLetterName NOT IN ('Credit Suspension', 'Expired Credit Card', 'Credit Review', 'Service Charge Invoices Letter')
			DELETE FROM dbo.tblARCollectionOverdue WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_return_table) AND intEntityUserId = @intEntityUserId
			
		SET NOCOUNT ON;
		SELECT * FROM @temp_return_table ORDER BY strCustomerName
		SET NOCOUNT OFF;
	END
