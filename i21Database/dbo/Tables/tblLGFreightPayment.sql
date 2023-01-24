CREATE TABLE [dbo].[tblLGFreightPayment]
(
 [intFreightPaymentId] INT NOT NULL IDENTITY,
 [intConcurrencyId] INT NOT NULL,
 [strFreightPayment] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,

 CONSTRAINT [PK_tblLGFreightPayment_intFreightPaymentId] PRIMARY KEY ([intFreightPaymentId]),
 CONSTRAINT [UK_tblLGFreightPayment_strFreightPayment] UNIQUE ([strFreightPayment])
 )