CREATE TABLE [dbo].[tblARCustomerRecurringPO] (
    [intCustomerRecurringPOId]	INT                 IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]       INT                 NOT NULL,    
    [strRecurringPONumber]      NVARCHAR(50)        COLLATE Latin1_General_CI_AS NULL,    
    [dtmFrom]				    DATETIME            NOT NULL,    
    [dtmTo]				    DATETIME            NOT NULL,    
    [intConcurrencyId]			INT                 NOT NULL,
    [guiApiUniqueId]            UNIQUEIDENTIFIER    NULL,
    CONSTRAINT [PK_tblARCustomerRecurringPO] PRIMARY KEY CLUSTERED ([intCustomerRecurringPOId] ASC),
	CONSTRAINT [FK_tblARCustomerRecurringPO_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE,
);


