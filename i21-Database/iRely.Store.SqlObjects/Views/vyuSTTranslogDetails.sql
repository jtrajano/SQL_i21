CREATE VIEW dbo.vyuSTTranslogDetails
AS
SELECT *, ROW_NUMBER() OVER (ORDER BY intTermMsgSN ASC) AS intId
FROM
(
	SELECT DISTINCT CAST(TR.intCheckoutId AS NVARCHAR(MAX)) + '0' + CAST(TR.intTermMsgSN AS NVARCHAR(MAX)) AS strUniqueId -- ROW_NUMBER() OVER (ORDER BY intTermMsgSN ASC) AS intUniqeId
       , TR.intTrlDeptNumber
	   , TR.strTrlDept
	   , TR.strTrlNetwCode
	   , TR.strTrlUPC
	   , TR.strTrlDesc
	   , TR. dblTrlQty
	   , TR.dblTrlUnitPrice
	   , TR.dblTrlLineTot
	   , TR.intTermMsgSN
	FROM tblSTTranslogRebates TR
	JOIN tblSTCheckoutHeader CH ON TR.intCheckoutId = CH.intCheckoutId
	JOIN tblSTStore ST ON CH.intStoreId = ST.intStoreId 
) x