CREATE TABLE [dbo].[tblLGWeightClaim]
(
[intWeightClaimId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intReferenceNumber] INT NOT NULL,
[dtmTransDate] DATETIME NULL,
[intShipmentId] INT NULL,
[strComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,

CONSTRAINT [PK_tblLGWeightClaim_intWeightClaimId] PRIMARY KEY ([intWeightClaimId]), 
CONSTRAINT [UK_tblLGWeightClaim_intReferenceNumber] UNIQUE ([intReferenceNumber]),
CONSTRAINT [FK_tblLGWeightClaim_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]),
)
