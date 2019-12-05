CREATE TABLE [dbo].[tblCMAddendaSequence](
	[intAddendaSequenceId] [int] IDENTITY(1,1) NOT NULL,
	[strTransactionId] [nvarchar](30)  COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblCMAddendaSequence_intAddendaSequenceId] PRIMARY KEY CLUSTERED 
(
	[intAddendaSequenceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
