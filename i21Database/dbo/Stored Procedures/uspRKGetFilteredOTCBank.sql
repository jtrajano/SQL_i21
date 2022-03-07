CREATE PROCEDURE [dbo].[uspRKGetFilteredOTCBank]
	  @intBuyCurrencyId INT
	, @intSellCurrencyId INT
	, @intLocationId INT
	, @strInstrumentType NVARCHAR(100)
AS
BEGIN
	SELECT intBankId
		, strBankName
	FROM tblCMBank bank
	WHERE EXISTS	(SELECT TOP 1 '' FROM dbo.fnRKGetOTCAllowedBankAccounts(@intLocationId, @strInstrumentType, @intBuyCurrencyId, bank.intBankId) bankAcct)
		AND EXISTS	(SELECT TOP 1 '' FROM dbo.fnRKGetOTCAllowedBankAccounts(@intLocationId, @strInstrumentType, @intSellCurrencyId, bank.intBankId) bankAcct)
END