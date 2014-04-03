CREATE TABLE [dbo].[tblARCustomerBuyback] (
    [intBuybackId]          INT             IDENTITY (1, 1) NOT NULL,
    [intEntityId]           INT             NOT NULL,
    [intItemId]             INT             NOT NULL,
    [dtmBeginDate]          DATETIME        NULL,
    [dtmExpirationDate]     DATETIME        NULL,
    [dblDeliveryCommission] NUMERIC (18, 2) NOT NULL,
    [intConcurrencyId]      INT             NOT NULL,
    CONSTRAINT [PK_tblARCustomerBuyback] PRIMARY KEY CLUSTERED ([intBuybackId] ASC)
);

