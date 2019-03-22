CREATE TABLE [dbo].[tblPATTransferType]
(
	[intTransferTypeId] INT NOT NULL IDENTITY,
	[intTransferType] INT NULL,
	[strTransferType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_intTransferTypeId] PRIMARY KEY ([intTransferTypeId])
)