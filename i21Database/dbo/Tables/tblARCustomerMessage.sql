CREATE TABLE [dbo].[tblARCustomerMessage] (
    [intMessageId]     INT            IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]      INT            NOT NULL,
    [strMessageType]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strAction]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strMessage]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblARCustomerMessage_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARCustomerMessage] PRIMARY KEY CLUSTERED ([intMessageId] ASC)
);

