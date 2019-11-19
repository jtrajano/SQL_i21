CREATE TABLE [dbo].[tblAPBalanceDifference]
(
	[intId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[ysnOrigin] BIT NOT NULL DEFAULT 0,
	[dblAPBalance] DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dblAPGLBalance] DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dblDifference] DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[strTransactionId] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL
)
