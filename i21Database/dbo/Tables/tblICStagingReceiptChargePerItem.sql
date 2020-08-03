CREATE TABLE [dbo].[tblICStagingReceiptChargePerItem] (
	  intStagingReceiptChargePerItemId INT IDENTITY(1,1)
	, guiUniqueId UNIQUEIDENTIFIER NOT NULL
	, intReceiptId INT NOT NULL
	, intReceiptItemId INT NOT NULL
	, CONSTRAINT PK_tblICStagingReceiptChargePerItem_intStagingReceiptChargePerItemId PRIMARY KEY (intStagingReceiptChargePerItemId)
)