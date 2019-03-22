CREATE VIEW dbo.vyuSTTranslogHeader
AS
SELECT ROW_NUMBER() OVER (ORDER BY TRR.intTermMsgSN ASC) AS intId 
      , CAST(TRR.intTermMsgSN AS NVARCHAR(MAX)) + '0' +  CAST(TRR.intTermMsgSNterm AS NVARCHAR(MAX)) + '0' + CAST(TRR.intStoreId AS NVARCHAR(MAX)) COLLATE Latin1_General_CI_AS AS strUniqueId
      , TRR.intTermMsgSN
	  , TRR.intStoreId
	  , TRR.intCheckoutId
	  , TRR.dtmCheckoutDate
	  , CAST(TRR.intStoreNo AS NVARCHAR(100)) + ' ' + TRR.strStoreDescription AS strStoreDescription
	  , TRR.strTransType
	  , TRR.dtmDate
	  , TRR.strCashier
	  , TRR.dblTrpAmt
	  , TRR.intCompanyLocationId
	  , TRR.intEntityId
FROM
(   
	SELECT DISTINCT
		 TR.intTermMsgSN
		 , TR.intTermMsgSNterm
		 , TR.intStoreId
		 , TR.intCheckoutId 
		 , TR.strTransType
		 , TR.dtmDate
		 , TR.strCashier
		 , ST.intStoreNo
		 , ST.strDescription AS strStoreDescription
		 , ST.intCompanyLocationId
		 , CH.dtmCheckoutDate
		 , TR.dblTrpAmt
		 , RolePerm.intCompanyLocationId AS intUserCompanyLocationId
		 , USec.ysnStoreManager AS ysnIsUserStoreManager
		 , USec.ysnAdmin AS ysnIsUserAdmin
		 , USec.strDashboardRole
		 , USec.intEntityId
	FROM tblSTTranslogRebates TR
	JOIN tblSTCheckoutHeader CH 
		ON TR.intCheckoutId = CH.intCheckoutId
	JOIN tblSTStore ST 
		ON CH.intStoreId = ST.intStoreId
	OUTER APPLY tblSMUserSecurity USec
	INNER JOIN tblSMUserSecurityCompanyLocationRolePermission RolePerm
		ON USec.intEntityId = RolePerm.intEntityId
		AND ST.intCompanyLocationId = RolePerm.intCompanyLocationId
	WHERE TR.strTrpPaycode = 'CASH'
	AND TR.dblTrpAmt > 0
	--ORDER BY TR.dtmDate OFFSET 0 ROWS
) TRR 