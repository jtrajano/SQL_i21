CREATE TABLE [dbo].[tblLGLoadAllocationDetail]
(
	[intLoadAllocationDetailId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intGenerateLoadId] INT NOT NULL, 
    [intPLoadId] INT NOT NULL, 
    [intSLoadId] INT NOT NULL, 
    [dblPAllocatedQty] NUMERIC(18, 6) NOT NULL, 
    [dblSAllocatedQty] NUMERIC(18, 6) NOT NULL, 
    [intPUnitMeasureId] INT NOT NULL, 
    [intSUnitMeasureId] INT NOT NULL, 
	[dtmAllocatedDate] DATETIME NOT NULL,
    [intUserSecurityId] INT NOT NULL, 	
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 
	
    CONSTRAINT [PK_intLoadAllocationDetailId] PRIMARY KEY ([intLoadAllocationDetailId]),
    CONSTRAINT [FK_tblLGLoadAllocationDetail_tblLGGenerateLoad_intGenerateLoadId] FOREIGN KEY ([intGenerateLoadId]) REFERENCES [tblLGGenerateLoad]([intGenerateLoadId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblLGLoadAllocationDetail_tblLGLoad_intPLoadId] FOREIGN KEY ([intPLoadId]) REFERENCES [tblLGLoad]([intLoadId]),
	CONSTRAINT [FK_tblLGLoadAllocationDetail_tblLGLoad_intSLoadId] FOREIGN KEY ([intSLoadId]) REFERENCES [tblLGLoad]([intLoadId]),
    CONSTRAINT [FK_tblLGLoadAllocationDetail_tblICUnitMeasure_intPUnitMeasureId] FOREIGN KEY ([intPUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [FK_tblLGLoadAllocationDetail_tblICUnitMeasure_intSUnitMeasureId] FOREIGN KEY ([intSUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
    CONSTRAINT [FK_tblLGLoadAllocationDetail_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID])
)
