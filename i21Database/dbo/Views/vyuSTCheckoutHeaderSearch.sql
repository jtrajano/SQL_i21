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
	 , ST.intCompanyLocationId		AS intStoreCompanyLocationId
	 , USec.ysnStoreManager			AS ysnIsUserStoreManager
	 , USec.ysnAdmin				AS ysnIsUserAdmin
	 , USec.strDashboardRole
	 , USec.intEntityId
FROM tblEMEntity em
INNER JOIN tblSMUserSecurity USec
	ON em.intEntityId = USec.intEntityId
LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission Perm
	ON em.intEntityId = Perm.intEntityId 
LEFT JOIN tblSTStore ST
	ON ST.intCompanyLocationId = CASE
										WHEN ((SELECT COUNT(1) FROM tblSMUserSecurityCompanyLocationRolePermission _perm INNER JOIN tblSTStore _st ON _perm.intCompanyLocationId = _st.intCompanyLocationId WHERE _perm.intEntityId = USec.intEntityId) = 0 AND USec.ysnStoreManager = 0)
											-- Full Access Admin
											THEN ST.intCompanyLocationId
										WHEN ((SELECT COUNT(1) FROM tblSMUserSecurityCompanyLocationRolePermission _perm INNER JOIN tblSTStore _st ON _perm.intCompanyLocationId = _st.intCompanyLocationId WHERE _perm.intEntityId = USec.intEntityId) >= 2 AND USec.ysnStoreManager = 0)
											-- Regional Manager
											THEN Perm.intCompanyLocationId
										WHEN (((SELECT COUNT(1) FROM tblSMUserSecurityCompanyLocationRolePermission _perm INNER JOIN tblSTStore _st ON _perm.intCompanyLocationId = _st.intCompanyLocationId WHERE _perm.intEntityId = USec.intEntityId) = 1) AND (USec.ysnStoreManager = 1 AND USec.ysnAdmin = 0))
											-- Store Manager
											THEN Perm.intCompanyLocationId
										ELSE 
											USec.intCompanyLocationId
									END
	--ON ST.intCompanyLocationId = CASE
	--									WHEN USec.ysnAdmin = 1
	--										THEN ST.intCompanyLocationId
	--									WHEN USec.ysnStoreManager = 1
	--										THEN Perm.intCompanyLocationId
	--								END
INNER JOIN tblSTCheckoutHeader Chk
	ON ST.intStoreId = Chk.intStoreId
LEFT JOIN tblARInvoice Inv
	ON Chk.intInvoiceId = Inv.intInvoiceId
INNER JOIN tblSMCompanyLocation CL
	ON ST.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblSTHandheldScanner HS
	ON ST.intStoreId = HS.intStoreId
LEFT JOIN tblSTRegister R 
	ON ST.intRegisterId = R.intRegisterId





--SELECT DISTINCT 
--     Chk.intCheckoutId
--     , ST.intStoreNo
--	 , Chk.dtmCheckoutDate
--	 , Chk.intShiftNo
--	 , Chk.dtmShiftClosedDate
--	 , Chk.strCheckoutType
--	 , CASE 
--			WHEN Inv.ysnPosted = 1
--				THEN 'Posted'
--			ELSE Chk.strCheckoutStatus
--	 END AS strCheckoutStatus
--	 , Chk.dblCustomerCount
--	 , Chk.dblTotalSales
--	 , Chk.dblTotalTax
--	 , Chk.dblTotalPaidOuts
--	 , Chk.dblTotalToDeposit
--	 , Chk.dblTotalDeposits
--	 , Chk.dblCashOverShort   
--	 , ST.intCompanyLocationId AS intStoreCompanyLocationId
--	 , USec.ysnStoreManager AS ysnIsUserStoreManager
--	 , USec.ysnAdmin AS ysnIsUserAdmin
--	 , USec.strDashboardRole
--	 , USec.intEntityId
--FROM tblSTCheckoutHeader Chk
--INNER JOIN tblSTStore ST
--	ON Chk.intStoreId = ST.intStoreId
--LEFT JOIN tblARInvoice Inv
--	ON Chk.intInvoiceId = Inv.intInvoiceId
--INNER JOIN tblSMUserSecurity USec
--	ON ST.intCompanyLocationId = USec.intCompanyLocationId
--	AND (Chk.strCheckoutStatus != CASE
--									WHEN USec.ysnStoreManager = CAST(0 AS BIT)
--										THEN ''
--								END
--		OR Chk.strCheckoutStatus = CASE
--									WHEN USec.ysnStoreManager = CAST(1 AS BIT)
--										THEN 'Open'
--								END)
--	OR 1 = CASE
--				WHEN USec.ysnStoreManager = CAST(0 AS BIT)
--					THEN 1
--				ELSE 0
--			END
--INNER JOIN tblSMUserSecurityCompanyLocationRolePermission Perm
--	ON USec.intEntityId = Perm.intEntityId
--	AND ST.intCompanyLocationId = Perm.intCompanyLocationId
--	OR 1 = CASE
--				WHEN NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityCompanyLocationRolePermission WHERE intEntityId = USec.intEntityId AND intCompanyLocationId = USec.intCompanyLocationId)
--					THEN 1
--				ELSE 0
--			END