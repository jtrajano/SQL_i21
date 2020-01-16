CREATE TABLE [dbo].[tblICBackupCollateral]
(
	[intId] INT NOT NULL IDENTITY(1,1),
    [intBackupId] INT NOT NULL,
    [strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblICBackupCollateral] PRIMARY KEY NONCLUSTERED ([intId]),	
	CONSTRAINT [FK_tblICBackupCollateral_tblICBackup] FOREIGN KEY ([intBackupId]) REFERENCES [tblICBackup]([intBackupId])
)