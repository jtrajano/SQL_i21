CREATE FUNCTION [dbo].[fnGetStartingNumber](
	@startingNumberId AS INT
)
RETURNS NVARCHAR(20) 
AS 
BEGIN 
    DECLARE @StartingNumber AS NVARCHAR(20)
    EXEC dbo.uspSMGetStartingNumber @startingNumberId, @StartingNumber OUTPUT

    IF @StartingNumber IS NULL 
    BEGIN 
	   -- Raise the error:
	   -- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
	   RAISERROR(50030, 11, 1);
	   RETURN @StartingNumber;
    END 
	RETURN @StartingNumber
END