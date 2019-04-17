﻿CREATE TABLE [dbo].[tblCTSMTransactionApprovedLog]
(
	[intTransactionApprovedLogId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	strType NVARCHAR(MAX),
	intRecordId INT,
	dtmLog DATETIME,
	ysnOnceApproved BIT,
	strErrMsg NVARCHAR(MAX)
)
