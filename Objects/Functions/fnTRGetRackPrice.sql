CREATE FUNCTION [dbo].[fnTRGetRackPrice]
(
	 @dtmEffectiveDateTime AS DATETIME,	
	 @intSupplyPointId AS INT,
	 @intItemId AS INT
)
RETURNS decimal(18,6)

AS

BEGIN
	DECLARE @RackPrice decimal(18,6)
	DECLARE @strRackPriceToUse nvarchar(50)
	DECLARE @intRackSupplyPointId as int
	
	SELECT @intRackSupplyPointId = intRackPriceSupplyPointId FROM tblTRSupplyPoint WHERE intSupplyPointId = @intSupplyPointId
	
	IF @intRackSupplyPointId IS NULL
	BEGIN
	   SET @intRackSupplyPointId = @intSupplyPointId
    END

	SELECT TOP 1 @strRackPriceToUse = strRackPriceToUse FROM tblTRCompanyPreference
	
	IF (@strRackPriceToUse IS NULL)
	BEGIN
		SET @RackPrice = 0
	END
	
	SELECT TOP 1 @RackPrice = CASE WHEN @strRackPriceToUse = 'Vendor' THEN RP.dblVendorRack
								WHEN @strRackPriceToUse = 'Jobber' THEN RP.dblJobberRack END
	FROM vyuTRGetRackPriceDetail RP
	WHERE RP.intSupplyPointId = @intRackSupplyPointId
		AND RP.intItemId = @intItemId
		AND RP.dtmEffectiveDateTime <= @dtmEffectiveDateTime
	ORDER BY RP.dtmEffectiveDateTime DESC
	
	SET @RackPrice = isNull(@RackPrice, 0)

	RETURN @RackPrice
END
