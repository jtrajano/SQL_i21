CREATE TABLE [dbo].[tblPATChangeStatusDetail]
(
	[intChangeStatusDetailId] INT NOT NULL IDENTITY, 
    [intChangeStatusId] INT NOT NULL, 
    [intCustomerId] INT NULL, 
    [strCurrentStatus] NVARCHAR(50)  COLLATE Latin1_General_CI_AS  NULL, 
	[strNewStatus] NVARCHAR(50)  COLLATE Latin1_General_CI_AS  NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATChangeStatusDetail] PRIMARY KEY ([intChangeStatusDetailId]), 
    CONSTRAINT [FK_tblPATChangeStatusDetail_tblPATChangeStatus] FOREIGN KEY ([intChangeStatusId]) REFERENCES [tblPATChangeStatus]([intChangeStatusId]) ON DELETE CASCADE
)