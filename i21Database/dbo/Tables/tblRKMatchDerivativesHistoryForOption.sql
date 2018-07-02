CREATE TABLE [dbo].[tblRKMatchDerivativesHistoryForOption]
(
	intMatchDerivativeHistoryForOptionId INT IDENTITY(1,1) NOT NULL, 
	intOptionsMatchPnSHeaderId INT NOT NULL,
	intMatchOptionsPnSId INT NOT NULL,
	intMatchQty int NULL,
	dtmMatchDate DATETIME NOT NULL,
	intLFutOptTransactionId INT NOT NULL,
	intSFutOptTransactionId INT NOT NULL,	
	dtmTransactionDate DATETIME NOT NULL,
	strUserName NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,

    CONSTRAINT [PK_tblRKMatchDerivativesHistoryForOption_intMatchDerivativeHistoryForOptionId] PRIMARY KEY CLUSTERED (intMatchDerivativeHistoryForOptionId ASC), 	
)