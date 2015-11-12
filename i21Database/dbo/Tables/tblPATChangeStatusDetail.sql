CREATE TABLE [dbo].[tblPATChangeStatusDetail]
(
	[intUpdateDetailId] INT NOT NULL IDENTITY, 
    [intUpdateId] INT NOT NULL, 
    [intCustomerId] INT NULL, 
    [strCurrentStatus] NVARCHAR(50) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATChangeStatusDetail] PRIMARY KEY ([intUpdateDetailId]), 
    CONSTRAINT [FK_tblPATChangeStatusDetail_tblPATChangeStatus] FOREIGN KEY ([intUpdateId]) REFERENCES [tblPATChangeStatus]([intUpdateId]) 
)
