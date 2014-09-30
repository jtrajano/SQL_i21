CREATE TABLE [dbo].[tblARCustomerProductVersion] (
    [intCustomerProductVersionId] INT IDENTITY (1, 1) NOT NULL,
    [intCustomerId]               INT NOT NULL,
    [intProductId]                INT NOT NULL,
    [intVersionId]                INT NOT NULL,
    [intConcurrencyId]            INT CONSTRAINT [DF_tblARCustomerProductVersion_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARCustomerProductVersion] PRIMARY KEY CLUSTERED ([intCustomerProductVersionId] ASC)
);

