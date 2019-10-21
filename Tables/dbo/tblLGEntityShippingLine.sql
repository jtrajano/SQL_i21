CREATE TABLE [dbo].[tblLGEntityShippingLine]
(
	[intEntityId] INT NOT NULL PRIMARY KEY,
	[strContractNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmContractDate] DATETIME NOT NULL,
	[strAmendmentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[dtmAmendmentDate] DATETIME,
	[dtmValidFrom] DATETIME,
	[dtmValidTo] DATETIME,

	CONSTRAINT [FK_tblLGEntityShippingLine_tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId])
)
