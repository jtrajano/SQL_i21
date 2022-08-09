CREATE TABLE [dbo].[tblARCustomerDefaultItem]
(
	[intCustomerDefaultItemId]				INT IDENTITY(1,1) NOT NULL, 
    [intEntityCustomerId]					INT NOT NULL,

	[intItemId]								INT NULL,
	[intEstimatedUnits]						INT NULL,
	[intMonthstoUseForAvg]					INT NULL,
	[strOrderToUseForAvg]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	
	[intConcurrencyId]						INT CONSTRAINT [DF_tblARCustomerDefaultItem_intConcurrencyId] DEFAULT ((0)) NOT NULL,


	CONSTRAINT [PK_tblARCustomerDefaultItem] PRIMARY KEY CLUSTERED ([intCustomerDefaultItemId] ASC),
    CONSTRAINT [FK_tblARCustomerDefaultItem_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
	
	CONSTRAINT [FK_tblARCustomerDefaultItem_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId])
)
