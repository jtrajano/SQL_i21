CREATE PROCEDURE [dbo].[uspTRGetRackPrice]
	@dtmEffectiveDateTime AS DATETIME
	, @dblAdjustment AS DECIMAL(18,6)
	, @intSupplyPointId AS INT
	, @intItemId AS INT
	, @dblIndexPrice AS DECIMAL(18,6) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @strRackPriceToUse nvarchar(50)

BEGIN TRY

	SELECT TOP 1 @strRackPriceToUse = strRackPriceToUse
	FROM tblTRCompanyPreference
	
	IF (ISNULL(@strRackPriceToUse, '') = '')
	BEGIN
		RAISERROR('Rack Price to Use Setup is missing in Company Configuration', 16, 1)
	END

	SELECT TOP 1 @dblIndexPrice = CASE WHEN @strRackPriceToUse = 'Vendor' THEN RP.dblVendorRack
									WHEN @strRackPriceToUse = 'Jobber' THEN RP.dblJobberRack END
	FROM vyuTRGetRackPriceDetail RP
	WHERE RP.intSupplyPointId = @intSupplyPointId
		AND RP.intItemId = @intItemId
		AND RP.dtmEffectiveDateTime <= @dtmEffectiveDateTime
	ORDER BY RP.dtmEffectiveDateTime DESC
	
	SET @dblIndexPrice = ISNULL(@dblIndexPrice, 0) + ISNULL(@dblAdjustment, 0)

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