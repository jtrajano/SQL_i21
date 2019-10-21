CREATE TABLE [dbo].[tblICBackupDetailTransactionDetailLog]
(
	[intBackupDetailId]			INT NOT NULL IDENTITY(1, 1),
	[intBackupId]				INT NOT NULL,
	[intIdentityId]				INT NOT NULL,
    [strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intTransactionId] INT NOT NULL, 
    [intTransactionDetailId] INT NOT NULL, 
    [intOrderNumberId] INT NULL, 
	[intOrderType] INT NOT NULL DEFAULT((0)),
    [intSourceNumberId] INT NULL, 
	[intSourceType] INT NOT NULL DEFAULT((0)),
    [intLineNo] INT NULL, 
    [intItemId] INT NULL, 
    [intItemUOMId] INT NULL, 
    [dblQuantity] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), 
	[ysnLoad] BIT NULL DEFAULT((0)),
	[intLoadReceive] INT NULL DEFAULT ((0)),
	[intCompanyId] INT NULL, 
    CONSTRAINT [PK_tblICBackupDetailTransactionDetailLog] PRIMARY KEY ([intBackupDetailId]),
	CONSTRAINT [FK_tblICBackupDetailTransactionDetailLog_tblICBackup] FOREIGN KEY ([intBackupId]) REFERENCES [tblICBackup]([intBackupId])	
)