CREATE TABLE [dbo].[tblCTSMTransactionApprovedLog]
(
	[intTransactionApprovedLogId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	strType NVARCHAR(MAX),
	intRecordId INT,
	dtmLog DATETIME,
	strErrMsg NVARCHAR(MAX)
)
