CREATE TABLE [dbo].[tblRKFutOptTransactionHeaderBook]
(
	intFutOptTransactionHeaderBookId INT IDENTITY(1,1) NOT NULL,
	intFutOptTransactionHeaderId INT NOT NULL,
	intBookId INT NOT NULL,
	CONSTRAINT [PK_tblRKFutOptTransactionHeaderBook_intFutOptTransactionHeaderBookId] PRIMARY KEY (intFutOptTransactionHeaderBookId)
)
