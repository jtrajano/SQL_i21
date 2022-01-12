
CREATE TABLE [dbo].[tblARAuditLog](
	[intAuditLogId] INT IDENTITY(1,1) NOT NULL,
	[strActionType] NVARCHAR(100) NOT NULL,
	[strTransactionType] NVARCHAR(100) NOT NULL,
	[strRecordNo] NVARCHAR (50)  NULL,
	[dtmDate] DATETIME NOT NULL,
	[intUserId] INT  NULL,
	[intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_blARAuditLog_intAuditLogId] PRIMARY KEY CLUSTERED ([intAuditLogId] ASC),
);
