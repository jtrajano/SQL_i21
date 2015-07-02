CREATE FUNCTION [dbo].[fnGetStartingNumber](
	@startingNumberId AS INT
)
RETURNS NVARCHAR(20) 
AS 
BEGIN 
    DECLARE @StartingNumber AS NVARCHAR(20)
    EXEC dbo.uspSMGetStartingNumber @startingNumberId, @StartingNumber OUTPUT

	RETURN @StartingNumber
END