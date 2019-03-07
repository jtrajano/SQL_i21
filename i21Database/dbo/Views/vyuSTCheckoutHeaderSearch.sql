CREATE VIEW [dbo].[vyuSTCheckoutHeaderSearch]
AS
SELECT DISTINCT 
     Chk.intCheckoutId
     , ST.intStoreNo
	 , Chk.dtmCheckoutDate
	 , Chk.intShiftNo
	 , Chk.dtmShiftClosedDate
	 , Chk.strCheckoutType
	 , CASE 
			WHEN Inv.ysnPosted = 1
				THEN 'Posted'
			ELSE Chk.strCheckoutStatus
	 END AS strCheckoutStatus
	 , Chk.dblCustomerCount
	 , Chk.dblTotalSales
	 , Chk.dblTotalTax
	 , Chk.dblTotalPaidOuts
	 , Chk.dblTotalToDeposit
	 , Chk.dblTotalDeposits
	 , Chk.dblCashOverShort   
	 , ST.intCompanyLocationId AS intStoreCompanyLocationId
	 , USec.ysnStoreManager AS ysnIsUserStoreManager
	 , USec.ysnAdmin AS ysnIsUserAdmin
	 , USec.strDashboardRole
	 , USec.intEntityId
FROM tblSTCheckoutHeader Chk
INNER JOIN tblSTStore ST
	ON Chk.intStoreId = ST.intStoreId
LEFT JOIN tblARInvoice Inv
	ON Chk.intInvoiceId = Inv.intInvoiceId
INNER JOIN tblSMUserSecurity USec
	ON ST.intCompanyLocationId = USec.intCompanyLocationId
	OR 1 = CASE
				WHEN USec.ysnStoreManager = CAST(0 AS BIT)
					THEN 1
				ELSE 0
			END
--OUTER APPLY tblSMUserSecurity USec
--LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission RolePerm
--	ON USec.intEntityId = RolePerm.intEntityId
--	AND ST.intCompanyLocationId = RolePerm.intCompanyLocationId