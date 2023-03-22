﻿CREATE PROCEDURE [dbo].[uspSMAddOppositeRateDetail]
	@rateDetailId INT
AS
BEGIN
	
	DECLARE @rateId INT
	DECLARE @fromId INT
	DECLARE @toId INT
		
	SELECT @rateId = intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRateDetail WHERE intCurrencyExchangeRateDetailId = @rateDetailId
	SELECT @fromId = intFromCurrencyId, 
		   @toId = intToCurrencyId 
	FROM tblSMCurrencyExchangeRate 
	WHERE intCurrencyExchangeRateId = @rateId

	IF EXISTS (SELECT TOP 1 1 FROM tblSMCurrencyExchangeRate WHERE intFromCurrencyId =  @toId AND intToCurrencyId = @fromId)
	BEGIN

		-- OPPOSITE EXCHANGE RATE
		DECLARE @oppsiteId INT
	
		SELECT @oppsiteId = intCurrencyExchangeRateId FROM tblSMCurrencyExchangeRate WHERE intFromCurrencyId =  @toId AND intToCurrencyId = @fromId

	
		DECLARE @rateTypeId INT
		DECLARE @validFromDate DATETIME
	
		SELECT @rateTypeId = intRateTypeId FROM tblSMCurrencyExchangeRateDetail WHERE intCurrencyExchangeRateDetailId = @rateDetailId
		SELECT @validFromDate = dtmValidFromDate FROM tblSMCurrencyExchangeRateDetail WHERE intCurrencyExchangeRateDetailId = @rateDetailId

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMCurrencyExchangeRateDetail WHERE intCurrencyExchangeRateId = @oppsiteId AND intRateTypeId = @rateTypeId AND dtmValidFromDate = @validFromDate)
		BEGIN
			INSERT INTO tblSMCurrencyExchangeRateDetail(intCurrencyExchangeRateId, dblRate, intRateTypeId, dtmValidFromDate, strSource, dtmCreatedDate)
			SELECT @oppsiteId
			, CASE WHEN ISNULL(dblRate, 0) <> 0
				THEN (1 / dblRate)
				ELSE 0
				END
			, intRateTypeId, dtmValidFromDate, strSource, dtmCreatedDate
			FROM tblSMCurrencyExchangeRateDetail
			WHERE intCurrencyExchangeRateDetailId = @rateDetailId
		END

	END

END
	
