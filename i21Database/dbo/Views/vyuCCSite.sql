
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
		case when C.ysnPassedThruArCustomer is null then 'Company Owned' 
			 when C.ysnPassedThruArCustomer = 1 then 'Company Owned Pass Thru' else 'Company Owned' 		 
			 end strSiteType,
		 convert(bit,0)  as ysnPostNetToArCustomer,
		 0  as dblSharedFeePercentage,
		 C.intCompanyOwnedSiteId,
		 C.intDealerSiteId,
		 null as intAccountId,
 		 intCreditCardReceivableAccountId = C.intAccountId,
		 C.intFeeExpenseAccountId
	FROM
		 dbo.tblCCVendorDefault A
		JOIN dbo.tblCCSite C
			ON A.intVendorDefaultId = C.intVendorDefaultId and C.strType = 'COMPANY OWNED'
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
		case when C.ysnSharedFee is null then 'Dealer Site' 
			 when C.ysnSharedFee = 1 then 'Dealer Site Shared Fees' else 'Dealer Site' 		 
			 end strSiteType,
		C.ysnPostNetToArCustomer,
		C.dblSharedFeePercentage,
		C.intCompanyOwnedSiteId,
		C.intDealerSiteId,
		C.intAccountId,
		null as intCreditCardReceivableAccountId,
		null as intFeeExpenseAccountId
	FROM  
		 dbo.tblCCVendorDefault A
		JOIN dbo.tblCCSite C
			ON C.intVendorDefaultId = A.intVendorDefaultId and C.strType = 'DEALER'
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