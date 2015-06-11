CREATE VIEW [dbo].[vyuTRRackPriceEquation]
WITH SCHEMABINDING
	AS 

SELECT DISTINCT  ST2.intItemId, 
ST2.intSupplyPointId,
    (SELECT        (' ' + ST1.strOperand + ' ' + CONVERT(NVARCHAR(50), ST1.dblFactor)) AS [text()]
      FROM            (SELECT DISTINCT  A.intItemId, A.intSupplyPointId, A.strOperand, 
                         A.dblFactor
FROM                                     dbo.tblTRSupplyPointRackPriceEquation A) ST1
WHERE        ST1.intItemId = ST2.intItemId AND ST2.intSupplyPointId = ST1.intSupplyPointId
ORDER BY ST2.intItemId FOR XML PATH('')) [strEquation]
FROM            (SELECT DISTINCT  A.intItemId, A.intSupplyPointId, A.strOperand, 
                         A.dblFactor
FROM                                     dbo.tblTRSupplyPointRackPriceEquation A) ST2    
	
	
	



