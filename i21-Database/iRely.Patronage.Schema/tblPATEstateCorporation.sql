CREATE TABLE [dbo].[tblPATEstateCorporation]
(
	[intEstateCorporationId] INT NOT NULL IDENTITY , 
	[intCorporateCustomerId] INT NOT NULL,
    [intRefundTypeId] INT NOT NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATEstateCorporation] PRIMARY KEY ([intEstateCorporationId]), 
    CONSTRAINT [FK_tblPATEstateCorporation_tblPATRefundRate] FOREIGN KEY ([intRefundTypeId]) REFERENCES [tblPATRefundRate]([intRefundTypeId]) 
)
