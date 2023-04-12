
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
		(SELECT ',' + CAST(Contact.strEmail AS NVARCHAR(75)) 
			FROM (SELECT strEmail 
				FROM tblEMEntityToContact I 
				LEFT JOIN tblEMEntity J ON J.intEntityId = I.intEntityContactId
				WHERE I.intEntityId = A.intEntityId
				AND J.strEmailDistributionOption LIKE '%Dealer CC Notification%'
			) Contact
		FOR XML PATH('')),1,1,''
	)
	,A.ysnPassedThruArCustomerFees
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
		CASE WHEN ISNULL(C.ysnPassedThruArCustomer,0) = 0 AND C.ysnSharedFee = 1 AND ISNULL(C.ysnPassedThruArCustomerFees,0) = 1 then 'Company Owned Shared Fees/Pass Thru Fees' --Normal Invoie
			 WHEN ISNULL(C.ysnPassedThruArCustomer,0) = 1 AND C.ysnSharedFee = 1 AND ISNULL(C.ysnPassedThruArCustomerFees,0) = 0 then 'Company Owned Shared Fees/Pass Thru' --cREDIT Memo
			 --WHEN ISNULL(C.ysnPassedThruArCustomer,0) = 0 AND C.ysnSharedFee = 1 AND ISNULL(C.ysnPassedThruArCustomerFees,0) = 0 then 'Company Owned Shared Fees' --no ar
			 WHEN ISNULL(C.ysnPassedThruArCustomer,0) = 1 THEN 'Company Owned Pass Thru' --Credit Memo (Gross less fee(shared))
			 --WHEN ISNULL(C.ysnPassedThruArCustomer,0) = 0 AND C.ysnSharedFee = 1 AND ISNULL(C.ysnPassedThruArCustomerFees,0) = 0 then 'Company Owned Shared Fees' --Normal Invoie

			else 'Company Owned' 		 
		end COLLATE Latin1_General_CI_AS strSiteType,
		 ysnPostNetToArCustomer = C.ysnPassedThruArCustomer,
		 
		CASE WHEN ISNULL(C.ysnSharedFee,0) = 1  THEN dblSharedFeePercentage
			else 0
		end as dblSharedFeePercentage,
		 C.intCompanyOwnedSiteId,
		 C.intDealerSiteId,
		 null as intAccountId,
 		 intCreditCardReceivableAccountId = C.intAccountId,
		 C.intFeeExpenseAccountId,
		 C.ysnPassedThruArCustomerFees
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
		C.intFeeExpenseAccountId,
		C.ysnPassedThruArCustomerFees
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