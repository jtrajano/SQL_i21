﻿CREATE TABLE [dbo].[tblAPBalanceLog]
(
	[intBalanceLogId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[dtmDate] DATETIME NOT NULL,
	[dblAPBalance] DECIMAL(18,6) NOT NULL,
	[dblAPGLBalance] DECIMAL(18,6) NOT NULL
)
