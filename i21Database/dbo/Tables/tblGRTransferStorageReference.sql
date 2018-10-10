CREATE TABLE [dbo].[tblGRTransferStorageReference]
(
	[intTransferStorageReferenceId] INT NOT NULL IDENTITY,
    [intTransferStorageId] INT NOT NULL,
    [intSourceCustomerStorageId] INT NOT NULL,
    [intTransferToCustomerStorageId] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL,
    CONSTRAINT [PK_tblGRTransferStorageReference_intTransferStorageReferenceId] PRIMARY KEY ([intTransferStorageReferenceId]), 
    CONSTRAINT [FK_tblGRTransferStorageReference_intTransferStorageId_intTransferStorageId] FOREIGN KEY ([intTransferStorageId]) REFERENCES [dbo].tblGRTransferStorage ([intTransferStorageId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblGRTransferStorageReference_intSourceCustomerStorageId_intCustomerStorageId] FOREIGN KEY ([intSourceCustomerStorageId]) REFERENCES [dbo].tblGRCustomerStorage ([intCustomerStorageId]),
    CONSTRAINT [FK_tblGRTransferStorageReference_intTransferToCustomerStorageId_intCustomerStorageId] FOREIGN KEY ([intTransferToCustomerStorageId]) REFERENCES [dbo].tblGRCustomerStorage ([intCustomerStorageId])
)