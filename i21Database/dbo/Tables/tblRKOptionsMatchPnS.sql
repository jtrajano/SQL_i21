
CREATE TABLE [dbo].[tblRKOptionsMatchPnS]
(
	[intMatchOptionsPnSId]  INT IDENTITY(1,1) NOT NULL,
	[intOptionsMatchPnSHeaderId] int NOT NULL,
	[strTranNo]  nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL , 
	[dtmMatchDate] DATETIME NOT NULL, 
    [intMatchQty] INT NOT NULL, 
	[intLFutOptTransactionId] INT NOT NULL,
	[intSFutOptTransactionId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL,

    CONSTRAINT [PK_tblRKOptionsMatchPnS_intMatchOptionsPnSId] PRIMARY KEY (intMatchOptionsPnSId), 
	CONSTRAINT [FK_tblRKOptionsMatchPnS_tblRKOptionsMatchPnSHeader_intOptionsMatchPnSHeaderId] FOREIGN KEY ([intOptionsMatchPnSHeaderId]) REFERENCES [tblRKOptionsMatchPnSHeader]([intOptionsMatchPnSHeaderId]),	
    CONSTRAINT [FK_tblRKOptionsMatchPnS_tblRKFutOptTransaction_intLFutOptTransactionId] FOREIGN KEY ([intLFutOptTransactionId]) REFERENCES [tblRKFutOptTransaction]([intFutOptTransactionId]),
	CONSTRAINT [FK_tblRKOptionsMatchPnS_tblRKFutOptTransaction_intSFutOptTransactionId] FOREIGN KEY ([intSFutOptTransactionId]) REFERENCES [tblRKFutOptTransaction]([intFutOptTransactionId]),
)