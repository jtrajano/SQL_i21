CREATE VIEW [dbo].[vyuARPOSSearchEndOfDay]
AS
SELECT intPOSEndOfDayId
	 , intCompanyLocationPOSDrawerId
	 , intStoreId
	 , intBankDepositId
	 , intUndepositedFundsId
	 , intCashOverShortId
	 , intEntityId
	 , intCurrencyId
	 , intConcurrencyId
	 , strEODNo
	 , dblOpeningBalance
	 , dblExpectedEndingBalance
	 , dblCashReturn
	 , dblFinalEndingBalance
	 , dtmOpen
	 , dtmClose
	 , ysnClosed
FROM tblARPOSEndOfDay WITH (NOLOCK)