CREATE TABLE [dbo].[tblLGWeightClaim]
(
[intWeightClaimId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[strReferenceNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
[dtmTransDate] DATETIME NULL,
[intLoadId] INT NULL,
[strComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NULL,
[dtmETAPOD] DATETIME NULL,
[dtmLastWeighingDate] DATETIME NULL,
[dtmActualWeighingDate] DATETIME NULL,
[dtmClaimValidTill] DATETIME NULL,
[intPurchaseSale] INT NULL,
[ysnPosted] BIT NULL,
[dtmPosted] DATETIME NULL,
[intCompanyId] INT NULL,
[intBookId] INT NULL,
[intSubBookId] INT NULL,
[intWeightClaimRefId] INT NULL, 

CONSTRAINT [PK_tblLGWeightClaim_intWeightClaimId] PRIMARY KEY ([intWeightClaimId]), 
CONSTRAINT [UK_tblLGWeightClaim_intReferenceNumber] UNIQUE ([strReferenceNumber]),
CONSTRAINT [FK_tblLGWeightClaim_tblLGShipment_intShipmentId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]),
CONSTRAINT [FK_tblLGWeightClaim_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
CONSTRAINT [FK_tblLGWeightClaim_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId])
)
