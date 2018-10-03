CREATE TABLE [dbo].[tblGRTransferStorage]
(
	[intTransferStorageId] INT NOT NULL IDENTITY,
    [strTransferStorageTicket] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intEntityId] INT NOT NULL,
    [intLocationId] INT NOT NULL,
    [intStorageTypeId] INT NOT NULL,
    [intItemId] INT NOT NULL,
    [intItemUOMId] INT NOT NULL,
    [dblTotalUnits] NUMERIC(38,20) NOT NULL,
    [dtmTransferStorageDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [intConcurrencyId] INT NOT NULL,
    CONSTRAINT [PK_tblGRTransferStorage_intTransferStorageId] PRIMARY KEY ([intTransferStorageId]), 
    CONSTRAINT [FK_tblGRTransferStorage_intEntityId_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]),
    CONSTRAINT [FK_tblGRTransferStorage_intLocationId_intCompanyLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [dbo].tblSMCompanyLocation ([intCompanyLocationId]),    
    CONSTRAINT [FK_tblGRTransferStorage_intStorageTypeId_intStorageScheduleTypeId] FOREIGN KEY ([intStorageTypeId]) REFERENCES [dbo].tblGRStorageType (intStorageScheduleTypeId),
    CONSTRAINT [FK_tblGRTransferStorage_intItemId_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].tblICItem ([intItemId]),
    CONSTRAINT [FK_tblGRTransferStorage_intItemUOMId_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [dbo].tblICItemUOM ([intItemUOMId])
    
)
