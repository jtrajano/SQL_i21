CREATE TABLE [dbo].[tblGRDiscountLocationUse]
(
	[intDiscountLocationUseId] INT NOT NULL  IDENTITY, 
    [intDiscountId] INT NOT NULL, 
    [intCompanyLocationId] INT NOT NULL, 
    [ysnDiscountLocationActive] BIT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblGRDiscountLocationUse_intDiscountLocationUseId] PRIMARY KEY ([intDiscountLocationUseId]), 
    CONSTRAINT [FK_tblGRDiscountLocationUse_tblGRDiscountId_intDiscountId] FOREIGN KEY ([intDiscountId]) REFERENCES [tblGRDiscountId]([intDiscountId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblGRDiscountLocationUse_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
)