CREATE TABLE [dbo].[tblGRTransferStorageSourceSplit]
(
	[intTransferStorageSourceSplitId] INT NOT NULL IDENTITY,
    [intTransferStorageId] INT NOT NULL,
    [intSourceCustomerStorageId] INT NOT NULL,
	[intStorageTypeId] INT NOT NULL,
    [intStorageScheduleId] INT NOT NULL,
    [intContractDetailId] INT NULL,
    [dblOriginalUnits] NUMERIC(38,20) NOT NULL,
    [dblDeductedUnits] NUMERIC(38,20) NOT NULL,
    [intConcurrencyId] INT NOT NULL,
    CONSTRAINT [PK_tblGRTransferStorageSourceSplit_iintTransferStorageSourceSplitId] PRIMARY KEY ([intTransferStorageSourceSplitId]), 
    CONSTRAINT [FK_tblGRTransferStorageSourceSplit_intTransferStorageId_intTransferStorageId] FOREIGN KEY ([intTransferStorageId]) REFERENCES [dbo].tblGRTransferStorage ([intTransferStorageId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGRTransferStorageSourceSplit_intStorageTypeId_intStorageScheduleTypeId] FOREIGN KEY ([intStorageTypeId]) REFERENCES [dbo].tblGRStorageType ([intStorageScheduleTypeId]),
    CONSTRAINT [FK_tblGRTransferStorageSourceSplit_intStorageScheduleId_intStorageScheduleRuleId] FOREIGN KEY ([intStorageScheduleId]) REFERENCES [dbo].tblGRStorageScheduleRule ([intStorageScheduleRuleId]),
    CONSTRAINT [FK_tblGRTransferStorageSourceSplit_intContractDetailId_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].tblCTContractDetail ([intContractDetailId])
)