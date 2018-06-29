CREATE VIEW dbo.vyuSTTranslogHeader
AS
SELECT ROW_NUMBER() OVER (ORDER BY intTermMsgSN ASC) AS intId 
      , CAST(TRR.intCheckoutId AS NVARCHAR(MAX)) + '0' + CAST(TRR.intTermMsgSN AS NVARCHAR(MAX)) AS strUniqueId
      , TRR.intTermMsgSN
	  , TRR.intStoreId
	  , TRR.intCheckoutId
	  , TRR.dtmCheckoutDate
	  , CAST(TRR.intStoreNo AS NVARCHAR(100)) + ' ' + TRR.strStoreDescription AS strStoreDescription
	  , TRR.strTransType
	  , TRR.dtmDate
	  , TRR.strCashier
	  , TRR.dblTrValueTrTotWTax
	  , TRR.intCompanyLocationId
FROM
(   
	SELECT TR.*
	       , ST.intStoreNo
		   , ST.strDescription AS strStoreDescription
		   , ST.intCompanyLocationId
		   , CH.dtmCheckoutDate
		   , ROW_NUMBER() OVER (PARTITION BY TR.intTermMsgSN, TR.intStoreId, TR.intCheckoutId ORDER BY TR.intTermMsgSN ASC) AS rn
	FROM tblSTTranslogRebates TR
	JOIN tblSTCheckoutHeader CH ON TR.intCheckoutId = CH.intCheckoutId
	JOIN tblSTStore ST ON CH.intStoreId = ST.intStoreId 
) TRR 
WHERE TRR.rn = 1