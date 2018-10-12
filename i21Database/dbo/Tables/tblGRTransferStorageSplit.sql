CREATE TABLE [dbo].[tblGRTransferStorageSplit]
(
	[intTransferStorageSplitId] INT NOT NULL IDENTITY(1,1),
    [intTransferStorageId] INT NULL,
    [intTransferToCustomerStorageId] INT NULL,
    [intEntityId] INT NULL,
    [intCompanyLocationId] INT NULL,
    [intStorageTypeId] INT NULL,
    [intStorageScheduleId] INT NULL,
    [intContractDetailId] INT NULL,
    [dblSplitPercent] DECIMAL(18,6) NOT NULL DEFAULT 0,
    [dblUnits] NUMERIC(38,20) NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblGRTransferStorageSplit_intTransferStorageSplitId] PRIMARY KEY CLUSTERED ([intTransferStorageSplitId] ASC), 
    CONSTRAINT [FK_tblGRTransferStorageSplit_intTransferStorageId_intTransferStorageId] FOREIGN KEY ([intTransferStorageId]) REFERENCES [dbo].tblGRTransferStorage ([intTransferStorageId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblGRTransferStorageSplit_intEntityId_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
    CONSTRAINT [FK_tblGRTransferStorageSplit_intCompanyLocationId_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].tblSMCompanyLocation ([intCompanyLocationId]),    
    CONSTRAINT [FK_tblGRTransferStorageSplit_intStorageTypeId_intStorageScheduleTypeId] FOREIGN KEY ([intStorageTypeId]) REFERENCES [dbo].tblGRStorageType ([intStorageScheduleTypeId]),
    CONSTRAINT [FK_tblGRTransferStorageSplit_intStorageScheduleId_intStorageScheduleRuleId] FOREIGN KEY ([intStorageScheduleId]) REFERENCES [dbo].tblGRStorageScheduleRule ([intStorageScheduleRuleId])
)
