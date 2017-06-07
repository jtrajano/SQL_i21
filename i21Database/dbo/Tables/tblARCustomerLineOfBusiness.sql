CREATE TABLE [dbo].[tblARCustomerLineOfBusiness]
(
	[intCustomerLineOfBusinessId] INT IDENTITY(1,1) NOT NULL,
	[intEntityCustomerId]					INT NOT NULL,
    [intLineOfBusinessId]					INT NOT NULL,	
	[intConcurrencyId]						INT CONSTRAINT [DF_tblARCustomerLineOfBusiness_intConCurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARCustomerLineOfBusiness] PRIMARY KEY CLUSTERED ([intCustomerLineOfBusinessId] ASC),
	CONSTRAINT [FK_tblARCustomerLineOfBusiness_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCustomerLineOfBusiness_tblSMLineOfBusiness] FOREIGN KEY ([intLineOfBusinessId]) REFERENCES [dbo].[tblSMLineOfBusiness] ([intLineOfBusinessId]),
)
