CREATE TABLE [dbo].[tblGRTransferStorageSplit]
(
	[intTransferStorageSplitId] INT NOT NULL IDENTITY(1,1),
    [intTransferStorageId] INT NOT NULL,
    [intTransferToCustomerStorageId] INT NULL,
    [intEntityId] INT NOT NULL,
    [intCompanyLocationId] INT NOT NULL,
    [intStorageTypeId] INT NOT NULL,
    [intStorageScheduleId] INT NULL,
    [intContractDetailId] INT NULL,
    [dblSplitPercent] DECIMAL(18,6) NOT NULL,
    [dblUnits] NUMERIC(38,20) NOT NULL,
    [intConcurrencyId] INT NOT NULL,
    CONSTRAINT [PK_tblGRTransferStorageSplit_intTransferStorageSplitId] PRIMARY KEY CLUSTERED ([intTransferStorageSplitId] ASC), 
    CONSTRAINT [FK_tblGRTransferStorageSplit_intTransferStorageId_intTransferStorageId] FOREIGN KEY ([intTransferStorageId]) REFERENCES [dbo].tblGRTransferStorage ([intTransferStorageId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblGRTransferStorageSplit_intEntityId_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
    CONSTRAINT [FK_tblGRTransferStorageSplit_intCompanyLocationId_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].tblSMCompanyLocation ([intCompanyLocationId]),    
    CONSTRAINT [FK_tblGRTransferStorageSplit_intStorageTypeId_intStorageScheduleTypeId] FOREIGN KEY ([intStorageTypeId]) REFERENCES [dbo].tblGRStorageType ([intStorageScheduleTypeId]),
    CONSTRAINT [FK_tblGRTransferStorageSplit_intStorageScheduleId_intStorageScheduleRuleId] FOREIGN KEY ([intStorageScheduleId]) REFERENCES [dbo].tblGRStorageScheduleRule ([intStorageScheduleRuleId])
)