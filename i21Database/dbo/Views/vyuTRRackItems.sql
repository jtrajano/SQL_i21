CREATE VIEW [dbo].[vyuTRRackItems]
WITH SCHEMABINDING
	AS 
SELECT 
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
		   A.intItemId = C.intItemId