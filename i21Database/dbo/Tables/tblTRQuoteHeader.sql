CREATE TABLE [dbo].[tblTRQuoteHeader]
(
	[intQuoteHeaderId] INT NOT NULL IDENTITY,
	[strQuoteNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strQuoteStatus] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmQuoteDate]  DATETIME        NOT NULL,
	[dtmQuoteEffectiveDate]  DATETIME        NOT NULL,	
	[intEntityCustomerId] INT NOT NULL,
	[strQuoteComments] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerComments] nvarchar(max) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblTRQuoteHeader] PRIMARY KEY ([intQuoteHeaderId]),	
	CONSTRAINT [FK_tblTRQuoteHeader_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] (intEntityId)
	
)
