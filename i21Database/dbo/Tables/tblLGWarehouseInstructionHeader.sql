CREATE TABLE [dbo].[tblLGWarehouseInstructionHeader]
(
	[intWarehouseInstructionHeaderId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[dtmTransDate] DATETIME NOT NULL,
    [intCompanyLocationId] INT NOT NULL, 
	[intCommodityId] INT NOT NULL, 
	[intSourceType] INT NOT NULL,
	[intShipmentId] INT NULL,
	[intInventoryShipmentId] INT NULL,
	[intCompanyLocationSubLocationId] INT NOT NULL,
	[intWarehouseRateMatrixHeaderId] INT NOT NULL,
    [intUserSecurityId] INT NOT NULL,
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL, 
	[intBillId]            INT NULL,

    CONSTRAINT [PK_tblLGWarehouseInstructionHeader_intWarehouseInstructionHeaderId] PRIMARY KEY ([intWarehouseInstructionHeaderId]), 
    CONSTRAINT [FK_tblLGWarehouseInstructionHeader_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [tblLGShipment]([intShipmentId]),
    CONSTRAINT [FK_tblLGWarehouseInstructionHeader_tblICInventoryShipment_intInventoryShipmentId] FOREIGN KEY ([intInventoryShipmentId]) REFERENCES [tblICInventoryShipment]([intInventoryShipmentId]),	
    CONSTRAINT [FK_tblLGWarehouseInstructionHeader_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
    CONSTRAINT [FK_tblLGWarehouseInstructionHeader_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]),
	CONSTRAINT [FK_tblLGWarehouseInstructionHeader_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	-- THIS IS THE ORIGINAL BEFORE THE MERGE PLEASE CHECK
--    CONSTRAINT [FK_tblLGWarehouseInstructionHeader_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]),
    CONSTRAINT [FK_tblLGWarehouseInstructionHeader_tblLGWarehouseRateMatrixHeader_intWarehouseRateMatrixHeaderId] FOREIGN KEY ([intWarehouseRateMatrixHeaderId]) REFERENCES [tblLGWarehouseRateMatrixHeader]([intWarehouseRateMatrixHeaderId]),
    CONSTRAINT [FK_tblLGWarehouseInstructionHeader_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]),
	CONSTRAINT [FK_tblLGWarehouseInstructionHeader_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [tblAPBill]([intBillId])
)
