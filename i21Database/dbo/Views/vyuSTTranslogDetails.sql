CREATE VIEW [dbo].[vyuSTTranslogDetails]
AS

SELECT intTranslogId AS intId
	, strUniqueId 
	, strTrlDeptNumber
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
	, strCustDOB
	, Hr
	, strTransRollback
	, dblTrExNetProdTrENPAmount
	, strTrlModifier
	, intRegister
	, strTrlDeptType
	, strTrLineType
	, ysnFuel
	, dblTrlPrcOvrd
	, intMixMatchDeals
	, strItemType
	, strTrlMatchLineTrlMatchName
	, CAST((CASE WHEN dblTrlQty<>0 
				THEN ROUND(dblTrlLineTot/dblTrlQty,2)
				ELSE dblTrlLineTot 
			END) 
		AS DECIMAL(18,2))  AS dblTrlUnitPrice

	,  CASE WHEN strTrlModifier like '%1'
		        THEN  dblTrlQty * 2
				ELSE dblTrlQty 
				END AS dblTrlQty  
		    -- Added 12/21/2021
	, dblTrlSign
    ,cast((CASE WHEN strTrlMatchLineTrlMatchName IS NOT NULL THEN dblTrlLineTot - intMixMatchDeals * dblTrlMatchLineTrlPromoAmount   
		            --Line total - the number of Mix Match Deals * dblTrlMatchLineTrlPromoAmount
					  ELSE dblTrlLineTot END) AS DECIMAL(18,2)) AS dblTrlLineTot
	    
	--, dblTrlUnitPrice * dblTrlQty * dblTrlSign AS dblTrlLineTot  -- Added 10/12/2021
	--, ROW_NUMBER() OVER (ORDER BY intTermMsgSN ASC) AS intId
FROM
(   SELECT --DISTINCT  -- update 09/08
        intTranslogId
		, CAST(TR.intTermMsgSN AS NVARCHAR(MAX)) + '0' +  CAST(TR.intTermMsgSNterm AS NVARCHAR(MAX)) + '0' + CAST(TR.intStoreId AS NVARCHAR(MAX)) 
                --+ CAST(USec.intEntityId AS NVARCHAR(MAX)) 
                COLLATE Latin1_General_CI_AS AS strUniqueId
       , TR.strTrlDeptNumber
       , TR.strTrlDept
       , TR.strTrlNetwCode
       , TR.strTrlUPC
       , dbo.fnSTUPCRemoveLeadingZero(strTrlUPC)  collate Latin1_General_CI_AS AS strTrlUpcWithoutLeadingZero -- 12 digit UPC code -- Modified the collate  11/17/2021
       , TR.strTrpPaycode
       , TR.strTrpCardInfoTrpcCCName
       , TR.strTrlDesc
	   , TR.dblTrlLineTot
	   , TR.dblTrlMatchLineTrlPromoAmount
       --, TR.dblTrlUnitPrice removed 09/08/2021
       , TR.strTrlDeptType
	   , TR.strTrLineType
       , TR.intTermMsgSN
       , TR.dtmDate AS dtmDateTime
	   , TR.strTransRollback
	   , TR.dblTrExNetProdTrENPAmount
	   , TR.strCustDOB
	   , TR.strTrlModifier
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
	   , TR.dblTrlPrcOvrd 
       , RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(HOUR, TR.dtmDate)), 2) as Hr
       , CAST(RIGHT(intCashierPosNum , 1) AS INT) AS intRegister
       , CAST((CASE WHEN LEN(strTrlFuelBasePrice) > 0
                           THEN 1
                           ELSE 0
                           END) AS BIT)  as ysnFuel
        ,CASE WHEN dblTrlPrcOvrd IS NOT NULL
                    THEN 'O' --Price Override
            WHEN strTrlMatchLineTrlMatchName IS NOT NULL
                    THEN 'M' --Mix/Match Item
           -- WHEN strTrlUPC IS NULL AND (dblTrlSign = -1 OR dblTrlLineTot < 0 OR strTrlDeptType = 'neg') 
		   WHEN strTrlUPC IS NULL AND strTrLineType = 'void dept'
                    THEN 'N' --Department Return
            WHEN strTrlUPC IS NOT NULL AND strTrLineType = 'void plu'
                    THEN 'R' --Item Return
            WHEN strTrlUPC IS NULL
                    THEN 'D' --Department 
            WHEN strTrlUPC IS NOT NULL
                    THEN 'I' --Normal Item 
            END 
        AS strItemType
		,CASE WHEN strTransType like '%refund%' or strTrLineType like '%void%' --  Added 11/17/2021
		        then  TR.dblTrlQty * -1
				Else TR.dblTrlQty 
				END as dblTrlQty 
	     --Flips sign for quantity. If both "refund" and "void" are on the same line, sign does not need flipped.
													 

		 ,Cast(CASE WHEN dblTrlMatchLineTrlMatchQuantity=1 THEN 1 ELSE ROUND((dblTrlQty-.5)/dblTrlMatchLineTrlMatchQuantity,0) END AS INT) AS intMixMatchDeals
		
		
					 

	    --,dblTrlUnitPrice * dblTrlQty * dblTrlSign as dblTrlLineTot
		,dblTrlSign -- Added 10/12/2021		
		,TR.strTrlMatchLineTrlMatchName  -- Added 09/26/2021

       FROM tblSTTranslogRebates TR 
        WHERE  (strTransRollback IS NULL AND strTransFuelPrepay IS NULL AND strTransType NOT LIKE '%suspended%' AND strTransType NOT LIKE '%void%' AND strTrLineType<>'preFuel' AND strTransFuelPrepayCompletion IS NULL) 
		OR     (strTransRollback IS NULL AND strTransFuelPrepay IS NULL AND strTransType NOT LIKE '%suspended%' AND strTransType NOT LIKE '%void%' AND strTrLineType='postFuel' AND strTransFuelPrepayCompletion IS NOT NULL)
       	   
) x
GO