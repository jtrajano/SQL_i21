IF EXISTS(select top 1 1 from sys.procedures where name = 'uspGRImportStorageType')
	DROP PROCEDURE uspGRImportStorageType
GO
CREATE PROCEDURE uspGRImportStorageType
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT
	AS
BEGIN
	--================================================
	--     IMPORT GRAIN STORAGE TYPES
	--================================================

	IF (@Checking = 1)
	BEGIN
			 SELECT @Total = COUNT(*)  FROM gactlmst  WHERE gactl_key = '1' AND gactl_stor_desc_1 != '            '
				AND NOT EXISTS (SELECT strStorageTypeCode FROM tblGRStorageType where strStorageTypeCode = '1')
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '1' AND gactl_stor_desc_2 != '            '
				AND NOT EXISTS (SELECT strStorageTypeCode FROM tblGRStorageType where strStorageTypeCode = '2')
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '1' AND gactl_stor_desc_3 != '            '
				AND NOT EXISTS (SELECT strStorageTypeCode FROM tblGRStorageType where strStorageTypeCode = '3')
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '1' AND gactl_stor_desc_4 != '            '
				AND NOT EXISTS (SELECT strStorageTypeCode FROM tblGRStorageType where strStorageTypeCode = '4')
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '1' AND gactl_stor_desc_5 != '            '
				AND NOT EXISTS (SELECT strStorageTypeCode FROM tblGRStorageType where strStorageTypeCode = '5')
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '1' AND gactl_stor_desc_6 != '            '
				AND NOT EXISTS (SELECT strStorageTypeCode FROM tblGRStorageType where strStorageTypeCode = '6')
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '1' AND gactl_stor_desc_7 != '            '
				AND NOT EXISTS (SELECT strStorageTypeCode FROM tblGRStorageType where strStorageTypeCode = '7')
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '1' AND gactl_stor_desc_8 != '            '
				AND NOT EXISTS (SELECT strStorageTypeCode FROM tblGRStorageType where strStorageTypeCode = '8')
			 
			 RETURN @Total
	END

	INSERT INTO [dbo].[tblGRStorageType] 
	(
		 strStorageTypeDescription
		, strStorageTypeCode
		, ysnReceiptedStorage
		, intConcurrencyId
		, strOwnedPhysicalStock
		, ysnDPOwnedType
		, ysnGrainBankType
		, ysnActive
		, ysnCustomerStorage
	)
	  (
		SELECT
		LTRIM(RTRIM(gactl_stor_desc_1)),
		1,
		CONVERT(bit, 0),
		1,
		CASE
		  WHEN gactl_include_stor_type = 1 THEN 'Company'
		  WHEN gactl_unpd_stor_type = 1 THEN 'Company'
		  ELSE 'Customer'
		END,

		CASE
		  WHEN gactl_unpd_stor_type = 1 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CASE
		  WHEN gactl_roll_stor_type = 1 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CONVERT(bit, 1),
		CONVERT(bit, 0)
	  FROM gactlmst
	  WHERE gactl_key = '1'
	  AND gactl_stor_desc_1 != '            '

	  UNION ALL

	  SELECT
		LTRIM(RTRIM(gactl_stor_desc_2)),
		2,
		CONVERT(bit, 0),
		1,
		CASE
		  WHEN gactl_include_stor_type = 2 THEN 'Company'
		  WHEN gactl_unpd_stor_type = 2 THEN 'Company'
		  ELSE 'Customer'
		END,
		CASE
		  WHEN gactl_unpd_stor_type = 2 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CASE
		  WHEN gactl_roll_stor_type = 2 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CONVERT(bit, 1),
		CONVERT(bit, 0)
	  FROM gactlmst
	  WHERE gactl_key = '1'
	  AND gactl_stor_desc_2 != '            '
	  UNION ALL
	  SELECT
		LTRIM(RTRIM(gactl_stor_desc_3)),
		3,
		CONVERT(bit, 0),
		1,
		CASE
		  WHEN gactl_include_stor_type = 3 THEN 'Company'
		  WHEN gactl_unpd_stor_type = 3 THEN 'Company'
		  ELSE 'Customer'
		END,
		CASE
		  WHEN gactl_unpd_stor_type = 3 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CASE
		  WHEN gactl_roll_stor_type = 3 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CONVERT(bit, 1),
		CONVERT(bit, 0)
	  FROM gactlmst
	  WHERE gactl_key = '1'
	  AND gactl_stor_desc_3 != '            '
	  UNION ALL
	  SELECT
		LTRIM(RTRIM(gactl_stor_desc_4)),
		4,
		CONVERT(bit, 0),
		1,
		CASE
		  WHEN gactl_include_stor_type = 4 THEN 'Company'
		  WHEN gactl_unpd_stor_type = 4 THEN 'Company'
		  ELSE 'Customer'
		END,
		CASE
		  WHEN gactl_unpd_stor_type = 4 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CASE
		  WHEN gactl_roll_stor_type = 4 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CONVERT(bit, 1),
		CONVERT(bit, 0)
	  FROM gactlmst
	  WHERE gactl_key = '1'
	  AND gactl_stor_desc_4 != '            '
	  UNION ALL
	  SELECT
		LTRIM(RTRIM(gactl_stor_desc_5)),
		5,
		CONVERT(bit, 0),
		1,
		CASE
		  WHEN gactl_include_stor_type = 5 THEN 'Company'
		  WHEN gactl_unpd_stor_type = 5 THEN 'Company'
		  ELSE 'Customer'
		END,
		CASE
		  WHEN gactl_unpd_stor_type = 5 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CASE
		  WHEN gactl_roll_stor_type = 5 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CONVERT(bit, 1),
		CONVERT(bit, 0)
	  FROM gactlmst
	  WHERE gactl_key = '1'
	  AND gactl_stor_desc_5 != '            '
	  UNION ALL
	  SELECT
		LTRIM(RTRIM(gactl_stor_desc_6)),
		6,
		CONVERT(bit, 1),
		1,
		CASE
		  WHEN gactl_include_stor_type = 6 THEN 'Company'
		  WHEN gactl_unpd_stor_type = 6 THEN 'Company'
		  ELSE 'Customer'
		END,
		CASE
		  WHEN gactl_unpd_stor_type = 6 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CASE
		  WHEN gactl_roll_stor_type = 6 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CONVERT(bit, 1),
		CONVERT(bit, 0)
	  FROM gactlmst
	  WHERE gactl_key = '1'
	  AND gactl_stor_desc_6 != '            '
	  UNION ALL
	  SELECT
		LTRIM(RTRIM(gactl_stor_desc_7)),
		7,
		CONVERT(bit, 1),
		1,
		CASE
		  WHEN gactl_include_stor_type = 7 THEN 'Company'
		  WHEN gactl_unpd_stor_type = 7 THEN 'Company'
		  ELSE 'Customer'
		END,
		CASE
		  WHEN gactl_unpd_stor_type = 7 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CASE
		  WHEN gactl_roll_stor_type = 7 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CONVERT(bit, 1),
		CONVERT(bit, 0)
	  FROM gactlmst
	  WHERE gactl_key = '1'
	  AND gactl_stor_desc_7 != '            '
	  UNION ALL
	  SELECT
		LTRIM(RTRIM(gactl_stor_desc_8)),
		8,
		CONVERT(bit, 1),
		1,
		CASE
		  WHEN gactl_include_stor_type = 8 THEN 'Company'
		  WHEN gactl_unpd_stor_type = 8 THEN 'Company'
		  ELSE 'Customer'
		END,
		CASE
		  WHEN gactl_unpd_stor_type = 8 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CASE
		  WHEN gactl_roll_stor_type = 8 THEN CONVERT(bit, 1)
		  ELSE CONVERT(bit, 0)
		END,
		CONVERT(bit, 1),
		CONVERT(bit, 0)
	  FROM gactlmst
	  WHERE gactl_key = '1'
	  AND gactl_stor_desc_8 != '            ')

	  ---1. If any Storage Type is assocaited with Only "S" Storage Ticket and not with any "P" Storage Ticket then make the Offsite as Checked.
	  IF EXISTS(SELECT Distinct gastr_stor_type FROM gastrmst WHERE  gastr_pur_sls_ind='S' AND gastr_stor_type NOT IN (SELECT Distinct gastr_stor_type FROM gastrmst WHERE  gastr_pur_sls_ind='P'))
	  BEGIN
		  UPDATE tblGRStorageType SET ysnCustomerStorage=1 WHERE strStorageTypeCode IN(SELECT Distinct gastr_stor_type FROM gastrmst WHERE  gastr_pur_sls_ind='S' AND gastr_stor_type NOT IN (SELECT Distinct gastr_stor_type FROM gastrmst WHERE  gastr_pur_sls_ind='P'))
	  END
		
END	



