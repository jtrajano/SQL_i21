﻿CREATE TABLE [dbo].[tblGRStorageHistoryDeleteHistory]
(
	[intStorageHistoryDeleteHistoryId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	intSettleStorageId int not null,
	intEntityId int not null,
	dtmAction datetime not null,
	strColumnRecord nvarchar(max),
	strRowRecord nvarchar(max)
)
