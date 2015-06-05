CREATE VIEW [dbo].[vyuTRRackPriceEquation]
WITH SCHEMABINDING
	AS 

Select  Distinct top 1 ROW_NUMBER() OVER(ORDER BY ST2.intRackPriceDetailId ASC) intRackPriceEquationId,  ST2.intRackPriceDetailId,ST2.intItemId,ST2.intSupplyPointId ,
            (
                Select (   ' ' + ST1.strOperand + ' ' + convert(NVARCHAR(50),ST1.dblFactor) )  AS [text()]
                From dbo.[vyuTRRackItems] ST1
                Where ST1.intItemId = ST2.intItemId AND ST2.intSupplyPointId = ST1.intSupplyPointId 
                ORDER BY ST2.intItemId
                For XML PATH ('')
            ) [strEquation]  
        
        From dbo.[vyuTRRackItems] ST2
