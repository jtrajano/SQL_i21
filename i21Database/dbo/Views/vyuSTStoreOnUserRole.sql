CREATE VIEW [dbo].[vyuSTStoreOnUserRole]
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
	 , dblEndingBalanceATMFund		= ISNULL(
	 (SELECT TOP 1 dblATMEndBalanceActual 
	 FROM tblSTCheckoutHeader 
	 where dtmCheckoutDate = (SELECT MAX(dtmCheckoutDate) FROM tblSTCheckoutHeader where intStoreId = Store.intStoreId) 
	 and intStoreId = Store.intStoreId order by intShiftNo desc)  , 0)
									
									
	 -- Will be used to load Beg Balance in checkout
	 , dblEndingBalanceChangeFund	= ISNULL(
	 (SELECT TOP 1 dblChangeFundEndBalance 
	 FROM tblSTCheckoutHeader 
	 where dtmCheckoutDate = (SELECT MAX(dtmCheckoutDate) FROM tblSTCheckoutHeader where intStoreId = Store.intStoreId) 
	 and intStoreId = Store.intStoreId order by intShiftNo desc) , 0)
								    

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
	 END COLLATE Latin1_General_CI_AS AS strSAPPHIRECheckoutPullTimePeriod
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
	 END COLLATE Latin1_General_CI_AS AS strSAPPHIRECheckoutPullTimeSet

	 , usec_uRole.strName			AS strDefaultUserRoleName
	 , usec_uRole.strRoleType		AS strDefaultUserRoleType
	 , USec.ysnStoreManager AS ysnIsUserStoreManager
	 , USec.ysnAdmin AS ysnIsUserAdmin
	 , USec.strDashboardRole
	 , USec.intEntityId
	 , perm_uRole.strName			AS strUserRoleName
	 , perm_uRole.strRoleType		AS strUserRoleType 
	 , Store.strState
FROM tblEMEntity em
INNER JOIN tblSMUserSecurity USec
	ON em.intEntityId = USec.intEntityId
INNER JOIN tblSMUserRole usec_uRole
	ON USec.intUserRoleID = usec_uRole.intUserRoleID
LEFT JOIN tblSMUserSecurityCompanyLocationRolePermission Perm
	ON em.intEntityId = Perm.intEntityId 
LEFT JOIN tblSMUserRole perm_uRole
	ON Perm.intUserRoleId = perm_uRole.intUserRoleID
LEFT JOIN tblSTStore Store
	ON Store.intCompanyLocationId = CASE
										WHEN ((SELECT COUNT(1) FROM tblSMUserSecurityCompanyLocationRolePermission _perm WHERE _perm.intEntityId = USec.intEntityId) = 0 AND USec.ysnStoreManager = 0)
											-- Full Access Admin
											THEN Store.intCompanyLocationId
										WHEN ((SELECT COUNT(1) FROM tblSMUserSecurityCompanyLocationRolePermission _perm WHERE _perm.intEntityId = USec.intEntityId) >= 2 AND USec.ysnStoreManager = 0)
											-- Regional Manager
											THEN Perm.intCompanyLocationId
										WHEN (((SELECT COUNT(1) FROM tblSMUserSecurityCompanyLocationRolePermission _perm WHERE _perm.intEntityId = USec.intEntityId) = 1) AND (USec.ysnStoreManager = 1 AND USec.ysnAdmin = 0))
											-- Store Manager
											THEN Perm.intCompanyLocationId
										ELSE 
											USec.intCompanyLocationId
									END
--http://jira.irelyserver.com/browse/ST-1580
--LEFT JOIN tblSTStore Store
--	ON Store.intCompanyLocationId = CASE
--										WHEN ((SELECT COUNT(1) FROM tblSMUserSecurityCompanyLocationRolePermission _perm INNER JOIN tblSTStore _st ON _perm.intCompanyLocationId = _st.intCompanyLocationId WHERE _perm.intEntityId = USec.intEntityId) = 0 AND USec.ysnStoreManager = 0)
--											-- Full Access Admin
--											THEN Store.intCompanyLocationId
--										WHEN ((SELECT COUNT(1) FROM tblSMUserSecurityCompanyLocationRolePermission _perm INNER JOIN tblSTStore _st ON _perm.intCompanyLocationId = _st.intCompanyLocationId WHERE _perm.intEntityId = USec.intEntityId) >= 2 AND USec.ysnStoreManager = 0)
--											-- Regional Manager
--											THEN Perm.intCompanyLocationId
--										WHEN (((SELECT COUNT(1) FROM tblSMUserSecurityCompanyLocationRolePermission _perm INNER JOIN tblSTStore _st ON _perm.intCompanyLocationId = _st.intCompanyLocationId WHERE _perm.intEntityId = USec.intEntityId) = 1) AND (USec.ysnStoreManager = 1 AND USec.ysnAdmin = 0))
--											-- Store Manager
--											THEN Perm.intCompanyLocationId
--										ELSE 
--											USec.intCompanyLocationId
--									END
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