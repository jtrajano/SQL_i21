CREATE FUNCTION dbo.fnValidatePO(@poId int, @orderStatus int)
RETURNS BIT 
AS 
-- Returns the stock level for the product.
BEGIN
    
	RETURN(1)
END;
GO

