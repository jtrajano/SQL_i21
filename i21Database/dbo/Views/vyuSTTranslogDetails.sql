﻿CREATE VIEW dbo.vyuSTTranslogDetails
AS
SELECT *, ROW_NUMBER() OVER (ORDER BY intTermMsgSN ASC) AS intId
FROM
(
	SELECT DISTINCT 
		CAST(TR.intTermMsgSN AS NVARCHAR(MAX)) + '0' +  CAST(TR.intTermMsgSNterm AS NVARCHAR(MAX)) + '0' + CAST(TR.intStoreId AS NVARCHAR(MAX)) 
			--+ CAST(USec.intEntityId AS NVARCHAR(MAX)) 
			COLLATE Latin1_General_CI_AS AS strUniqueId
       , TR.intTrlDeptNumber
	   , TR.strTrlDept
	   , TR.strTrlNetwCode
	   , TR.strTrlUPC
	   , TR.strTrlDesc
	   , TR. dblTrlQty
	   , TR.dblTrlUnitPrice
	   , TR.dblTrlLineTot
	   , TR.intTermMsgSN
	   , USec.intEntityId
	   , TR.dtmDate
	   , TR.intCashierPosNum
	   , RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(HOUR, TR.dtmDate)), 2) as Hr
	   --, USec.intEntityId
	FROM tblSTTranslogRebates TR
	JOIN tblSTCheckoutHeader CH 
		ON TR.intCheckoutId = CH.intCheckoutId
	JOIN tblSTStore ST 
		ON CH.intStoreId = ST.intStoreId 
	-- OUTER APPLY tblSMUserSecurity USec
	-- INNER JOIN tblSMUserSecurityCompanyLocationRolePermission RolePerm
		-- ON USec.intEntityId = RolePerm.intEntityId
		-- AND ST.intCompanyLocationId = RolePerm.intCompanyLocationId
) x