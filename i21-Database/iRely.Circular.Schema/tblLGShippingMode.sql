CREATE TABLE [dbo].[tblLGShippingMode]
(
 [intShippingModeId] INT NOT NULL IDENTITY,
 [intConcurrencyId] INT NOT NULL,
 [strShippingMode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,

 CONSTRAINT [PK_tblLGShippingMode_intShippingModeId] PRIMARY KEY ([intShippingModeId]),
 CONSTRAINT [UK_tblLGShippingMode_strShippingMode] UNIQUE ([strShippingMode])
 )