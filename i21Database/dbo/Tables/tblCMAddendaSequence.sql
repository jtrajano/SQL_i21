
CREATE TABLE [dbo].[tblCMAddendaSequence](
	[intAddendaSequenceId] [int] IDENTITY(1,1) NOT NULL,
	[intTransactionId] [int] NOT NULL,
 CONSTRAINT [PK_tblCMAddendaSequence_intAddendaSequenceId] PRIMARY KEY CLUSTERED 
(
	[intAddendaSequenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblCMAddendaSequence]  WITH CHECK ADD  CONSTRAINT [FK_tblCMAddendaSequence_tblCMBankTransaction] FOREIGN KEY([intTransactionId])
REFERENCES [dbo].[tblCMBankTransaction] ([intTransactionId])
GO

ALTER TABLE [dbo].[tblCMAddendaSequence] CHECK CONSTRAINT [FK_tblCMAddendaSequence_tblCMBankTransaction]
GO

