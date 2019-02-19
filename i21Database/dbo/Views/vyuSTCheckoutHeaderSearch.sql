﻿CREATE VIEW [dbo].[vyuSTCheckoutHeaderSearch]
AS
SELECT DISTINCT 
     Chk.intCheckoutId
     , ST.intStoreNo
	 , Chk.dtmCheckoutDate
	 , Chk.intShiftNo
	 , Chk.strCheckoutType
	 , Chk.dblTotalSales
	 , Chk.dblCashOverShort
     , CASE 
			WHEN Inv.ysnPosted = 1
				THEN 'Posted'
			ELSE Chk.strCheckoutStatus
	END AS strCheckoutStatus
	, ST.intCompanyLocationId AS intStoreCompanyLocationId
	, RolePerm.intCompanyLocationId AS intUserCompanyLocationId
	, USec.ysnStoreManager AS ysnIsUserStoreManager
	, USec.ysnAdmin AS ysnIsUserAdmin
	, USec.strDashboardRole
	, USec.intEntityId
FROM tblSTCheckoutHeader Chk
INNER JOIN tblSTStore ST
	ON Chk.intStoreId = ST.intStoreId
LEFT JOIN tblARInvoice Inv
	ON Chk.intInvoiceId = Inv.intInvoiceId
OUTER APPLY tblSMUserSecurity USec
INNER JOIN tblSMUserSecurityCompanyLocationRolePermission RolePerm
	ON USec.intEntityId = RolePerm.intEntityId
	AND ST.intCompanyLocationId = RolePerm.intCompanyLocationId