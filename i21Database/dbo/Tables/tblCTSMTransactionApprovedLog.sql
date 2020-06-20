CREATE TABLE [dbo].[tblCTSMTransactionApprovedLog]
(
	[intTransactionApprovedLogId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	strType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	intRecordId INT,
	dtmLog DATETIME,
	ysnOnceApproved BIT,
	strErrMsg NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
)
