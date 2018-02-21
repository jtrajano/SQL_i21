IF EXISTS(select top 1 1 from sys.procedures where name = 'uspGRImportWeightGrades')
	DROP PROCEDURE uspGRImportWeightGrades
GO
CREATE PROCEDURE uspGRImportWeightGrades
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
			 SELECT @Total = COUNT(*) FROM gactlmst WHERE gactl_key = '5' AND gact5_grd_wgt_desc_1 != '            '
				AND NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_1 COLLATE SQL_Latin1_General_CP1_CS_AS)
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '5' AND gact5_grd_wgt_desc_2 != '            '
				AND NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_2 COLLATE SQL_Latin1_General_CP1_CS_AS)
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '5' AND gact5_grd_wgt_desc_3 != '            '
				AND NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_3 COLLATE SQL_Latin1_General_CP1_CS_AS)
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '5' AND gact5_grd_wgt_desc_4 != '            '
				AND NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_4 COLLATE SQL_Latin1_General_CP1_CS_AS)
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '5' AND gact5_grd_wgt_desc_5 != '            '
				AND NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_5 COLLATE SQL_Latin1_General_CP1_CS_AS)
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '5' AND gact5_grd_wgt_desc_6 != '            '
				AND NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_6 COLLATE SQL_Latin1_General_CP1_CS_AS)
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '5' AND gact5_grd_wgt_desc_7 != '            '
				AND NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_7 COLLATE SQL_Latin1_General_CP1_CS_AS)
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '5' AND gact5_grd_wgt_desc_8 != '            '
				AND NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_8 COLLATE SQL_Latin1_General_CP1_CS_AS)
			 SELECT @Total = @Total + COUNT(*)  FROM gactlmst  WHERE gactl_key = '5' AND gact5_grd_wgt_desc_9 != '            '
				AND NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_9 COLLATE SQL_Latin1_General_CP1_CS_AS)		
			 
			 RETURN @Total
	END

	INSERT INTO tblCTWeightGrade (
	intConcurrencyId
	,strWeightGradeDesc
	,strWhereFinalized
	,ysnActive
	,ysnWeight
	,ysnGrade
	)
SELECT 1
	,gact5_grd_wgt_desc_1
	,CASE 
		WHEN gact5_grd_wgt_type_1 = 'D'
			THEN 'Designation'
		ELSE 'Origin'
		END
	,1
	,1
	,1
FROM gactlmst
WHERE gactl_key = '5'
	AND gact5_grd_wgt_desc_1 != '            '
	AND NOT EXISTS (SELECT strWeightGradeDesc FROM tblCTWeightGrade
		WHERE strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_1 COLLATE SQL_Latin1_General_CP1_CS_AS)

	INSERT INTO tblCTWeightGrade (
	intConcurrencyId
	,strWeightGradeDesc
	,strWhereFinalized
	,ysnActive
	,ysnWeight
	,ysnGrade
	)
SELECT 1
	,gact5_grd_wgt_desc_2
	,CASE 
		WHEN gact5_grd_wgt_type_2 = 'D'
			THEN 'Designation'
		ELSE 'Origin'
		END
	,1
	,1
	,1
FROM gactlmst
WHERE gactl_key = '5'
	AND gact5_grd_wgt_desc_2 != '            '
	AND NOT EXISTS (SELECT strWeightGradeDesc FROM tblCTWeightGrade
		WHERE strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_2 COLLATE SQL_Latin1_General_CP1_CS_AS)
		
	INSERT INTO tblCTWeightGrade (
	intConcurrencyId
	,strWeightGradeDesc
	,strWhereFinalized
	,ysnActive
	,ysnWeight
	,ysnGrade
	)
SELECT 1
	,gact5_grd_wgt_desc_3
	,CASE 
		WHEN gact5_grd_wgt_type_3 = 'D'
			THEN 'Designation'
		ELSE 'Origin'
		END
	,1
	,1
	,1
FROM gactlmst
WHERE gactl_key = '5'
	AND gact5_grd_wgt_desc_3 != '            '
	AND NOT EXISTS (SELECT strWeightGradeDesc FROM tblCTWeightGrade
		WHERE strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_3 COLLATE SQL_Latin1_General_CP1_CS_AS)

	INSERT INTO tblCTWeightGrade (
	intConcurrencyId
	,strWeightGradeDesc
	,strWhereFinalized
	,ysnActive
	,ysnWeight
	,ysnGrade
	)
SELECT 1
	,gact5_grd_wgt_desc_4
	,CASE 
		WHEN gact5_grd_wgt_type_4 = 'D'
			THEN 'Designation'
		ELSE 'Origin'
		END
	,1
	,1
	,1
FROM gactlmst
WHERE gactl_key = '5'
	AND gact5_grd_wgt_desc_4 != '            '
	AND NOT EXISTS (SELECT strWeightGradeDesc FROM tblCTWeightGrade
		WHERE strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_4 COLLATE SQL_Latin1_General_CP1_CS_AS)		
		
	INSERT INTO tblCTWeightGrade (
	intConcurrencyId
	,strWeightGradeDesc
	,strWhereFinalized
	,ysnActive
	,ysnWeight
	,ysnGrade
	)
SELECT 1
	,gact5_grd_wgt_desc_5
	,CASE 
		WHEN gact5_grd_wgt_type_5 = 'D'
			THEN 'Designation'
		ELSE 'Origin'
		END
	,1
	,1
	,1
FROM gactlmst
WHERE gactl_key = '5'
	AND gact5_grd_wgt_desc_5 != '            '
	AND NOT EXISTS (SELECT strWeightGradeDesc FROM tblCTWeightGrade
		WHERE strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_5 COLLATE SQL_Latin1_General_CP1_CS_AS)		

	INSERT INTO tblCTWeightGrade (
	intConcurrencyId
	,strWeightGradeDesc
	,strWhereFinalized
	,ysnActive
	,ysnWeight
	,ysnGrade
	)
SELECT 1
	,gact5_grd_wgt_desc_6
	,CASE 
		WHEN gact5_grd_wgt_type_6 = 'D'
			THEN 'Designation'
		ELSE 'Origin'
		END
	,1
	,1
	,1
FROM gactlmst
WHERE gactl_key = '5'
	AND gact5_grd_wgt_desc_6 != '            '
	AND NOT EXISTS (SELECT strWeightGradeDesc FROM tblCTWeightGrade
		WHERE strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_6 COLLATE SQL_Latin1_General_CP1_CS_AS)		

	INSERT INTO tblCTWeightGrade (
	intConcurrencyId
	,strWeightGradeDesc
	,strWhereFinalized
	,ysnActive
	,ysnWeight
	,ysnGrade
	)
SELECT 1
	,gact5_grd_wgt_desc_7
	,CASE 
		WHEN gact5_grd_wgt_type_7 = 'D'
			THEN 'Designation'
		ELSE 'Origin'
		END
	,1
	,1
	,1
FROM gactlmst
WHERE gactl_key = '5'
	AND gact5_grd_wgt_desc_7 != '            '
	AND NOT EXISTS (SELECT strWeightGradeDesc FROM tblCTWeightGrade
		WHERE strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_7 COLLATE SQL_Latin1_General_CP1_CS_AS)	

	INSERT INTO tblCTWeightGrade (
	intConcurrencyId
	,strWeightGradeDesc
	,strWhereFinalized
	,ysnActive
	,ysnWeight
	,ysnGrade
	)
SELECT 1
	,gact5_grd_wgt_desc_8
	,CASE 
		WHEN gact5_grd_wgt_type_8 = 'D'
			THEN 'Designation'
		ELSE 'Origin'
		END
	,1
	,1
	,1
FROM gactlmst
WHERE gactl_key = '5'
	AND gact5_grd_wgt_desc_8 != '            '
	AND NOT EXISTS (SELECT strWeightGradeDesc FROM tblCTWeightGrade
		WHERE strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_8 COLLATE SQL_Latin1_General_CP1_CS_AS)		
		
	INSERT INTO tblCTWeightGrade (
	intConcurrencyId
	,strWeightGradeDesc
	,strWhereFinalized
	,ysnActive
	,ysnWeight
	,ysnGrade
	)
SELECT 1
	,gact5_grd_wgt_desc_9
	,CASE 
		WHEN gact5_grd_wgt_type_9 = 'D'
			THEN 'Designation'
		ELSE 'Origin'
		END
	,1
	,1
	,1
FROM gactlmst
WHERE gactl_key = '5'
	AND gact5_grd_wgt_desc_9 != '            '
	AND NOT EXISTS (SELECT strWeightGradeDesc FROM tblCTWeightGrade
		WHERE strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = gact5_grd_wgt_desc_9 COLLATE SQL_Latin1_General_CP1_CS_AS)		
	
END	

GO

