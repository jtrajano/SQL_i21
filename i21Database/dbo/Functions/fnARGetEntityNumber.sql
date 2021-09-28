CREATE FUNCTION [dbo].[fnARGetEntityNumber]()
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @strEntityNumber NVARCHAR(50)

	EXEC uspSMGetStartingNumber 43, @strEntityNumber OUT
	RETURN @strEntityNumber
END