CREATE TABLE [dbo].[tblARCustomerQuote] (
    [intQuoteId]       INT IDENTITY (1, 1) NOT NULL,
    [intEntityId]      INT NOT NULL,
    [intVendorId]      INT NOT NULL,
    [ysnQuote]         BIT CONSTRAINT [DF_tblARCustomerQuote_ysnQuote] DEFAULT ((0)) NOT NULL,
    [intConcurrencyId] INT NOT NULL,
    CONSTRAINT [PK_tblARCustomerQuote] PRIMARY KEY CLUSTERED ([intQuoteId] ASC)
);

