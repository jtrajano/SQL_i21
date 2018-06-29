CREATE TABLE [dbo].[tblICInventoryShipmentInspection]
(
		[intInventoryShipmentInspectionId] INT NOT NULL IDENTITY, 
		[intInventoryShipmentId] INT NOT NULL, 
		[intQAPropertyId] INT NOT NULL, 
		[ysnSelected] BIT NOT NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[strPropertyName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		[strComment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		CONSTRAINT [PK_tblICInventoryShipmentInspection] PRIMARY KEY ([intInventoryShipmentInspectionId]), 
		CONSTRAINT [FK_tblICInventoryShipmentInspection_tblICInventoryShipment] FOREIGN KEY ([intInventoryShipmentId]) REFERENCES [tblICInventoryShipment]([intInventoryShipmentId]) ON DELETE CASCADE
)
