CREATE FUNCTION [dbo].[fnTRGetRackPrice]
(
	 @dtmEffectiveDateTime AS DATETIME,	
	 @intSupplyPointId as int,
	 @intItemId as int
)
RETURNS decimal(18,6)
AS
BEGIN
	DECLARE @RackPrice decimal(18,6);
	DECLARE @strRackPriceToUse nvarchar(50);
	DECLARE @intRackSupplyPointId as int;
	select @intRackSupplyPointId= intRackPriceSupplyPointId from tblTRSupplyPoint where intSupplyPointId = @intSupplyPointId 
	IF @intRackSupplyPointId IS NULL
	BEGIN
	   set @intRackSupplyPointId = @intSupplyPointId
    END
	select top 1 @strRackPriceToUse = strRackPriceToUse from tblTRCompanyPreference
	   IF @strRackPriceToUse IS NULL 
       BEGIN
		set @RackPrice = 0
	   END
       select top 1 @RackPrice = CASE
								  WHEN @strRackPriceToUse = 'Vendor'
								  THEN RP.dblVendorRack
								  WHEN @strRackPriceToUse = 'Jobber'
								  THEN RP.dblJobberRack
								  END	   
	   from vyuTRRackPrice RP 	   
	   where RP.intSupplyPointId = @intRackSupplyPointId 
	     and RP.intItemId = @intItemId
	     and RP.dtmEffectiveDateTime <= @dtmEffectiveDateTime
       order by RP.dtmEffectiveDateTime DESC	                          
	   set @RackPrice = isNull(@RackPrice,0);

	RETURN @RackPrice
END
