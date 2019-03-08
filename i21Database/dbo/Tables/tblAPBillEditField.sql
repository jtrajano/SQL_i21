CREATE TABLE [dbo].[tblAPBillEditField]
(
	[intId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intTermsId] INT NULL,
	[intEntityId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0
)
