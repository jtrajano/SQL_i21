CREATE TABLE [dbo].[tblAPBillForPosting]
(
	[intId] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[intBillId] INT NOT NULL,
	[ysnIsPost] BIT
)
