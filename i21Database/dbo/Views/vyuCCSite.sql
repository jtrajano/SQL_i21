
CREATE VIEW [dbo].[vyuCCSite]
WITH SCHEMABINDING
	AS 
SELECT 
	C.intSiteId, 
	A.intVendorDefaultId,
	C.strSite,
	C.strSiteDescription,
	G.strPaymentMethod,
	I.strName as strCustomerName,
    case when B.ysnPassedThruArCustomer is null then 'Company Owned' 
	     when B.ysnPassedThruArCustomer = 1 then 'Company Owned Pass Thru' else 'Company Owned' 		 
		 end strSiteType,
	 0  as ysnPostNetToArCustomer,
	 0  as intSharedFeePercentage
FROM
     dbo.tblCCVendorDefault A
	JOIN dbo.tblCCCompanyOwnedSite B
		ON A.intVendorDefaultId = B.intVendorDefaultId
	JOIN dbo.tblCCSite C
		ON B.intCompanyOwnedSiteId = C.intCompanyOwnedSiteId
	JOIN dbo.tblSMPaymentMethod G
	    ON G.intPaymentMethodID = C.intPaymentMethodId
    JOIN dbo.tblARCustomer H
	    ON H.intEntityCustomerId = C.intCustomerId
	JOIN dbo.tblEntity I
	    ON I.intEntityId = H.intEntityCustomerId
UNION ALL
SELECT
    F.intSiteId, 
	D.intVendorDefaultId,
	F.strSite,
	F.strSiteDescription,
	J.strPaymentMethod,
	L.strName as strCustomerName,
    case when E.ysnSharedFee is null then 'Dealer Site' 
	     when E.ysnSharedFee = 1 then 'Dealer Site Shared Fees' else 'Dealer Site' 		 
		 end strSiteType,
	E.ysnPostNetToArCustomer,
	E.intSharedFeePercentage
FROM
     
	 dbo.tblCCVendorDefault D
	JOIN dbo.tblCCDealerSite E
		ON D.intVendorDefaultId = E.intVendorDefaultId
	JOIN dbo.tblCCSite F
		ON E.intDealerSiteId = F.intDealerSiteId
    LEFT JOIN dbo.tblSMPaymentMethod J
	    ON J.intPaymentMethodID = F.intPaymentMethodId
    LEFT JOIN dbo.tblARCustomer K
	    ON K.intEntityCustomerId = F.intCustomerId
	LEFT JOIN dbo.tblEntity L
	    ON L.intEntityId = K.intEntityCustomerId
	
	
	

