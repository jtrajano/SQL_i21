﻿CREATE TABLE [dbo].[tblEMEntityMessage]
(
	[intMessageId]     INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT            NOT NULL,
    [strMessageType]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strAction]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strMessage]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblEMEntityMessage_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblEMEntityMessage] PRIMARY KEY CLUSTERED ([intMessageId] ASC),
	CONSTRAINT [FK_tblEMEntityMessage_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]) ON DELETE CASCADE,

)
