CREATE TABLE [dbo].[tblIPReceiptItemStage]
(
	intStageReceiptItemId INT IDENTITY(1,1),
	intStageReceiptId INT NOT NULL,
	strDeliveryItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSubLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strStorageLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strBatchNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblQuantity NUMERIC(38,20),
	strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strHigherPositionRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblIPReceiptItemStage_intStageReceiptItemId] PRIMARY KEY ([intStageReceiptItemId]),
	CONSTRAINT [FK_tblIPReceiptItemStage_tblIPReceiptStage_intStageReceiptId] FOREIGN KEY ([intStageReceiptId]) REFERENCES [tblIPReceiptStage]([intStageReceiptId]) ON DELETE CASCADE, 
)
