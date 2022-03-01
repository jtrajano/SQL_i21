CREATE PROCEDURE [dbo].[uspRKGetFilteredOTCBank]
	  @intBuyCurrencyId INT
	, @intSellCurrencyId INT
AS
BEGIN
	SELECT intBankId
		, strBankName
	FROM tblCMBank bank
	WHERE EXISTS	(SELECT TOP 1 '' FROM vyuCMBankAccount bankAcct 
						WHERE bankAcct.intBankId = bank.intBankId AND bankAcct.intCurrencyId = @intBuyCurrencyId)
		AND EXISTS	(SELECT TOP 1 '' FROM vyuCMBankAccount bankAcct 
						WHERE bankAcct.intBankId = bank.intBankId AND bankAcct.intCurrencyId = @intSellCurrencyId)
END