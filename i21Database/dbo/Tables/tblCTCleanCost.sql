CREATE TABLE [dbo].[tblCTCleanCost]
(
	[intCleanCostId] INT IDENTITY(1,1) NOT NULL, 
	[intEntityId] INT NOT NULL,
	[intContractDetailId] INT NOT NULL,
	[intShipmentId] INT,
	[intInventoryReceiptId] INT,
    [strReferenceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strCleanCostNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnFinalCost] BIT,
    [dblUncleanWeights] NUMERIC(18,6),
	[dblCleanWeights] NUMERIC(18,6),
	[dblLossInWeights] NUMERIC(18,6),
	[dblHumidity] NUMERIC(18,6),
	[dblCostRate] NUMERIC(18,6),
	[dblTotalAmount] NUMERIC(18,6),		
	[dblPriceInUnitUOM] NUMERIC(18,6),		
	[strRemark] NVARCHAR(256) COLLATE Latin1_General_CI_AS NULL, 
	[intConcurrencyId] INT NOT NULL,
	
	CONSTRAINT [PK_tblCTCleanCost_intCleanCostId] PRIMARY KEY CLUSTERED ([intCleanCostId] ASC),
	CONSTRAINT [UK_tblCTCleanCost_strReferenceNumber] UNIQUE ([strReferenceNumber]),
	CONSTRAINT [FK_tblCTCleanCost_tblEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEntity]([intEntityId]),
	CONSTRAINT [FK_tblCTCleanCost_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTCleanCost_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]),
	CONSTRAINT [FK_tblCTCleanCost_tblICInventoryReceipt_intInventoryReceiptId] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId])
)
