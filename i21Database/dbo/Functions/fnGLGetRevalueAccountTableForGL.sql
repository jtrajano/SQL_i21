CREATE FUNCTION [dbo].[fnGLGetRevalueAccountTableForGL](
    @intAccountCategoryId INT,
    @offsetAccountId INT,
	@ysnOffset BIT
)
RETURNS INT
AS
BEGIN


    DECLARE @out INT
    IF @ysnOffset = 0
    BEGIN
        IF @intAccountCategoryId = 27  --inventory
            SELECT @out = intInventoryRealizedId FROM tblSMMultiCurrency --REPLACE WITH NEW SETTING
        ELSE
        IF @intAccountCategoryId = 46 -- inventory intransit
            SELECT @out = intInventoryInTransitRealizedId FROM tblSMMultiCurrency -- REPLACE WITH NEW SETTING
        ELSE
            SELECT @out = intGeneralLedgerRealizedId FROM tblSMMultiCurrency
    END
    ELSE
        SELECT @out = @offsetAccountId


    RETURN @out

END