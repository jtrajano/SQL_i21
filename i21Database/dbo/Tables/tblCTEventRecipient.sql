CREATE TABLE [dbo].[tblCTEventRecipient]
(
	[intEventRecipientId] [int] IDENTITY(1,1) NOT NULL,
	[intEventId] [int] NOT NULL,
	[strEntityType] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intEntityId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTEventRecipient_intEventRecipientId] PRIMARY KEY CLUSTERED ([intEventRecipientId] ASC),
	CONSTRAINT [FK_tblCTEventRecipient_tblCTEvent_intEventId] FOREIGN KEY (intEventId) REFERENCES [tblCTEvent](intEventId) ON DELETE CASCADE,
	CONSTRAINT [UK_tblCTEventRecipient_intEventId_intEntityId] UNIQUE (intEventId,intEntityId),
	CONSTRAINT [FK_tblCTEventRecipient_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId])
)
