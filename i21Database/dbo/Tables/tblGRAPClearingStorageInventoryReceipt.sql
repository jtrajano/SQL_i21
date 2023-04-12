CREATE TABLE [dbo].[tblGRAPClearingStorageInventoryReceipt]
(
	intAPClearingStorageInventoryReceipt INT PRIMARY KEY IDENTITY(1,1)
	,intEntityVendorId INT
    ,dtmDate DATETIME
    ,strTransactionNumber NVARCHAR(40) COLLATE Latin1_General_CI_AS
    ,intInventoryReceiptId INT NULL
    ,intBillId INT NULL
    ,strBillId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
    ,intBillDetailId INT NULL
    ,intInventoryReceiptItemId INT NULL
    ,intItemId INT NULL
    ,intItemUOMId INT NULL
    ,strUOM NVARCHAR(40) COLLATE Latin1_General_CI_AS
    ,dblVoucherTotal DECIMAL(18,6) DEFAULT(0)
    ,dblVoucherQty DECIMAL(18,6) DEFAULT(0)
    ,dblReceiptTotal DECIMAL(18,6) DEFAULT(0)
    ,dblReceiptQty DECIMAL(18,6) DEFAULT(0)
    ,intLocationId INT NULL
    ,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
    ,ysnAllowVoucher BIT NULL
    ,intAccountId INT NULL
	,strAccountId NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
