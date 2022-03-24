CREATE VIEW dbo.vyuSTTranslogHeader
AS
SELECT ROW_NUMBER() OVER (ORDER BY TRR.intTermMsgSN ASC) AS intId 
      , CAST(TRR.intTermMsgSN AS NVARCHAR(MAX)) + '0' +  CAST(TRR.intTermMsgSNterm AS NVARCHAR(MAX)) + '0' + CAST(TRR.intStoreId AS NVARCHAR(MAX)) 
		  --+ CAST(TRR.intEntityId AS NVARCHAR(MAX)) 
		  COLLATE Latin1_General_CI_AS AS strUniqueId
      , TRR.intTermMsgSN
	  , TRR.intStoreId
	  , TRR.intCheckoutId
	  , TRR.dtmCheckoutDate
	  , TRR.dtmClosedTime
	  , CAST(TRR.intStoreNo AS NVARCHAR(100)) + ' ' + TRR.strStoreDescription AS strStoreDescription
	  , TRR.strTransType
	  , TRR.dtmDate
	  , TRR.strCashier
	  , TRR.dblTrpAmt
	  , TRR.dblTrlQty AS dblTotalTrlQty
	  , TRR.intCompanyLocationId
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
		 , TR.dtmClosedTime
		 , SUM(TR.dblTrlLineTot) AS dblTrpAmt
		 , SUM(TR.dblTrlQty) AS dblTrlQty
	FROM tblSTTranslogRebates TR
	LEFT JOIN tblSTCheckoutHeader CH 
		ON TR.intCheckoutId = CH.intCheckoutId
	LEFT JOIN tblSTStore ST 
		ON TR.intStoreId = ST.intStoreId
	WHERE TR.strTrpPaycode = 'CASH'
	AND TR.dblTrpAmt > 0
	GROUP BY 
		TR.intTermMsgSN
		, TR.intTermMsgSNterm
		, TR.intStoreId
		, TR.intCheckoutId 
		, TR.strTransType
		, TR.dtmDate
		, TR.strCashier
		, ST.intStoreNo
		, ST.strDescription
		, ST.intCompanyLocationId
		, CH.dtmCheckoutDate
		, TR.dtmClosedTime
	--OR, TR.dblTrpAmtDER BY TR.dtmDate OFFSET 0 ROWS
) TRR
GO
