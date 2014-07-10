CREATE TABLE [dbo].[cstARCustomer] (
    [intId] INT NOT NULL,
    CONSTRAINT [PK_tblARCustomerCustom_1] PRIMARY KEY CLUSTERED ([intId] ASC),
    CONSTRAINT [FK_cstARCustomer_tblARCustomer] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]) ON DELETE CASCADE
);

