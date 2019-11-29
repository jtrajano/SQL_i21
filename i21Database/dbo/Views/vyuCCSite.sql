﻿
CREATE VIEW [dbo].[vyuCCSite]
--WITH SCHEMABINDING
AS 
SELECT A.intSiteId
	,A.intVendorDefaultId
	,A.intCustomerId
	,A.strSite
	,A.strSiteDescription
	,A.strPaymentMethod
	,A.strCustomerName
	,A.strSiteType
	,A.ysnPostNetToArCustomer
	,A.dblSharedFeePercentage
	,A.intCompanyOwnedSiteId
	,A.intDealerSiteId
	,A.intAccountId
	,A.intCreditCardReceivableAccountId
	,A.intFeeExpenseAccountId
	,strEmail = STUFF(
		(SELECT ',' + CAST(Contact.strEmail AS NVARCHAR) 
			FROM (SELECT strEmail 
				FROM tblEMEntityToContact I 
				LEFT JOIN tblEMEntity J ON J.intEntityId = I.intEntityContactId
				WHERE I.intEntityId = A.intEntityId
			) Contact
		FOR XML PATH('')),1,1,''
	)
FROM (
	SELECT 
		C.intSiteId, 
		A.intVendorDefaultId,
		C.intCustomerId,
		C.strSite,
		C.strSiteDescription,
		D.strPaymentMethod,
		H.intEntityId,
		H.strName as strCustomerName,
		case when C.ysnPassedThruArCustomer is null then 'Company Owned' 
			 when C.ysnPassedThruArCustomer = 1 then 'Company Owned Pass Thru' else 'Company Owned' 		 
			 end COLLATE Latin1_General_CI_AS strSiteType,
		 ysnPostNetToArCustomer = C.ysnPassedThruArCustomer,
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
	UNION ALL
	SELECT
		C.intSiteId, 
		A.intVendorDefaultId,
		C.intCustomerId,
		C.strSite,
		C.strSiteDescription,
		D.strPaymentMethod,
		H.intEntityId,
		H.strName as strCustomerName,
		case when C.ysnSharedFee is null then 'Dealer Site' 
			 when C.ysnSharedFee = 1 then 'Dealer Site Shared Fees' else 'Dealer Site' 		 
			 end COLLATE Latin1_General_CI_AS strSiteType,
		C.ysnPostNetToArCustomer,
		C.dblSharedFeePercentage,
		C.intCompanyOwnedSiteId,
		C.intDealerSiteId,
		C.intAccountId,
		null as intCreditCardReceivableAccountId,
		C.intFeeExpenseAccountId
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
) A
	-- SELECT 
	-- 	C.intSiteId, 
	-- 	A.intVendorDefaultId,
	-- 	C.intCustomerId,
	-- 	C.strSite,
	-- 	C.strSiteDescription,
	-- 	D.strPaymentMethod,
	-- 	H.strName as strCustomerName,
	-- 	J.strEmail,
	-- 	case when C.ysnPassedThruArCustomer is null then 'Company Owned' 
	-- 		 when C.ysnPassedThruArCustomer = 1 then 'Company Owned Pass Thru' else 'Company Owned' 		 
	-- 		 end COLLATE Latin1_General_CI_AS strSiteType,
	-- 	 ysnPostNetToArCustomer = C.ysnPassedThruArCustomer,
	-- 	 0  as dblSharedFeePercentage,
	-- 	 C.intCompanyOwnedSiteId,
	-- 	 C.intDealerSiteId,
	-- 	 null as intAccountId,
 	-- 	 intCreditCardReceivableAccountId = C.intAccountId,
	-- 	 C.intFeeExpenseAccountId
	-- FROM
	-- 	 dbo.tblCCVendorDefault A
	-- 	JOIN dbo.tblCCSite C
	-- 		ON A.intVendorDefaultId = C.intVendorDefaultId and C.strType = 'COMPANY OWNED'
	-- 	LEFT JOIN dbo.tblSMPaymentMethod D
	-- 		ON D.intPaymentMethodID = C.intPaymentMethodId
	-- 	LEFT JOIN dbo.tblARCustomer F
	-- 		ON F.[intEntityId] = C.intCustomerId
	-- 	LEFT JOIN dbo.tblEMEntity H
	-- 		ON H.intEntityId = F.[intEntityId]
	-- 	LEFT JOIN dbo.tblEMEntityToContact I 
	-- 		ON I.intEntityId = H.intEntityId AND I.ysnDefaultContact = 1
	-- 	LEFT JOIN dbo.tblEMEntity J 
	-- 		ON J.intEntityId = I.intEntityContactId
	-- UNION ALL
	-- SELECT
	-- 	C.intSiteId, 
	-- 	A.intVendorDefaultId,
	-- 	C.intCustomerId,
	-- 	C.strSite,
	-- 	C.strSiteDescription,
	-- 	D.strPaymentMethod,
	-- 	H.strName as strCustomerName,
	-- 	J.strEmail,
	-- 	case when C.ysnSharedFee is null then 'Dealer Site' 
	-- 		 when C.ysnSharedFee = 1 then 'Dealer Site Shared Fees' else 'Dealer Site' 		 
	-- 		 end COLLATE Latin1_General_CI_AS strSiteType,
	-- 	C.ysnPostNetToArCustomer,
	-- 	C.dblSharedFeePercentage,
	-- 	C.intCompanyOwnedSiteId,
	-- 	C.intDealerSiteId,
	-- 	C.intAccountId,
	-- 	null as intCreditCardReceivableAccountId,
	-- 	C.intFeeExpenseAccountId
	-- FROM  
	-- 	 dbo.tblCCVendorDefault A
	-- 	JOIN dbo.tblCCSite C
	-- 		ON C.intVendorDefaultId = A.intVendorDefaultId and C.strType = 'DEALER'
	-- 	LEFT JOIN dbo.tblSMPaymentMethod D
	-- 		ON D.intPaymentMethodID = C.intPaymentMethodId
	-- 	LEFT JOIN dbo.tblARCustomer F
	-- 		ON F.[intEntityId] = C.intCustomerId
	-- 	LEFT JOIN dbo.tblEMEntity H
	-- 		ON H.intEntityId = F.[intEntityId]
	-- 	INNER JOIN dbo.tblEMEntityToContact I 
	-- 		ON I.intEntityId = H.intEntityId AND I.ysnDefaultContact = 1
	-- 	INNER JOIN dbo.tblEMEntity J 
	-- 		ON J.intEntityId = I.intEntityContactId