CREATE TABLE [dbo].[tblRKMatchFuturesPSDetail]
(
	[intMatchFuturesPSDetailId]  INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	[intMatchFuturesPSHeaderId] INT NOT NULL, 
	[dblMatchQty] NUMERIC(18, 6) NOT NULL,
	[intLFutOptTransactionId] INT NOT NULL,
	[intSFutOptTransactionId] INT NOT NULL		 
	 CONSTRAINT [PK_tblRKMatchFuturesPSDetail_intMatchFuturesPSDetailId] PRIMARY KEY (intMatchFuturesPSDetailId), 
	 CONSTRAINT [FK_tblRKMatchFuturesPSDetail_tblRKFutOptTransaction_intLFutOptTransactionId] FOREIGN KEY ([intLFutOptTransactionId]) REFERENCES [tblRKFutOptTransaction]([intFutOptTransactionId]),
	 CONSTRAINT [FK_tblRKMatchFuturesPSDetail_tblRKFutOptTransaction_intSFutOptTransactionId] FOREIGN KEY ([intSFutOptTransactionId]) REFERENCES [tblRKFutOptTransaction]([intFutOptTransactionId]),
)