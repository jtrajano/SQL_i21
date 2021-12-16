CREATE VIEW [dbo].[vyuSTTranslogDetails]
AS

SELECT 
	strUniqueId 
	, intTrlDeptNumber
	, strTrlDept
	, strTrlNetwCode
	, strTrlUPC
	, strTrlUpcWithoutLeadingZero
	, strTrpPaycode
	, strTrpCardInfoTrpcCCName
	, strTrlDesc
	, intTermMsgSN
	, dtmDateTime
	, dtmDate
	, intCashierPosNum
	, intStoreId
	, intStoreNo
	, intTicketPosNum
	, intTicketTrSeq
	, strTransType
	, intCashierSysId
	, strCashier
	, intTrTickNumTrSeq
	, Hr
	, intRegister
	, ysnFuel
	, strItemType
	, strTrlMatchLineTrlMatchName
	, dblTrlUnitPrice
	, dblTrlQty
	, dblTrlSign
	, dblTrlUnitPrice * dblTrlQty * dblTrlSign AS dblTrlLineTot  -- Added 10/12/2021
	, ROW_NUMBER() OVER (ORDER BY intTermMsgSN ASC) AS intId
FROM
(       SELECT --DISTINCT  -- update 09/08
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
       
       --, TR.dblTrlUnitPrice removed 09/08/2021
       
       , TR.intTermMsgSN
       , TR.dtmDate AS dtmDateTime
       , CONVERT(VARCHAR, TR.dtmDate, 23) AS dtmDate
       , CAST(TR.intCashierPosNum AS INT) AS intCashierPosNum
       , CAST(TR.intStoreId AS INT) AS intStoreId
       , CAST(TR.intStoreNumber AS INT) AS intStoreNo
       , CAST(TR.intTrTickNumPosNum AS INT) AS intTicketPosNum -- Ticket Number
       , CAST(TR.intTrTickNumTrSeq AS INT) AS intTicketTrSeq -- Ticket Number
       , TR.strTransType 
       , CAST(TR.intCashierSysId AS INT) AS intCashierSysId
       , TR.strCashier
       , TR.intTrTickNumTrSeq -- Added 09/08/2021
       , RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(HOUR, TR.dtmDate)), 2) as Hr
       , CAST(Right(intCashierPosNum , 1) AS INT) as intRegister
       , CAST((CASE WHEN LEN(strTrlFuelBasePrice) > 0
                           THEN 1
                           ELSE 0
                           END) AS BIT)  as ysnFuel
        ,CASE WHEN dblTrlPrcOvrd IS NOT NULL
                    THEN 'O' --Price Override
            WHEN strTrlMatchLineTrlMatchName IS NOT NULL
                    THEN 'M' --Mix/Match Item
            WHEN strTrlUPC IS NULL AND (dblTrlSign = -1 OR dblTrlLineTot < 0 OR strTrlDeptType = 'neg')
                    THEN 'N' --Department Return
            WHEN strTrlUPC IS NOT NULL AND dblTrlSign = -1 
                    THEN 'R' --Item Return
            WHEN strTrlUPC IS NULL
                    THEN 'D' --Department 
            WHEN strTrlUPC IS NOT NULL
                    THEN 'I' --Normal Item 
            END 
        AS strItemType
		,CASE WHEN strTrlUPC IS NOT NULL AND dblTrlSign = -1  --  Added 10/01/2021
		        then  -TR.dblTrlQty
				Else TR.dblTrlQty 
				END as dblTrlQty
	   
		 , CASE WHEN strTrlMatchLineTrlMatchName IS NOT NULL
             THEN TR.dblTrlMatchLineTrlMatchPrice
			   When strTrLoyaltyProgramProgramID is not null
			   THEN  TR.dblTrlLineTot
          Else
            TR.dblTrlUnitPrice END As dblTrlUnitPrice -- added 09/08/2021
       --    , TR.dblTrlLineTot -- removed 09/15/2021

	
	    --,dblTrlUnitPrice * dblTrlQty * dblTrlSign as dblTrlLineTot
		,dblTrlSign -- Added 10/12/2021		
		,TR.strTrlMatchLineTrlMatchName  -- Added 09/26/2021

       FROM tblSTTranslogRebates TR 
       --JOIN tblSTStore ST 
       --       ON TR.intStoreId = ST.intStoreId 
        WHERE (strTransRollback IS NULL) AND (strTransFuelPrepayCompletion IS NULL) and (strTransType not Like '%void%') -- Added 09/26/2021
          
) x