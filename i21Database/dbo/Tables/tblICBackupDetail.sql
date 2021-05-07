CREATE TABLE [dbo].[tblICBackupDetail]
(
	[intBackupDetailId] INT NOT NULL IDENTITY(1,1),    
	[intBackupId] INT NOT NULL,
	[intItemId] INT NULL,
	[intCategoryId] INT NULL,
    [strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [strCategoryCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblICBackupDetail] PRIMARY KEY NONCLUSTERED ([intBackupDetailId])
)