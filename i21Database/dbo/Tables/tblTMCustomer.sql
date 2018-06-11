CREATE TABLE [dbo].[tblTMCustomer] (
    [intConcurrencyId]     INT DEFAULT 1 NOT NULL,
    [intCustomerID]        INT IDENTITY (1, 1) NOT NULL,
    [intCurrentSiteNumber] INT DEFAULT 0 NOT NULL,
    [intCustomerNumber]    INT DEFAULT 0 NOT NULL,
    [strOriginCustomerKey] NVARCHAR(15) COLLATE Latin1_General_CI_AS DEFAULT ('') NOT NULL, 
    CONSTRAINT [PK_tblTMCustomer] PRIMARY KEY CLUSTERED ([intCustomerID] ASC)
);


GO

CREATE INDEX [IX_tblTMCustomer_intCustomerNumber] ON [dbo].[tblTMCustomer] ([intCustomerNumber])

GO

CREATE NONCLUSTERED INDEX [IX_tblTMCustomer_intCustomerID_intCustomerNumber] ON [dbo].[tblTMCustomer]
(
	[intCustomerID] ASC,
	[intCustomerNumber] ASC
)

GO
