CREATE TABLE [dbo].[tblTMCustomer] (
    [intConcurrencyID]     INT CONSTRAINT [DEF_tblTMCustomer_intConcurrencyID] DEFAULT ((0)) NULL,
    [intCustomerID]        INT IDENTITY (1, 1) NOT NULL,
    [intCurrentSiteNumber] INT CONSTRAINT [DEF_tblTMCustomer_intCurrentSiteNumber] DEFAULT ((0)) NOT NULL,
    [intCustomerNumber]    INT CONSTRAINT [DEF_tblTMCustomer_intCustomerNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblTMCustomer] PRIMARY KEY CLUSTERED ([intCustomerID] ASC)
);

