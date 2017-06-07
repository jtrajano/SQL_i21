
CREATE VIEW [dbo].[vyuCCSite]
WITH SCHEMABINDING
	AS 
SELECT 
	C.intSiteId, 
	A.intVendorDefaultId,
	C.intCustomerId,
	C.strSite,
	C.strSiteDescription,
	D.strPaymentMethod,
	H.strName as strCustomerName,
	J.strEmail,
    case when B.ysnPassedThruArCustomer is null then 'Company Owned' 
	     when B.ysnPassedThruArCustomer = 1 then 'Company Owned Pass Thru' else 'Company Owned' 		 
		 end strSiteType,
	 convert(bit,0)  as ysnPostNetToArCustomer,
	 0  as dblSharedFeePercentage,
	 C.intCompanyOwnedSiteId,
	 C.intDealerSiteId,
	 null as intAccountId,
 	 B.intCreditCardReceivableAccountId,
	 B.intFeeExpenseAccountId
FROM
     dbo.tblCCVendorDefault A
	JOIN dbo.tblCCCompanyOwnedSite B
		ON A.intVendorDefaultId = B.intVendorDefaultId
	JOIN dbo.tblCCSite C
		ON B.intCompanyOwnedSiteId = C.intCompanyOwnedSiteId
	LEFT JOIN dbo.tblSMPaymentMethod D
	    ON D.intPaymentMethodID = C.intPaymentMethodId
    LEFT JOIN dbo.tblARCustomer F
	    ON F.[intEntityId] = C.intCustomerId
	LEFT JOIN dbo.tblEMEntity H
	    ON H.intEntityId = F.[intEntityId]
	INNER JOIN dbo.tblEMEntityToContact I 
		ON I.intEntityId = H.intEntityId AND I.ysnDefaultContact = 1
	INNER JOIN dbo.tblEMEntity J 
		ON J.intEntityId = I.intEntityContactId
UNION ALL
SELECT
    C.intSiteId, 
	A.intVendorDefaultId,
	C.intCustomerId,
	C.strSite,
	C.strSiteDescription,
	D.strPaymentMethod,
	H.strName as strCustomerName,
	J.strEmail,
    case when E.ysnSharedFee is null then 'Dealer Site' 
	     when E.ysnSharedFee = 1 then 'Dealer Site Shared Fees' else 'Dealer Site' 		 
		 end strSiteType,
	E.ysnPostNetToArCustomer,
	E.dblSharedFeePercentage,
	C.intCompanyOwnedSiteId,
	C.intDealerSiteId,
	E.intAccountId,
	null as intCreditCardReceivableAccountId,
	null as intFeeExpenseAccountId
FROM  
	 dbo.tblCCVendorDefault A
	JOIN dbo.tblCCDealerSite E
		ON A.intVendorDefaultId = E.intVendorDefaultId
	JOIN dbo.tblCCSite C
		ON E.intDealerSiteId = C.intDealerSiteId
    LEFT JOIN dbo.tblSMPaymentMethod D
	    ON D.intPaymentMethodID = C.intPaymentMethodId
    LEFT JOIN dbo.tblARCustomer F
	    ON F.[intEntityId] = C.intCustomerId
	LEFT JOIN dbo.tblEMEntity H
	    ON H.intEntityId = F.[intEntityId]
	INNER JOIN dbo.tblEMEntityToContact I 
		ON I.intEntityId = H.intEntityId AND I.ysnDefaultContact = 1
	INNER JOIN dbo.tblEMEntity J 
		ON J.intEntityId = I.intEntityContactId

