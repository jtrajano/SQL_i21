CREATE VIEW [dbo].[vyuSTStoreOnUserRole]
AS
SELECT DISTINCT 
	 CAST(ROW_NUMBER() over(order by Perm.intEntityUserSecurityId desc) AS INT) intId
	 , Perm.intEntityUserSecurityId
     , Store.intStoreId
	 , Store.intStoreNo
	 , Store.strDescription  
	 , Store.intLastShiftNo
	 , Store.dtmLastShiftOpenDate
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
FROM tblSTStore Store
INNER JOIN tblSMUserSecurity USec
	ON Store.intCompanyLocationId = USec.intCompanyLocationId
	OR 1 = CASE
				WHEN USec.ysnStoreManager = CAST(0 AS BIT)
					THEN 1
				ELSE 0
			END
INNER JOIN tblSMUserSecurityCompanyLocationRolePermission Perm
	ON USec.intEntityId = Perm.intEntityId
	AND Store.intCompanyLocationId = Perm.intCompanyLocationId
	--OR 1 = CASE
	--			WHEN NOT EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityCompanyLocationRolePermission WHERE intEntityId = USec.intEntityId AND intCompanyLocationId = USec.intCompanyLocationId)
	--				THEN 1
	--			ELSE 0
	--		END

LEFT JOIN tblSTHandheldScanner HS
	ON Store.intStoreId = HS.intStoreId
LEFT JOIN tblSTRegister R 
	ON Store.intRegisterId = R.intRegisterId
JOIN tblSMCompanyLocation CL
	ON Store.intCompanyLocationId = CL.intCompanyLocationId


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