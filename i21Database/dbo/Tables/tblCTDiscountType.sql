CREATE TABLE [dbo].[tblCTDiscountType]
(
	[intDiscountTypeId] INT NOT NULL, 
    [strDiscountType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblCTDiscountType_intDiscountTypeId] PRIMARY KEY ([intDiscountTypeId]) 
)
