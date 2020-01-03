CREATE TABLE [dbo].[tblCTEventRecipientFilter]
(
	[intEventRecipientFilterId] [int] IDENTITY(1,1) NOT NULL,
	[intEventId] INT NOT NULL,
	intEntityId INT NOT NULL,
	intCommodityId INT NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblCTEventRecipientFilter_intEventRecipientFilterId] PRIMARY KEY CLUSTERED (intEventRecipientFilterId ASC),
	CONSTRAINT [UK_tblCTEventRecipientFilter_tblCTEvent_intEventId_intEntityId_intCommodityId] UNIQUE ([intEventId],[intEntityId],[intCommodityId]),
	CONSTRAINT [FK_tblCTEventRecipientFilter_tblCTEvent_intEventId] FOREIGN KEY ([intEventId]) REFERENCES tblCTEvent([intEventId])
)
