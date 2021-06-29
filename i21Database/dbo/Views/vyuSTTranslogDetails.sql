CREATE VIEW dbo.vyuSTTranslogDetails
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
	   , dbo.fnSTUPCRemoveLeadingZero(strTrlUPC) AS strTrlUpcWithoutLeadingZero -- 12 digit UPC code
	   , TR.strTrpPaycode
	   , TR.strTrpCardInfoTrpcCCName
	   , TR.strTrlDesc
	   , TR.dblTrlQty
	   , TR.dblTrlUnitPrice
	   , TR.dblTrlLineTot
	   , TR.intTermMsgSN
	   , TR.dtmDate AS dtmDateTime
	   , CONVERT(VARCHAR, TR.dtmDate, 23) AS dtmDate
	   , CAST(TR.intCashierPosNum AS INT) AS intCashierPosNum
	   , CAST(ST.intStoreId AS INT) AS intStoreId
	   , CAST(ST.intStoreNo AS INT) AS intStoreNo
	   , CAST(TR.intTrTickNumPosNum AS INT) AS intTicketPosNum -- Ticket Number
	   , CAST(TR.intTrTickNumTrSeq AS INT) AS intTicketTrSeq -- Ticket Number
	   , TR.strTransType 
	   , CAST(TR.intCashierSysId AS INT) AS intCashierSysId
	   , TR.strCashier
	   , RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(HOUR, TR.dtmDate)), 2) as Hr
	   , CAST(Right(intCashierPosNum , 1) AS INT) as intRegister
	   , CAST((CASE WHEN LEN(strTrlFuelBasePrice) > 0
				THEN 1
				ELSE 0
				END) AS BIT)  as ysnFuel
	   --, USec.intEntityId
	FROM tblSTTranslogRebates TR
	JOIN tblSTStore ST 
		ON TR.intStoreId = ST.intStoreId 
	-- OUTER APPLY tblSMUserSecurity USec
	-- INNER JOIN tblSMUserSecurityCompanyLocationRolePermission RolePerm
		-- ON USec.intEntityId = RolePerm.intEntityId
		-- AND ST.intCompanyLocationId = RolePerm.intCompanyLocationId
	 WHERE (strTransRollback IS NULL) AND (strTransFuelPrepayCompletion IS NULL)
) x