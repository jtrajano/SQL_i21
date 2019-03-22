CREATE TABLE [dbo].[tblLGReservation]
(
	[intReservationId] INT NOT NULL IDENTITY (1, 1),
	[intConcurrencyId] INT NOT NULL, 
	[intContractDetailId] INT NOT NULL,
	[dblReservedQuantity] NUMERIC(18, 6) NOT NULL,
	[intUnitMeasureId] INT NOT NULL,
	[intPurchaseSale] INT NOT NULL,
	[dtmReservedDate] DATETIME NOT NULL,
	[intUserSecurityId] INT NOT NULL, 	
	[strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 

	CONSTRAINT [PK_tblLGReservation] PRIMARY KEY ([intReservationId]), 
	CONSTRAINT [FK_tblLGReservation_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblLGReservation_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblLGReservation_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId])
)
