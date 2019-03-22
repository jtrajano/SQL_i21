CREATE TABLE [dbo].[tblTFTransactionDynamicMN]
(
	[intTransactionDynamicId] INT IDENTITY NOT NULL, 
	[intTransactionId] INT NOT NULL,
	[strItemDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblTFTransactionDynamicMN] PRIMARY KEY ([intTransactionDynamicId]),
	CONSTRAINT [FK_tblTFTransactionDynamicMN_tblTFTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES [tblTFTransaction]([intTransactionId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblTFTransactionDynamicMN_intTransactionId] ON [dbo].[tblTFTransactionDynamicMN] ([intTransactionId])

GO
