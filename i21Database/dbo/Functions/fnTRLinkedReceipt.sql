CREATE FUNCTION [dbo].fnTRLinkedReceipt (
      @strReceiptLink  VARCHAR(50),
      @intLoadHeaderId int
)

RETURNS @Receipts TABLE (
    [intLoadReceiptId] INT NOT NULL,
	[intLoadHeaderId] INT NOT NULL,
	[strOrigin] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTerminalId] INT NULL,
	[intSupplyPointId] INT NULL,
    [intCompanyLocationId] INT NOT NULL,
	[strBillOfLading] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intItemId] INT NOT NULL,	
	[intContractDetailId] INT NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblUnitCost] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFreightRate] DECIMAL(18, 6) NULL DEFAULT 0,
	[dblPurSurcharge] DECIMAL(18, 6) NULL DEFAULT 0, 
	[intInventoryReceiptId] int NULL,
	[ysnFreightInPrice] BIT  DEFAULT ((0)) NOT NULL,
	[intTaxGroupId] int NULL,
	[intInventoryTransferId] int NULL,
	[strReceiptLine] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strFuelSupplier] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strSupplyPoint] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strReceiptCompanyLocation] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strReceiptNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strTransferNo] nvarchar(50) COLLATE Latin1_General_CI_AS NULL
)

AS
BEGIN
     insert into @Receipts 
     select TR.intLoadReceiptId,
            TR.intLoadHeaderId,
			TR.strOrigin,
			TR.intTerminalId,
			TR.intSupplyPointId,
			TR.intCompanyLocationId,
			TR.strBillOfLading,
			TR.intItemId,
			TR.intContractDetailId,
			TR.dblGross,
			TR.dblNet,
			TR.dblUnitCost,
			TR.dblFreightRate,
			TR.dblPurSurcharge,
			TR.intInventoryReceiptId,
			TR.ysnFreightInPrice,
			TR.intTaxGroupId,
			TR.intInventoryTransferId,
			TR.strReceiptLine,
			TR.intConcurrencyId,
			SP.strFuelSupplier,
			SP.strSupplyPoint,
			(select top 1 SM.strLocationName from dbo.tblSMCompanyLocation SM where SM.intCompanyLocationId = TR.intCompanyLocationId) as strReceiptCompanyLocation,
            (select top 1 yy.strReceiptNumber from dbo.tblTRLoadReceipt xx
                                 left join dbo.tblICInventoryReceipt yy on xx.intInventoryReceiptId = yy.intInventoryReceiptId where xx.intLoadReceiptId = TR.intLoadReceiptId ),
            (select top 1 yyy.strTransferNo from dbo.tblTRLoadReceipt xxx
                                 left join dbo.tblICInventoryTransfer yyy on xxx.intInventoryTransferId = yyy.intInventoryTransferId  where xxx.intLoadReceiptId = TR.intLoadReceiptId)
	from tblTRLoadReceipt TR 
         left join vyuTRSupplyPointView SP on SP.intSupplyPointId = TR.intSupplyPointId
     where TR.strReceiptLine in (select Item from fnTRSplit(@strReceiptLink,','))
	       and TR.intLoadHeaderId = @intLoadHeaderId

     RETURN

END 
GO
