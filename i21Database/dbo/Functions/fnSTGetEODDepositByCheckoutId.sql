CREATE FUNCTION [dbo].[fnSTGetEODDepositByCheckoutId] 
(
	@intCheckoutId AS INT
)
RETURNS INT
AS BEGIN

    DECLARE @intEODDepositId INT
	IF EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutDeposits WHERE intCheckoutId = @intCheckoutId)
	BEGIN
		SET @intEODDepositId = (SELECT TOP 1 intDepositId FROM tblSTCheckoutDeposits WHERE intCheckoutId = @intCheckoutId);
	END
	ELSE
	BEGIN
		SET @intEODDepositId = 0;
	END

	RETURN @intEODDepositId
END