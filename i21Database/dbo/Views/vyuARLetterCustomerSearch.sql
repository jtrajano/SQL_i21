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
FROM 
	[vyuARCollectionOverdueReport]
 