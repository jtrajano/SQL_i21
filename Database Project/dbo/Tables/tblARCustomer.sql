CREATE TABLE [dbo].[tblARCustomer] (
    [intEntityId]         INT             NOT NULL,
    [strCustomerNumber]   NVARCHAR (15)   COLLATE Latin1_General_CI_AS NULL,
    [strType]             NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblCreditLimit]      DECIMAL (18, 2) NOT NULL,
    [dblARBalance]        DECIMAL (18, 2) NOT NULL,
    [strAccountNumber]    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTaxNumber]        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCurrency]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountStatusId]  INT             NOT NULL,
    [intSalesRepId]       INT             NOT NULL,
    [strPricing]          NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strLevel]            NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTimeZone]         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]           BIT             NOT NULL,
    [intBillToId]         INT             NULL,
    [intShipToId]         INT             NULL,
    [intEntityContactId]  INT             NOT NULL,
    [intEntityLocationId] INT             NOT NULL,
    [intConcurrencyID]    INT             NULL,
    CONSTRAINT [PK_dbo.tblARCustomer] PRIMARY KEY CLUSTERED ([intEntityId] ASC),
    CONSTRAINT [FK_dbo.tblARCustomer_dbo.tblEntities_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntities] ([intEntityId])
);


GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblARCustomer]([intEntityId] ASC);

