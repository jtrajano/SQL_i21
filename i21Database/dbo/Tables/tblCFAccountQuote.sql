CREATE TABLE [dbo].[tblCFAccountQuote](
	[intAccountQuoteId] [int] IDENTITY(1,1) NOT NULL,
	[intCustomerGroupId] [int] NOT NULL,
	[inAccountId] INT NOT NULL, 
	[intQuoteProduct1] [int] NULL,
	[intQuoteProduct2] [int] NULL,
	[intQuoteProduct3] [int] NULL,
	[intQuoteProduct4] [int] NULL,
	[intQuoteProduct5] [int] NULL,
	[ysnTaxExempt] [bit] CONSTRAINT [DF_tblCFAccountQuote_ysnTaxExempt] DEFAULT ((0)) NOT NULL,
	[intConcurrencyId] [int]  CONSTRAINT [DF_tblCFAccountQuote_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblCFAccountQuote] PRIMARY KEY CLUSTERED ([intAccountQuoteId] ASC),

);
GO