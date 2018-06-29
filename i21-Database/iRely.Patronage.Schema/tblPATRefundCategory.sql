CREATE TABLE [dbo].[tblPATRefundCategory]
(
	[intRefundCategoryId] INT NOT NULL IDENTITY, 
    [intRefundCustomerId] INT NULL, 
    [intPatronageCategoryId] INT NULL, 
    [dblRefundRate] NUMERIC(18, 6) NULL, 
    [dblVolume] NUMERIC(18, 6) NULL, 
    [dblRefundAmount] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATRefundCategory] PRIMARY KEY ([intRefundCategoryId]), 
    CONSTRAINT [FK_tblPATRefundCategory_tblPATRefundCustomer] FOREIGN KEY ([intRefundCustomerId]) REFERENCES [tblPATRefundCustomer]([intRefundCustomerId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblPATRefundCategory_tblPATPatronageCategory] FOREIGN KEY ([intPatronageCategoryId]) REFERENCES [tblPATPatronageCategory]([intPatronageCategoryId]) 
)
