CREATE FUNCTION [dbo].[fnGLGetRevalueAccountTableForGL](
    @intAccountCategoryId INT,
    @offsetAccountId INT,
	@ysnOffset BIT
)
RETURNS INT
AS
BEGIN


    DECLARE @out INT
    IF @ysnOffset = 1
    BEGIN
        SELECT @out = intGeneralLedgerRealizedId FROM tblSMMultiCurrency
        IF @intAccountCategoryId = 27  AND  @ysnOffset = 1 --inventory
            SELECT @out = intGainOnForwardRealizedId FROM tblSMMultiCurrency --REPLACE WITH NEW SETTING
        ELSE
        IF @intAccountCategoryId = 46 -- inventory intransit
            SELECT @out = intGainOnSwapRealizedId FROM tblSMMultiCurrency -- REPLACE WITH NEW SETTING
  
    END
    ELSE
        RETURN @offsetAccountId


    RETURN @out


END