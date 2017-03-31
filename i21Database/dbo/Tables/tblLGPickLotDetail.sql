CREATE TABLE [dbo].[tblLGPickLotDetail]
(
	[intPickLotDetailId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intPickLotHeaderId] INT NOT NULL, 
	[intAllocationDetailId] INT NULL,
	[intLotId] INT NOT NULL,		
    [dblSalePickedQty] NUMERIC(18, 6) NOT NULL, 
    [dblLotPickedQty] NUMERIC(18, 6) NOT NULL, 
    [intSaleUnitMeasureId] INT NOT NULL, 
    [intLotUnitMeasureId] INT NOT NULL, 
	[dblGrossWt] NUMERIC(18, 6) NOT NULL,
	[dblTareWt] NUMERIC(18, 6) NOT NULL,
	[dblNetWt] NUMERIC(18, 6) NOT NULL,
	[intWeightUnitMeasureId] INT NOT NULL,
	[dtmPickedDate] DATETIME NOT NULL,
    [intUserSecurityId] INT NOT NULL, 	
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 
	
    CONSTRAINT [PK_tblLGPickLotDetail] PRIMARY KEY ([intPickLotDetailId]),
    CONSTRAINT [FK_tblLGPickLotDetail_tblLGPickLotHeader_intPickLotHeaderId] FOREIGN KEY ([intPickLotHeaderId]) REFERENCES [tblLGPickLotHeader]([intPickLotHeaderId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblLGPickLotDetail_tblLGAllocationDetail_intAllocationDetailId] FOREIGN KEY ([intAllocationDetailId]) REFERENCES [tblLGAllocationDetail]([intAllocationDetailId]), 
	CONSTRAINT [FK_tblLGPickLotDetail_tblICLot_intLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]), 
	CONSTRAINT [FK_tblLGPickLotDetail_tblICUnitMeasure_intSaleUnitMeasureId] FOREIGN KEY ([intSaleUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblLGPickLotDetail_tblICUnitMeasure_intLotUnitMeasureId] FOREIGN KEY ([intLotUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblLGPickLotDetail_tblICUnitMeasure_intWeightUnitMeasureId] FOREIGN KEY ([intWeightUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [FK_tblLGPickLotDetail_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId])
)
