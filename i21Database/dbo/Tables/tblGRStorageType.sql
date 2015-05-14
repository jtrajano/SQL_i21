CREATE TABLE [dbo].[tblGRStorageType]
(
	[intStorageScheduleTypeId] INT NOT NULL IDENTITY, 
    [strStorageTypeDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strStorageTypeCode] NVARCHAR(3) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnReceiptedStorage] BIT NOT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL, 
    [ysnOwnedPhysicalStock] BIT NOT NULL DEFAULT 0, 
    [ysnDPOwnedType] BIT NOT NULL DEFAULT 0, 
    [ysnGrainBankType] BIT NOT NULL DEFAULT 0, 
    [ysnCustomerStorage] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblGRStorageType_intStorageScheduleTypeId] PRIMARY KEY ([intStorageScheduleTypeId])  
)
