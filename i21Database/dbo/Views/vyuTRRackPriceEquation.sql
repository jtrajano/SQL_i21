CREATE VIEW [dbo].[vyuTRRackPriceEquation]
WITH SCHEMABINDING
	AS 

Select  Distinct top 1 ROW_NUMBER() OVER(ORDER BY ST2.intRackPriceDetailId ASC) intRackPriceEquationId,  ST2.intRackPriceDetailId,ST2.intItemId,ST2.intSupplyPointId ,
            (
                Select (   ' ' + ST1.strOperand + ' ' + convert(NVARCHAR(50),ST1.dblFactor) )  AS [text()]
                From (SELECT 
                             ROW_NUMBER() OVER(ORDER BY intRackPriceDetailId ASC) intRackItemsId,
							 A.intRackPriceDetailId,
							 A.intItemId,
							 B.intSupplyPointId,
							 C.strOperand,
							 C.dblFactor
                      FROM
							dbo.tblTRRackPriceDetail A
							INNER JOIN dbo.tblTRRackPriceHeader B
								ON A.intRackPriceHeaderId = B.intRackPriceHeaderId
							INNER JOIN dbo.tblTRSupplyPointRackPriceEquation C
								ON B.intSupplyPointId = C.intSupplyPointId and 
								   A.intItemId = C.intItemId) ST1

                Where ST1.intItemId = ST2.intItemId AND ST2.intSupplyPointId = ST1.intSupplyPointId 
                ORDER BY ST2.intItemId
                For XML PATH ('')
            ) [strEquation]  
        
        From (SELECT 
                    ROW_NUMBER() OVER(ORDER BY intRackPriceDetailId ASC) intRackItemsId,
					A.intRackPriceDetailId,
					A.intItemId,
					B.intSupplyPointId,
					C.strOperand,
					C.dblFactor
              FROM
                     dbo.tblTRRackPriceDetail A
					INNER JOIN dbo.tblTRRackPriceHeader B
						ON A.intRackPriceHeaderId = B.intRackPriceHeaderId
					INNER JOIN dbo.tblTRSupplyPointRackPriceEquation C
						ON B.intSupplyPointId = C.intSupplyPointId and 
						   A.intItemId = C.intItemId) ST2
	
	
	
	
	
    
	
	
	



