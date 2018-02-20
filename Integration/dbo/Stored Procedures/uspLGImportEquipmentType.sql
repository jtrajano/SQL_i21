IF EXISTS(select top 1 1 from sys.procedures where name = 'uspLGImportEquipmentType')
	DROP PROCEDURE uspLGImportEquipmentType
GO
CREATE PROCEDURE uspLGImportEquipmentType
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT
	AS
BEGIN
	--================================================
	--     IMPORT GRAIN Weight/Grades
	--================================================

	IF (@Checking = 1)
	BEGIN
			 SELECT @Total = COUNT (*) FROM gactlmst s
		UNPIVOT
		(
		  strEquipmentDesc
		  FOR records IN (gac60_equip_desc_1, gac60_equip_desc_2, gac60_equip_desc_3, gac60_equip_desc_4, gac60_equip_desc_5, gac60_equip_desc_6, gac60_equip_desc_7, gac60_equip_desc_8, gac60_equip_desc_9,gac60_equip_desc_10)
		) x
		WHERE NOT EXISTS (SELECT strEquipmentType from tblLGEquipmentType
		WHERE  strEquipmentType COLLATE SQL_Latin1_General_CP1_CS_AS = x.strEquipmentDesc COLLATE SQL_Latin1_General_CP1_CS_AS)		
			 
			 RETURN @Total
	END

	INSERT INTO tblLGEquipmentType(intConcurrencyId,strEquipmentType)
	SELECT 1,x.strEquipmentType FROM gactlmst s
	UNPIVOT
	(
	  strEquipmentType
	  FOR records IN (gac60_equip_desc_1, gac60_equip_desc_2, gac60_equip_desc_3, gac60_equip_desc_4, gac60_equip_desc_5, gac60_equip_desc_6, gac60_equip_desc_7, gac60_equip_desc_8, gac60_equip_desc_9,gac60_equip_desc_10)
	) x
	WHERE NOT EXISTS (SELECT strEquipmentType from tblLGEquipmentType
	WHERE  strEquipmentType COLLATE SQL_Latin1_General_CP1_CS_AS = x.strEquipmentType COLLATE SQL_Latin1_General_CP1_CS_AS)	
	ORDER BY x.strEquipmentType ASC	
END	

GO