﻿CREATE VIEW [dbo].[vyuSTStoreOnUserRole]
AS
SELECT DISTINCT 
	 DENSE_RANK() OVER (ORDER BY Perm.intEntityUserSecurityId, Store.intStoreId, USec.intEntityId) intId
	 , Perm.intEntityUserSecurityId
     , Store.intStoreId
	 , Store.intStoreNo
	 , Store.intRegisterId
	 , Store.strDescription  
	 , Store.intLastShiftNo
	 , Store.dtmLastShiftOpenDate
	 , Store.intCompanyLocationId
	 , intNumberOfShifts			= ISNULL(Store.intNumberOfShifts, 0)

	 -- Will be used to load Beg Balance in checkout
	 , dblEndingBalanceATMFund		= (
										ISNULL((SELECT TOP 1 dblATMEndBalanceCalculated
										FROM tblSTCheckoutHeader
										WHERE intStoreId = Store.intStoreId
										ORDER BY intCheckoutId DESC), 0)
									)
	 -- Will be used to load Beg Balance in checkout
	 , dblEndingBalanceChangeFund	= (
										ISNULL((SELECT TOP 1 dblChangeFundEndBalance
										FROM tblSTCheckoutHeader
										WHERE intStoreId = Store.intStoreId
										ORDER BY intCheckoutId DESC), 0)
								    )

	 , Store.strRegisterCheckoutDataEntry
	 , HS.intHandheldScannerId
	 , CL.strLocationName
	 , R.strRegisterClass
	 , R.strSapphireIpAddress
	 , R.strSAPPHIREUserName
	 , R.strSAPPHIREPassword
	 , ISNULL(R.intSAPPHIRECheckoutPullTimePeriodId, 0) AS intSAPPHIRECheckoutPullTimePeriodId
	 , CASE
			WHEN R.intSAPPHIRECheckoutPullTimePeriodId = 1
				THEN 'Shift Close'
			WHEN R.intSAPPHIRECheckoutPullTimePeriodId = 2
				THEN 'Day Close'
			ELSE ''
	 END AS strSAPPHIRECheckoutPullTimePeriod
	 , ISNULL(R.intSAPPHIRECheckoutPullTimeSetId, 0) AS intSAPPHIRECheckoutPullTimeSetId
	 , CASE
			WHEN R.intSAPPHIRECheckoutPullTimeSetId = 1
				THEN 'Current Data'
			WHEN R.intSAPPHIRECheckoutPullTimeSetId = 2
				THEN 'Last Close Data'
			WHEN R.intSAPPHIRECheckoutPullTimeSetId = 3
				THEN 'Last Close Data - 1'
			WHEN R.intSAPPHIRECheckoutPullTimeSetId = 4
				THEN 'Last Close Data - 2 and on through 9'
			ELSE ''
	 END AS strSAPPHIRECheckoutPullTimeSet

	 , USec.ysnStoreManager AS ysnIsUserStoreManager
	 , USec.ysnAdmin AS ysnIsUserAdmin
	 , USec.strDashboardRole
	 , USec.intEntityId
	 , Store.strState
FROM tblEMEntity em
INNER JOIN tblSMUserSecurity USec
	ON em.intEntityId = USec.intEntityId
LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission Perm
	ON em.intEntityId = Perm.intEntityId 
LEFT JOIN tblSTStore Store
	ON Store.intCompanyLocationId = CASE
										WHEN USec.ysnAdmin = 1
											THEN Store.intCompanyLocationId
										WHEN USec.ysnStoreManager = 1
											THEN Perm.intCompanyLocationId
									END
INNER JOIN tblSMCompanyLocation CL
	ON Store.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblSTHandheldScanner HS
	ON Store.intStoreId = HS.intStoreId
LEFT JOIN tblSTRegister R 
	ON Store.intRegisterId = R.intRegisterId




--WHERE USec.intEntityId = 1
--	AND Perm.intEntityUserSecurityId = 1


--WHERE USec.intEntityId = 1

--CREATE VIEW [dbo].[vyuSTStoreOnUserRole]
--AS
--SELECT 
--		CAST(ROW_NUMBER() over(order by intEntityUserSecurityId desc) AS INT) intId,
--		intEntityUserSecurityId,
--		intStoreId,
--		intStoreNo,
--		strDescription		
--FROM tblSTStore
--INNER JOIN (
--			SELECT  intEntityUserSecurityId
--					,intEntityId
--					,intUserRoleId
--					,intMultiCompanyId
--					,intCompanyLocationId
--					,tblSMUserRole.strRoleType
--					,tblSMUserRole.ysnAdmin
--			FROM tblSMUserSecurityCompanyLocationRolePermission 
--			INNER JOIN tblSMUserRole 
--			ON tblSMUserRole.intUserRoleID = tblSMUserSecurityCompanyLocationRolePermission.intUserRoleId
--) as tblSMUserRoleLocation
--	ON tblSTStore.intCompanyLocationId = tblSMUserRoleLocation.intCompanyLocationId
--		OR ysnAdmin =1 
--	GROUP BY 
--		intEntityUserSecurityId,
--		intStoreId,
--		intStoreNo,
--		strDescription	