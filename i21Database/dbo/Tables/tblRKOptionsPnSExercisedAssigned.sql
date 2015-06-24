CREATE TABLE [dbo].[tblRKOptionsPnSExercisedAssigned]
(
	[intOptionsPnSExercisedAssignedId]  INT IDENTITY(1,1) NOT NULL,
	[intOptionsMatchPnSHeaderId] int NOT NULL,
	[strTranNo]  nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL , 
	[dtmTranDate] DATETIME NOT NULL, 
	[intLots] INT NOT NULL, 
	[intFutOptTransactionId] INT NOT NULL,
	[intFutTransactionId] int ,
	[ysnAssigned] bit,
	[intConcurrencyId] INT NOT NULL
    CONSTRAINT [PK_tblRKOptionsPnSExercisedAssigned_intOptionsPnSExercisedAssignedId] PRIMARY KEY (intOptionsPnSExercisedAssignedId), 
	CONSTRAINT [FK_tblRKOptionsPnSExercisedAssigned_tblRKOptionsMatchPnSHeader_intOptionsMatchPnSHeaderId] FOREIGN KEY ([intOptionsMatchPnSHeaderId]) REFERENCES [tblRKOptionsMatchPnSHeader]([intOptionsMatchPnSHeaderId]),	
    CONSTRAINT [FK_tblRKOptionsPnSExercisedAssigned_tblRKFutOptTransaction_intFutOptTransactionId] FOREIGN KEY ([intFutOptTransactionId]) REFERENCES [tblRKFutOptTransaction]([intFutOptTransactionId]) ,	
    )
