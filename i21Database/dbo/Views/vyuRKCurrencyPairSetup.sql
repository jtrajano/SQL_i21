CREATE VIEW [dbo].[vyuRKCurrencyPairSetup]
AS
SELECT 
	  intCurrencyPairId = CP.intCurrencyPairId
	, intFromCurrencyId = CP.intFromCurrencyId
	, strFromCurrency = FC.strCurrency
	, intToCurrencyId = CP.intToCurrencyId
	, strToCurrency = TC.strCurrency
	, strCurrencyPair = TC.strCurrency + '/' + FC.strCurrency
	, dtmCreateDateTime = CP.dtmCreateDateTime
	, intConcurrencyId = CP.intConcurrencyId
FROM tblRKCurrencyPair CP
JOIN tblSMCurrency FC
	ON FC.intCurrencyID = CP.intFromCurrencyId
JOIN tblSMCurrency TC
	ON TC.intCurrencyID = CP.intToCurrencyId