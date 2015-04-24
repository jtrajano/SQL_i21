﻿CREATE TABLE [dbo].[tblCFCreditCard] (
    [intCreditCardId]       INT            IDENTITY (1, 1) NOT NULL,
    [intNetworkId]          INT            NULL,
    [intSiteId]             INT            NULL,
    [strPrefix]             NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intCardId]             INT            NULL,
    [strCardDescription]    NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intCustomerId]         INT            NULL,
    [ysnLocalPrefix]        BIT            NULL,
    [intCreatedUserId]      INT            NULL,
    [dtmCreated]            DATETIME       NULL,
    [intLastModifiedUserId] INT            NULL,
    [dtmLastModified]       DATETIME       NULL,
    [intConcurrencyId]      INT            CONSTRAINT [DF_tblCFCreditCard_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFCreditCard] PRIMARY KEY CLUSTERED ([intCreditCardId] ASC),
    CONSTRAINT [FK_tblCFCreditCard_tblCFSiteLocation] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblCFSite] ([intSiteId])
);



