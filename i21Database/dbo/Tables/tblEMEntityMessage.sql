CREATE TABLE [dbo].[tblEMEntityMessage]
(
	[intMessageId]     INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT            NOT NULL,
    [strMessageType]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strAction]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strMessage]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblEMEntityMessage_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntityMessage] PRIMARY KEY CLUSTERED ([intMessageId] ASC),
	CONSTRAINT [FK_tblEMEntityMessage_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,

)

GO

CREATE INDEX [IX_tblEMEntityMessage_intEntityId] ON [dbo].[tblEMEntityMessage] ([intEntityId])
