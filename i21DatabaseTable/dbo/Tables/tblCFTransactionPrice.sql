CREATE TABLE [dbo].[tblCFTransactionPrice] (
    [intTransactionPriceId] INT             IDENTITY (1, 1) NOT NULL,
    [intTransactionId]      INT             NOT NULL,
    [strTransactionPriceId] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblOriginalAmount]     NUMERIC (18, 6) NULL,
    [dblCalculatedAmount]   NUMERIC (18, 6) NULL,
    [intConcurrencyId]      INT             CONSTRAINT [DF_tblTransactionPrice_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblTransactionPrice] PRIMARY KEY CLUSTERED ([intTransactionPriceId] ASC),
    CONSTRAINT [FK_tblCFTransactionPrice_tblCFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblCFTransaction] ([intTransactionId]) ON DELETE CASCADE
);




GO
CREATE NONCLUSTERED INDEX [tblCFTransactionPrice_intTransactionPriceId]
    ON [dbo].[tblCFTransactionPrice]([intTransactionPriceId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFTransactionPrice_intTransactionId]
    ON [dbo].[tblCFTransactionPrice]([intTransactionId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_tblCFTransactionPrice_17_359672329__K2_K1_3] ON [dbo].[tblCFTransactionPrice]
(
	[intTransactionId] ASC,
	[intTransactionPriceId] ASC
)
INCLUDE ( 	[strTransactionPriceId])
GO


CREATE NONCLUSTERED INDEX [IX_tblCFTransactionPrice_17_359672329__K2_3] ON [dbo].[tblCFTransactionPrice]
(
	[intTransactionId] ASC
)
INCLUDE ( 	[strTransactionPriceId]) 
GO

CREATE NONCLUSTERED INDEX [IX_tblCFTransactionPrice_17_359672329__K2_K1_3_5] ON [dbo].[tblCFTransactionPrice]
(
	[intTransactionId] ASC,
	[intTransactionPriceId] ASC
)
INCLUDE ( 	[strTransactionPriceId],
	[dblCalculatedAmount]) 

GO
