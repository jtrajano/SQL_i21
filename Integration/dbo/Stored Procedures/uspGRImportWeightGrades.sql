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
			 SELECT @Total = COUNT(*) FROM gactlmst s
		UNPIVOT
		(
		  strWeightGradeDesc
		  FOR records IN (gact5_grd_wgt_desc_1, gact5_grd_wgt_desc_2, gact5_grd_wgt_desc_3, gact5_grd_wgt_desc_4, gact5_grd_wgt_desc_5, gact5_grd_wgt_desc_6, gact5_grd_wgt_desc_7, gact5_grd_wgt_desc_8, gact5_grd_wgt_desc_9)
		) x
		WHERE NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade
		WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = x.strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS)		
			 
			 RETURN @Total
	END

	INSERT INTO tblCTWeightGrade(intConcurrencyId,strWeightGradeDesc,strWhereFinalized,ysnActive,ysnWeight,ysnGrade)
	SELECT 1,y.strWeightGradeDesc,CASE WHEN t.strOriginDest = 'D' THEN 'Designation' ELSE 'Origin' END,1,1,1 
	FROM(
		SELECT  SUBSTRING(x.records,LEN(x.records),LEN(x.records)-1) id, x.strWeightGradeDesc
		FROM gactlmst s
		UNPIVOT
		(
		  strWeightGradeDesc
		  FOR records in (gact5_grd_wgt_desc_1, gact5_grd_wgt_desc_2, gact5_grd_wgt_desc_3, gact5_grd_wgt_desc_4, gact5_grd_wgt_desc_5, gact5_grd_wgt_desc_6, gact5_grd_wgt_desc_7, gact5_grd_wgt_desc_8, gact5_grd_wgt_desc_9)
		) x
	)y
	JOIN(
		SELECT  SUBSTRING(u.records,LEN(u.records),LEN(u.records)-1) id, u.strOriginDest
		FROM gactlmst s
		UNPIVOT
		(
		  strOriginDest
		  FOR records in (gact5_grd_wgt_type_1, gact5_grd_wgt_type_2, gact5_grd_wgt_type_3, gact5_grd_wgt_type_4, gact5_grd_wgt_type_5, gact5_grd_wgt_type_6, gact5_grd_wgt_type_7, gact5_grd_wgt_type_8, gact5_grd_wgt_type_9)
		) u
	) t ON t.id = y.id
	WHERE NOT EXISTS (SELECT strWeightGradeDesc from tblCTWeightGrade
	WHERE  strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS = y.strWeightGradeDesc COLLATE SQL_Latin1_General_CP1_CS_AS)	
	ORDER BY y.id ASC	
		
END	



