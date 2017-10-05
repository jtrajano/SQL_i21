CREATE VIEW vyuARLetterCustomerSearch
AS
SELECT  
	DISTINCT [intEntityCustomerId]	=	(CAST([intEntityCustomerId] AS INT)) 
	, [strCustomerNumber]
	, [strCustomerName]
	, [dbl0DaysSum]
	, [dbl10DaysSum]
	, [dbl30DaysSum]
	, [dbl60DaysSum]
	, [dbl90DaysSum]
	, [dbl120DaysSum]
	, [dbl121DaysSum]
	, [dblTotalARSum]
	, [dblCreditLimit]
	, ysnHasEmailSetup = CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
FROM 
	[vyuARCollectionOverdueReport] ARC
OUTER APPLY (
	SELECT intEmailSetupCount = COUNT(*) 
	FROM dbo.vyuARCustomerContacts WITH (NOLOCK)
	WHERE intCustomerEntityId = ARC.intEntityCustomerId 
	  AND ISNULL(strEmail, '') <> '' 
	  AND strEmailDistributionOption LIKE '%Letter%'
) EMAILSETUP
 