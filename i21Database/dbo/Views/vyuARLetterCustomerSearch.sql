CREATE VIEW vyuARLetterCustomerSearch
AS
SELECT  
	DISTINCT intEntityCustomerId	=	(CAST(intEntityCustomerId AS INT)) 
	, strCustomerNumber
	, strCustomerName 
	, dbl0DaysSum
	, dbl30DaysSum
	, dbl60DaysSum
	, dbl90DaysSum
	, dblTotalARSum
FROM 
	vyuARCollectionOverdueReport


 