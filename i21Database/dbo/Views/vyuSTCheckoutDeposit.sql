CREATE VIEW [dbo].[vyuSTCheckoutDeposit]
AS
SELECT cd.*, bt.intTransactionId, bt.strTransactionId, bt.dtmDate, bt.dblAmount
	FROM tblSTCheckoutDeposits cd
	LEFT JOIN tblCMBankTransaction bt
		ON cd.intBDepId = bt.intTransactionId