CREATE TABLE [dbo].[tblARCustomerCompetitor]
(
	[intCustomerCompetitorId]				INT IDENTITY(1,1) NOT NULL,
	[intEntityCustomerId]					INT NOT NULL,
    [intEntityId]							INT NOT NULL,	
	[intConcurrencyId]						INT DEFAULT ((0)) NOT NULL,	
	CONSTRAINT [PK_tblARCustomerCompetitor] PRIMARY KEY CLUSTERED ([intCustomerCompetitorId] ASC),
	CONSTRAINT [FK_tblARCustomerCompetitor_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCustomerCompetitor_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
)
