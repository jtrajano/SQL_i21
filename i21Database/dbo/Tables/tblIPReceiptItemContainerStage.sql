CREATE TABLE [dbo].[tblIPReceiptItemContainerStage]
(
	[intStageReceiptItemContainerId] INT IDENTITY(1,1),
	intStageReceiptId INT NOT NULL,
	strContainerNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strContainerSize NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strDeliveryNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strDeliveryItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
	dblQuantity NUMERIC(38,20),
	strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblIPReceiptItemContainerStage_intStageReceiptItemContainerId] PRIMARY KEY ([intStageReceiptItemContainerId]),
	CONSTRAINT [FK_tblIPReceiptItemContainerStage_tblIPReceiptStage_intStageReceiptId] FOREIGN KEY ([intStageReceiptId]) REFERENCES [tblIPReceiptStage]([intStageReceiptId]) ON DELETE CASCADE, 
)
