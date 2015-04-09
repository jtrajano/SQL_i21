CREATE TABLE [dbo].[tblRKFutOptTransactionHeader]
(
	[intFutOptTransactionHeaderId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblRKFutOptTransactionHeader_intFutOptTransactionHeaderId] PRIMARY KEY (intFutOptTransactionHeaderId)
)
