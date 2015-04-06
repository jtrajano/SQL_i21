CREATE TABLE [dbo].[cstARCustomer] (
    [intId] INT NOT NULL,
    CONSTRAINT [PK_cstARCustomer] PRIMARY KEY CLUSTERED ([intId] ASC),
    CONSTRAINT [FK_cstARCustomer_tblARCustomer1] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]) ON DELETE CASCADE
);





