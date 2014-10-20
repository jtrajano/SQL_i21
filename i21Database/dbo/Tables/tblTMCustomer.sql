CREATE TABLE [dbo].[tblTMCustomer] (
    [intConcurrencyId]     INT DEFAULT 1 NOT NULL,
    [intCustomerID]        INT IDENTITY (1, 1) NOT NULL,
    [intCurrentSiteNumber] INT DEFAULT 0 NOT NULL,
    [intCustomerNumber]    INT DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_tblTMCustomer] PRIMARY KEY CLUSTERED ([intCustomerID] ASC)
);

