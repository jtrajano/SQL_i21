--BEGIN TRAN
GO
PRINT 'START rebuilding data in tblGRStorageInventoryReceipt'
DECLARE @CS AS Id
DECLARE @SettleVoucherCreate AS SettleVoucherCreate
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_TYPE='BASE TABLE' 
           AND TABLE_NAME='tblGRStorageInventoryReceipt') 
BEGIN
    DROP TABLE tblGRStorageInventoryReceipt
    CREATE TABLE [dbo].[tblGRStorageInventoryReceipt]
    (
    	[intStorageInventoryReceipt] INT IDENTITY(1,1)
    	,[intCustomerStorageId] INT NOT NULL
    	,[intInventoryReceiptId] INT NOT NULL
    	,[intInventoryReceiptItemId] INT NOT NULL
    	,[intContractDetailId] INT NULL
    	,[dblUnits] DECIMAL(38,20) NOT NULL
    	,[dblShrinkage] DECIMAL(38,20)
    	,[dblNetUnits] DECIMAL(38,20)
    	,[intSettleStorageId] INT NULL
    	,[intTransferStorageReferenceId] INT NULL
    	,[dblTransactionUnits] DECIMAL(38,20) NULL
    	,[dblReceiptRunningUnits] DECIMAL(24,10) NULL
    	,[ysnUnposted] BIT DEFAULT 0
    	,CONSTRAINT [PK_tblGRStorageInventoryReceipt_intStorageInventoryReceipt] PRIMARY KEY ([intStorageInventoryReceipt])
    	,CONSTRAINT [FK_tblGRStorageInventoryReceipt_tblICInventoryReceipt_intInventoryReceiptId] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [dbo].[tblICInventoryReceipt] ([intInventoryReceiptId])
    	,CONSTRAINT [FK_tblGRStorageInventoryReceiptItem_tblICInventoryReceiptItem_intInventoryReceiptItemId] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [dbo].[tblICInventoryReceiptItem] ([intInventoryReceiptItemId])
    	,CONSTRAINT [FK_tblGRStorageInventoryReceiptItem_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId])
    )

	CREATE NONCLUSTERED INDEX [IX_tblGRStorageInventoryReceipt_intCustomerStorageId]
		ON [dbo].[tblGRStorageInventoryReceipt]([intCustomerStorageId] DESC)
		INCLUDE ([intInventoryReceiptId],[intInventoryReceiptItemId],[dblUnits]);

	CREATE NONCLUSTERED INDEX [IX_tblGRStorageInventoryReceipt_intInventoryReceiptItemId]
		ON [dbo].[tblGRStorageInventoryReceipt]([intInventoryReceiptItemId] DESC);
END

DECLARE @CustomerStorage AS TABLE
(
	intId INT IDENTITY(1,1)
	,intCustomerStorageId INT
	,dblOriginalBalance DECIMAL(38,20)
	,dblShrinkage DECIMAL(38,20)
	,ysnTransferStorage BIT
)

DECLARE @Transactions AS TABLE
(
	intId INT IDENTITY(1,1)
	,intCustomerStorageId INT
	,intTransactionId INT NULL --intSettleStorageId or intTransferStorageReferenceId	
	,strTransactionType NVARCHAR(30) COLLATE Latin1_General_CI_AS	
	,intContractDetailId INT NULL
	,dblUnits DECIMAL(38,20)
	,ysnDeleted BIT	
)

INSERT INTO @CustomerStorage
SELECT CS.intCustomerStorageId
	,CS.dblOriginalBalance
	,SH_Shrinkage.dblUnits
	,CS.ysnTransferStorage
FROM tblGRCustomerStorage CS
INNER JOIN tblGRStorageType ST	
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId 
		AND ST.ysnDPOwnedType = 1 --DP STORAGES ONLY
LEFT JOIN (
	SELECT DISTINCT intCustomerStorageId FROM tblGRStorageHistory WHERE intTransactionTypeId IN (4,3)
) SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
LEFT JOIN (
	SELECT DISTINCT intCustomerStorageId, dblUnits FROM tblGRStorageHistory WHERE strPaidDescription = 'Quantity Adjustment From Delivery Sheet'
) SH_Shrinkage ON SH_Shrinkage.intCustomerStorageId = CS.intCustomerStorageId

INSERT INTO @Transactions
SELECT DISTINCT CS.intCustomerStorageId
	,CASE WHEN SH.strType = 'Settlement' THEN SH.intSettleStorageId ELSE TSR.intTransferStorageReferenceId END
	,SH.strType
	,CASE WHEN SH.strType = 'Settlement' THEN CD.intContractDetailId ELSE NULL END
	,CASE WHEN SH.strType = 'Settlement' THEN SH.dblUnits ELSE TSR.dblUnitQty END
	,CAST(CASE WHEN SH.strType = 'Settlement' AND SH.intSettleStorageId IS NULL THEN 1 ELSE 0 END AS BIT)
FROM tblGRStorageHistory SH
INNER JOIN @CustomerStorage CS
	ON CS.intCustomerStorageId = SH.intCustomerStorageId
LEFT JOIN tblGRTransferStorageReference TSR
	ON TSR.intSourceCustomerStorageId = CS.intCustomerStorageId
		AND TSR.intTransferStorageId = SH.intTransferStorageId
LEFT JOIN tblGRStorageHistory SH2
	ON SH2.intCustomerStorageId = TSR.intToCustomerStorageId
		AND SH2.intTransferStorageId = SH.intTransferStorageId
		AND SH.strType = 'From Transfer'
LEFT JOIN tblCTContractDetail CD
	ON CD.intContractHeaderId = SH.intContractHeaderId
WHERE SH.strType IN ('Settlement','Transfer') --and SH.intCustomerStorageId = 2883
--ORDER BY SH.intCustomerStorageId,SH.intStorageHistoryId

--SELECT * FROM @Transactions
-- SELECT A.*,ysnTransferStorage,CS.strStorageTicketNumber FROM @Transactions A INNER JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = A.intCustomerStorageId

DECLARE @intId INT
DECLARE @strTransactionType NVARCHAR(30)
DECLARE @intTransactionId INT
DECLARE @intContractDetailId INT
DECLARE @intCustomerStorageId INT
DECLARE @intScope INT
WHILE EXISTS(SELECT TOP 1 1 FROM @Transactions)
BEGIN
	DELETE FROM @SettleVoucherCreate
	SET @intId = NULL
	SET @intTransactionId = NULL
	SET @intCustomerStorageId = NULL
	SET @intScope = NULL

	SELECT TOP 1 @intId = intId
		,@strTransactionType = strTransactionType
		,@intTransactionId = intTransactionId
		,@intCustomerStorageId = intCustomerStorageId
	FROM @Transactions ORDER BY intId

	 IF(@strTransactionType = 'Settlement')
	 BEGIN
		IF @intTransactionId IS NOT NULL
		BEGIN
			INSERT INTO @SettleVoucherCreate
			(
				intItemType
				,intContractDetailId
				,dblUnits
			)
			SELECT 1, intContractDetailId, dblUnits FROM @Transactions WHERE intId = @intId

			EXEC uspGRStorageInventoryReceipt @SettleVoucherCreate,@intCustomerStorageId,@intTransactionId,NULL,0
		END		
	 END
	 ELSE
	 BEGIN
		EXEC uspGRStorageInventoryReceipt @SettleVoucherCreate,NULL,NULL,@intTransactionId,0
	 END
	 
	 DELETE FROM @Transactions WHERE intId = @intId

	 --SET @intScope = SCOPE_IDENTITY()
	 --IF (SELECT intSettleStorageId FROM tblGRStorageInventoryReceipt WHERE intStorageInventoryReceipt  = @intScope) IS NULL
		--AND (SELECT intTransferStorageReferenceId FROM tblGRStorageInventoryReceipt WHERE intStorageInventoryReceipt  = @intScope) IS NULL
	 --BEGIN		
		--UPDATE tblGRStorageInventoryReceipt SET ysnUnposted = 1 WHERE intStorageInventoryReceipt = @intScope
		--select * from tblGRStorageInventoryReceipt where intStorageInventoryReceipt = @intScope
	 --END
END

--SELECT * FROM tblGRStorageInventoryReceipt

--COMMIT TRAN

--SELECT * FROM tblGRStorageHistory WHERE intCustomerStorageId = 2883
--SELECT * FROM tblGRCustomerStorage WHERE intCustomerStorageId = 2883

--select * from tblGRTransferStorageReference where intTransferStorageReferenceId =499
--SELECT * FROM tblGRStorageHistory WHERE intTransferStorageI/d = 524
PRINT 'END rebuilding data in tblGRStorageInventoryReceipt'
GO