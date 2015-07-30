CREATE PROCEDURE [dbo].[uspTRIndexContractsPrice]
	 @dtmEffectiveDateTime AS DATETIME,
	 @dblAdjustment as decimal(18,6),
	 @intSupplyPointId as int,
	 @intItemId as int,
	 @dblIndexPrice decimal(18,6) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @strRackPriceToUse nvarchar(50);
BEGIN TRY

       select top 1 @strRackPriceToUse = strRackPriceToUse from tblTRCompanyPreference
	   IF @strRackPriceToUse IS NULL 
       BEGIN
		RAISERROR('Rack Price to Use Setup is missing in Company Preference', 16, 1);
	   END
       select top 1 @dblIndexPrice = CASE
								  WHEN @strRackPriceToUse = 'Vendor'
								  THEN RP.dblVendorRack
								  WHEN @strRackPriceToUse = 'Jobber'
								  THEN RP.dblJobberRack
								  END	   
	   from vyuTRRackPrice RP 	   
	   where RP.intSupplyPointId = @intSupplyPointId 
	     and RP.intItemId = @intItemId
	     and RP.dtmEffectiveDateTime <= @dtmEffectiveDateTime
       order by RP.dtmEffectiveDateTime DESC	                          
	   set @dblIndexPrice = isNull(@dblIndexPrice,0) + isNull(@dblAdjustment,0)
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH