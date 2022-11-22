CREATE TABLE [dbo].[tblGLIntraCompanyAccountSegment]
(
	[intIntraCompanyAccountSegmentId]	INT IDENTITY(1, 1)	NOT NULL,
	[intTransactionCompanySegmentId]	INT	NOT NULL,
	[intInterCompanySegmentId]			INT	NOT NULL,
	[intDueFromSegmentId]				INT	NOT NULL,
	[intDueToSegmentId]					INT	NOT NULL,
	[intConcurrencyId]					INT DEFAULT (1) NOT NULL,

	CONSTRAINT [PK_tblGLIntraCompanyAccountSegment] PRIMARY KEY CLUSTERED ([intIntraCompanyAccountSegmentId] ASC)
)
