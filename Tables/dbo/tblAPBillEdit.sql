CREATE TABLE [dbo].[tblAPBillEdit]
(
	[intId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[intBillId] INT NOT NULL,
	[strField] NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0
)
