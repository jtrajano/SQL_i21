CREATE TABLE [dbo].[tblARCustomerSkyBitzIntegration]
(
	[intCustomerSkyBitzIntegrationId]		INT IDENTITY(1,1) NOT NULL, 
    [intEntityCustomerId]					INT NOT NULL,

	[intTicketCopies]						INT NOT NULL DEFAULT(0),
	[strUserDefined1]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strUserDefined2]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strUserDefined3]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[strUserDefined4]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[ysnPrintTotalizerOnTicket]				BIT, 
	[ysnDisplayTicketInInsight]				BIT, 
	[ysnDisplayPriceInInsight]				BIT, 
	[intAvgDeliveryTime]					INT NOT NULL DEFAULT(0),
	[intExcludeFromAvg]						INT NOT NULL DEFAULT(0),
	[intNumPrevOrderToAvg]					INT NOT NULL DEFAULT(0),
	[intAvgForDayOfWeek]					INT NOT NULL DEFAULT(0),
	[intFuelingRadius]						INT NULL,
	
	[intConcurrencyId]						INT CONSTRAINT [DF_tblARCustomerSkyBitzIntegration_intConcurrencyId] DEFAULT ((0)) NOT NULL,


	CONSTRAINT [PK_tblARCustomerSkyBitzIntegration] PRIMARY KEY CLUSTERED ([intCustomerSkyBitzIntegrationId] ASC),
    CONSTRAINT [FK_tblARCustomerSkyBitzIntegration_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
)
