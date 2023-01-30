CREATE FUNCTION [dbo].[fnCTGetDefaultCurrencyExchangeRate]
(
	@intFromCurrencyId		INT
	,@intToCurrencyId		INT
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE
		@dblResult NUMERIC(18,6)
		;

	select top 1
		@dblResult = erd.dblRate
	from
		tblSMCurrencyExchangeRate er
		join tblSMCurrencyExchangeRateDetail erd on erd.intCurrencyExchangeRateId = er.intCurrencyExchangeRateId
	where
		er.intFromCurrencyId = @intFromCurrencyId
		and er.intToCurrencyId = @intToCurrencyId
		and dbo.fnRemoveTimeOnDate(getdate()) >= erd.dtmValidFromDate
	order by
		erd.dtmValidFromDate desc

	select @dblResult = isnull(@dblResult,1);

	RETURN @dblResult
	
END