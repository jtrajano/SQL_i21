CREATE TABLE [dbo].[tblPOOrderStatus]
(
	[intOrderStatusId] INT NOT NULL PRIMARY KEY, 
    [strStatus] NVARCHAR(25) COLLATE Latin1_General_CI_AS NOT NULL
)
