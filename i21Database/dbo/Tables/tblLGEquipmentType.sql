CREATE TABLE [dbo].[tblLGEquipmentType]
(
 [intEquipmentTypeId] INT NOT NULL IDENTITY, 
 [intConcurrencyId] INT NOT NULL, 
 [strEquipmentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
 
 CONSTRAINT [PK_tblLGEquipmentType_intEquipmentTypeId] PRIMARY KEY ([intEquipmentTypeId])
)