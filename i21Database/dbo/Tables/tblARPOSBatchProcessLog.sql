CREATE TABLE [dbo].[tblARPOSBatchProcessLog]
(
	[intPOSBatchProcessLogId]	INT             IDENTITY (1, 1) NOT NULL,
	[intPOSId]					INT				NOT NULL,
	[strDescription]			NVARCHAR(500)	COLLATE Latin1_General_CI_AS NULL,
	[ysnSuccess]				BIT				CONSTRAINT [DF_tblARPOSBatchProcessLog_ysnSuccess] DEFAULT ((0)) NOT NULL,
	[dtmDateProcessed]			DATETIME		NULL,
	CONSTRAINT [PK_tblARPOSBatchProcessLog] PRIMARY KEY CLUSTERED ([intPOSBatchProcessLogId] ASC)
)
