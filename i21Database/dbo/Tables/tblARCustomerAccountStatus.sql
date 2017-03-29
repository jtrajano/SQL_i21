CREATE TABLE [dbo].[tblARCustomerAccountStatus]
(
	[intCustomerAccountStatusId]			INT IDENTITY(1,1) NOT NULL, 
	[intEntityCustomerId]					INT NOT NULL,
    [intAccountStatusId]					INT NOT NULL,	
	[intConcurrencyId]						INT             CONSTRAINT [DF_tblARCustomerAccountStatus_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblARCustomerAccountStatus] PRIMARY KEY CLUSTERED ([intCustomerAccountStatusId] ASC),
    CONSTRAINT [FK_tblARCustomerAccountStatus_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCustomerAccountStatus_tblARAccountStatus] FOREIGN KEY ([intAccountStatusId]) REFERENCES [dbo].[tblARAccountStatus] ([intAccountStatusId]),
)
