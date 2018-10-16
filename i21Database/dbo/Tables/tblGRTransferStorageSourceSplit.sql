CREATE TABLE [dbo].[tblGRTransferStorageSourceSplit]
(
	[intTransferStorageSourceSplitId] INT NOT NULL IDENTITY(1,1),
    [intTransferStorageId] INT NULL,
    [intSourceCustomerStorageId] INT NULL,
	[intStorageTypeId] INT NULL,
    [intStorageScheduleId] INT NULL,
    [intContractDetailId] INT NULL,
    [dblSplitPercent] DECIMAL(18,6) NOT NULL DEFAULT 0,
    [dblOriginalUnits] NUMERIC(38,20) NOT NULL DEFAULT 0,
    [dblDeductedUnits] NUMERIC(38,20) NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblGRTransferStorageSourceSplit_iintTransferStorageSourceSplitId] PRIMARY KEY CLUSTERED ([intTransferStorageSourceSplitId] ASC), 
    CONSTRAINT [FK_tblGRTransferStorageSourceSplit_intTransferStorageId_intTransferStorageId] FOREIGN KEY ([intTransferStorageId]) REFERENCES [dbo].tblGRTransferStorage ([intTransferStorageId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGRTransferStorageSourceSplit_intStorageTypeId_intStorageScheduleTypeId] FOREIGN KEY ([intStorageTypeId]) REFERENCES [dbo].tblGRStorageType ([intStorageScheduleTypeId]),
    CONSTRAINT [FK_tblGRTransferStorageSourceSplit_intStorageScheduleId_intStorageScheduleRuleId] FOREIGN KEY ([intStorageScheduleId]) REFERENCES [dbo].tblGRStorageScheduleRule ([intStorageScheduleRuleId]),
    CONSTRAINT [FK_tblGRTransferStorageSourceSplit_intContractDetailId_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].tblCTContractDetail ([intContractDetailId])
)
