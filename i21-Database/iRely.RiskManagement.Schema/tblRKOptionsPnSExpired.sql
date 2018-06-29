CREATE TABLE [dbo].[tblRKOptionsPnSExpired]
(
	[intOptionsPnSExpiredId]  INT IDENTITY(1,1) NOT NULL,
	[intOptionsMatchPnSHeaderId] int NOT NULL,
	[strTranNo]  nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL , 
	[dtmExpiredDate] DATETIME NOT NULL, 
    [intLots] INT NOT NULL, 
	[intFutOptTransactionId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL
    CONSTRAINT [PK_tblRKOptionsPnSExpired_intOptionsPnSExpiredId] PRIMARY KEY (intOptionsPnSExpiredId), 
	CONSTRAINT [FK_tblRKOptionsPnSExpired_tblRKOptionsMatchPnSHeader_intOptionsMatchPnSHeaderId] FOREIGN KEY ([intOptionsMatchPnSHeaderId]) REFERENCES [tblRKOptionsMatchPnSHeader]([intOptionsMatchPnSHeaderId]),	
    CONSTRAINT [FK_tblRKOptionsPnSExpired_tblRKFutOptTransaction_intLFutOpTransactionId] FOREIGN KEY ([intFutOptTransactionId]) REFERENCES [tblRKFutOptTransaction]([intFutOptTransactionId])	
)
