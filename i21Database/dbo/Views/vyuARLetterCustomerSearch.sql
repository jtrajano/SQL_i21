CREATE VIEW vyuARLetterCustomerSearch
AS
SELECT  
	DISTINCT intEntityCustomerId	=	(CAST(intEntityCustomerId AS INT)) 
	, strCustomerNumber
	, strCustomerName 

FROM 
	vyuARCollectionOverdueReport


 