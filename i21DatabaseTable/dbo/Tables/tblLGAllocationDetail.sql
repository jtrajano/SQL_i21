CREATE TABLE [dbo].[tblLGAllocationDetail]
(
	[intAllocationDetailId] INT NOT NULL IDENTITY(1, 1), 
	[strAllocationDetailRefNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL, 
	[intAllocationHeaderId] INT NOT NULL, 
    [intPContractDetailId] INT NOT NULL, 
    [intSContractDetailId] INT NOT NULL, 
    [dblPAllocatedQty] NUMERIC(18, 6) NOT NULL, 
    [dblSAllocatedQty] NUMERIC(18, 6) NOT NULL, 
    [intPUnitMeasureId] INT NOT NULL, 
    [intSUnitMeasureId] INT NOT NULL, 
	[dtmAllocatedDate] DATETIME NOT NULL,
    [intUserSecurityId] INT NOT NULL, 	
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 
	
    CONSTRAINT [PK_tblLGAllocationDetail] PRIMARY KEY ([intAllocationDetailId]),
    CONSTRAINT [FK_tblLGAllocationDetail_tblLGAllocationHeader_intAllocationHeaderId] FOREIGN KEY ([intAllocationHeaderId]) REFERENCES [tblLGAllocationHeader]([intAllocationHeaderId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblLGAllocationDetail_tblCTContractDetail_intPContractDetailId] FOREIGN KEY ([intPContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblLGAllocationDetail_tblCTContractDetail_intSContractDetailId] FOREIGN KEY ([intSContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
    CONSTRAINT [FK_tblLGAllocationDetail_tblICUnitMeasure_intPUnitMeasureId] FOREIGN KEY ([intPUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [FK_tblLGAllocationDetail_tblICUnitMeasure_intSUnitMeasureId] FOREIGN KEY ([intSUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [FK_tblLGAllocationDetail_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]),
)
GO
CREATE NONCLUSTERED INDEX [_dta_index_tblLGAllocationDetail_197_692913540__K4_1] ON [dbo].[tblLGAllocationDetail]
(
	[intPContractDetailId] ASC
)
INCLUDE ( 	[intAllocationDetailId]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGAllocationDetail_197_692913540__K4_K1] ON [dbo].[tblLGAllocationDetail]
(
	[intPContractDetailId] ASC,
	[intAllocationDetailId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGAllocationDetail_197_692913540__K1_K4] ON [dbo].[tblLGAllocationDetail]
(
       [intAllocationDetailId] ASC,
       [intPContractDetailId] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [_dta_index_tblLGLoad_197_1172915250__K5_1] ON [dbo].[tblLGLoad]
(
	[intPurchaseSale] ASC
)
INCLUDE ( 	[intLoadId]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
