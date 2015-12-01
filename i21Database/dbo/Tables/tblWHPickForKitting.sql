﻿CREATE TABLE [dbo].[tblWHPickForKitting]
(
	intPickForKittingId INT PRIMARY KEY IDENTITY(1,1),
	intPickListId INT,
	strPickListNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	intPickListDetailId INT,
	intPickListLotId INT,
	intPickedLotId INT,
	dblPickListQty NUMERIC(18,6),
	dblPickedQty NUMERIC(18,6), 
	intUserId INT
)