CREATE TABLE [dbo].[tblRKMatchDerivativesHistory]
(
	intMatchDerivativeHistoryId INT IDENTITY(1,1) NOT NULL, 
	intMatchFuturesPSHeaderId INT NOT NULL,
	intMatchFuturesPSDetailId INT NOT NULL,
	dblMatchQty NUMERIC(18,6) NULL,
	dtmMatchDate DATETIME NOT NULL,
	dblFutCommission NUMERIC(18, 6) NOT NULL DEFAULT 0,
	intLFutOptTransactionId INT NOT NULL,
	intSFutOptTransactionId INT NOT NULL,	
	dtmTransactionDate DATETIME NOT NULL,
	strUserName NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,

    CONSTRAINT [PK_tblRKMatchDerivativesHistory_intMatchDerivativeHistoryId] PRIMARY KEY CLUSTERED (intMatchDerivativeHistoryId ASC), 	
)