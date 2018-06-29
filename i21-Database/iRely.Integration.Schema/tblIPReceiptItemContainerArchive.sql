CREATE TABLE [dbo].[tblIPReceiptItemContainerArchive]
(
	[intStageReceiptItemContainerId] INT IDENTITY(1,1),
	intStageReceiptId INT NOT NULL,
	strContainerNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strContainerSize NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strDeliveryNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strDeliveryItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
	dblQuantity NUMERIC(38,20),
	strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblIPReceiptItemContainerArchive_intStageReceiptItemContainerId] PRIMARY KEY ([intStageReceiptItemContainerId])
)
