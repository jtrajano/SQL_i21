CREATE TABLE [dbo].[tblRKFutOptTransactionHistory]
(
	intFutOptTransactionHistoryId INT IDENTITY(1,1) NOT NULL, 
	intFutOptTransactionId INT NOT NULL,
	intOldNoOfContract INT NULL,
	intNewNoOfContract INT NOT NULL,
	intBalanceContract INT NOT NULL,
	strScreenName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	strOldBuySell NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	strNewBuySell  NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	dtmTransactionDate DATETIME NOT NULL,
	strUserName NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,

    CONSTRAINT [PK_tblRKFutOptTransactionHistory_intFutOptTransactionHistoryId] PRIMARY KEY CLUSTERED (intFutOptTransactionHistoryId ASC), 	
)