CREATE TABLE [dbo].[tblAPVoucherApprover]
(
	[intVoucherApproverId] INT NOT NULL PRIMARY KEY, 
    [intVoucherId] INT NOT NULL, 
    [intLevelId] INT NOT NULL DEFAULT 1, 
	[intApproverId] INT NOT NULL,
    [intAlternateApprover] INT NULL, 
    [ysnApproved] BIT NOT NULL DEFAULT 0, 
    [dtmDateApproved] DATETIME NULL, 
    [strApproverEmail] NVARCHAR(50) NULL, 
    [strAlternateApproverEmail] NVARCHAR(50) NULL
)
