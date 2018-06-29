CREATE VIEW [dbo].[vyuCCCustomer]
WITH SCHEMABINDING
AS
	select
		intSiteId,
		intDealerSiteId,
		intCompanyOwnedSiteId,
		strSite,
		strSiteDescription,
		intPaymentMethodId,
		intCustomerId,
		intTermsId = (case when intTermsId is null then intEntityTermsId else intTermsId end),
		intSalespersonId,
		strCustomerEntityNo,
		strCustomerName
	from 
		(
			SELECT A.intSiteId,
				   A.intDealerSiteId,
				   A.intCompanyOwnedSiteId,
				   A.strSite,
				   A.strSiteDescription,
				   A.intPaymentMethodId,
				   A.intCustomerId,
				   D.intTermsId,
				   B.intSalespersonId,
				   C.strEntityNo AS strCustomerEntityNo,
				   C.strName AS strCustomerName,
				   B.intTermsId AS intEntityTermsId
			FROM dbo.tblCCSite AS A
				INNER JOIN dbo.tblARCustomer AS B
					ON B.[intEntityId] = A.intCustomerId
				INNER JOIN dbo.tblEMEntity AS C
					ON C.intEntityId = B.[intEntityId]
				LEFT OUTER JOIN dbo.[tblEMEntityLocation] AS D
					ON D.intEntityId = B.[intEntityId] AND D.ysnDefaultLocation = 1
		)as result 
/*
SELECT A.intSiteId,
       A.intDealerSiteId,
       A.intCompanyOwnedSiteId,
       A.strSite,
       A.strSiteDescription,
       A.intPaymentMethodId,
       A.intCustomerId,
       D.intTermsId,
       B.intSalespersonId,
	   C.strEntityNo AS strCustomerEntityNo,
	   C.strName AS strCustomerName
FROM dbo.tblCCSite AS A
	INNER JOIN dbo.tblARCustomer AS B
		ON B.[intEntityId] = A.intCustomerId
	INNER JOIN dbo.tblEMEntity AS C
		ON C.intEntityId = B.[intEntityId]
	LEFT OUTER JOIN dbo.[tblEMEntityLocation] AS D
		ON D.intEntityLocationId = B.[intEntityId] AND D.ysnDefaultLocation = 1
		*/
