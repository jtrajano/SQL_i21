﻿CREATE FUNCTION [dbo].[fnTMComputeNewBurnRateTable]
(
	@intSiteId INT
	,@intInvoiceDetailId INT
	,@intDDReadingId INT 
	,@intPreviousDDReadingId INT 
	,@ysnMultipleInvoice BIT = 0
	,@intDeliveryHistoryId INT = NULL
)
RETURNS @tblReturnValue TABLE(
	dblBurnRate NUMERIC(18,6)
	,ysnMaxExceed BIT
)

BEGIN
	DECLARE @dblBurnRate NUMERIC(18,6)
	DECLARE @dblPreviousBurnRate NUMERIC(18,6)
	DECLARE @ysnAdjustBurnRate BIT
	DECLARE @dblBurnRateAverage NUMERIC(18,6)
	DECLARE @dblCalculatedBurnRate NUMERIC(18,6)
	DECLARE @dblBurnRateChangePercent NUMERIC(18,6)
	DECLARE @intMaxChageDown INT
	DECLARE @intMaxChangeUp INT
	DECLARE @ysnExceedMax BIT
	DECLARE @dblCappedOrFloored NUMERIC(18,6)
	DECLARE @dblReturnValue NUMERIC(18,6)
	
	IF(@intDeliveryHistoryId IS NULL)
	BEGIN
		---Get Site Info
		SELECT
			@dblBurnRate = dblBurnRate
			,@dblPreviousBurnRate = dblPreviousBurnRate
			,@ysnAdjustBurnRate = ysnAdjustBurnRate
		FROM tblTMSite
		WHERE intSiteID = @intSiteId
	END
	ELSE
	BEGIN
		---Get Site Info from delivery history
		SELECT
			@dblBurnRate = dblSiteBurnRate
			,@dblPreviousBurnRate = dblSitePreviousBurnRate
			,@ysnAdjustBurnRate = ysnAdjustBurnRate
		FROM tblTMDeliveryHistory
		WHERE intDeliveryHistoryID = @intDeliveryHistoryId
	END
	
	---- Check for previous Reading 
	IF (ISNULL(@intPreviousDDReadingId,0) = 0)
	BEGIN
		INSERT INTO @tblReturnValue (dblBurnRate,ysnMaxExceed) VALUES (@dblBurnRate,0)
	END
	
	---- Check for ysnAdjust Burn rate
	IF (ISNULL(@ysnAdjustBurnRate,0)  = 0)
	BEGIN
		INSERT INTO @tblReturnValue (dblBurnRate,ysnMaxExceed) VALUES (@dblBurnRate,0)
	END
	ELSE
	BEGIN
	
		--- Get Average Burn rate
		SET	@dblCalculatedBurnRate = dbo.fnTMGetCalculatedBurnRate(@intSiteId,@intInvoiceDetailId,@intDDReadingId,@ysnMultipleInvoice,@intDeliveryHistoryId)
		IF(ISNULL(@dblPreviousBurnRate,0) = 0)
		BEGIN
			SET @dblBurnRateAverage = (ISNULL(@dblCalculatedBurnRate,0) + @dblBurnRate)/2
		END
		ELSE
		BEGIN
			SET @dblBurnRateAverage = (ISNULL(@dblCalculatedBurnRate,0) + @dblBurnRate + @dblPreviousBurnRate)/3
		END
		
		---- Get Burn Rate Change Percent Synch out of range part
		SET @dblBurnRateChangePercent = ((@dblBurnRateAverage - @dblBurnRate)/@dblBurnRate) * 100
		
		SELECT TOP 1
			@intMaxChageDown = ISNULL(intFloorBurnRate,0)
			,@intMaxChangeUp = ISNULL(intCeilingBurnRate,0)
		FROM tblTMPreferenceCompany
		
		SET @ysnExceedMax = 0
		IF((@dblBurnRateChangePercent < 0 AND ABS(@dblBurnRateChangePercent) > @intMaxChageDown)
			OR (@dblBurnRateChangePercent >= 0 AND ABS(@dblBurnRateChangePercent) > @intMaxChangeUp))
		BEGIN
			SET @ysnExceedMax = 1
		END
		
		IF(@dblBurnRateChangePercent < 0)
		BEGIN
			SET @dblCappedOrFloored = 100 - @intMaxChageDown
		END
		ELSE
		BEGIN
			SET @dblCappedOrFloored = 100 + @intMaxChangeUp
		END
		
	END
	
	IF(@ysnExceedMax = 1)
	BEGIN
		SET @dblReturnValue = ((@dblBurnRate * @dblCappedOrFloored)/100)
	END
	ELSE
	BEGIN
		SET @dblReturnValue = @dblBurnRateAverage
	END
	
	INSERT INTO @tblReturnValue (dblBurnRate,ysnMaxExceed) VALUES (@dblReturnValue,@ysnExceedMax)

	RETURN
END

GO