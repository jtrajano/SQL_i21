GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glragmst]') AND type IN (N'U')) 
BEGIN
EXEC('IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLImportOriginReallocation'' and type = ''P'')
			DROP PROCEDURE [dbo].[uspGLImportOriginReallocation];')

EXEC('CREATE PROCEDURE [dbo].[uspGLImportOriginReallocation]
AS
	BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @sql VARCHAR (max)
		DECLARE @jump INT
		DECLARE @intId INT
				
		DELETE FROM tblGLReallocationTemp
		INSERT tblGLAccountReallocation (strName,strDescription,intConcurrencyId)
			SELECT glrag_grid_id,glrag_desc,1 FROM glragmst

		SELECT @jump=1
			WHILE @jump<50 
				BEGIN
					SELECT @sql= ''insert into tblGLReallocationTemp(intAccountReallocationId,intPrimary,intSecondary,decPercentage,intAccountId,strAccountId) select tblGLAccountReallocation.intAccountReallocationId,glrag_acct1_8_''+rtrim(convert(varchar(10),@jump))+'',glrag_acct9_16_''+rtrim(convert(varchar(10),@jump))+'',glrag_pct_''+rtrim(convert(varchar(10),@jump))+'',convert(int,0) as intAccountId,convert(varchar(20),''+''''''''+''''''''+'') as accountstring from glragmst inner join tblGLAccountReallocation on (strName=glrag_grid_id collate SQL_Latin1_General_CP1_CS_AS)''
					EXEC (@sql)
 					SELECT @jump=@jump+1
				END

		DELETE FROM tblGLReallocationTemp WHERE decPercentage =0
		
		--check to see if things are equal to 100
		--SELECT intAccountReallocationId,SUM(decPercentage) FROM tblGLReallocationTemp GROUP BY intAccountReallocationId ORDER BY intAccountReallocationId
		DECLARE @primary int
		DECLARE @seg int
		DECLARE @sql2 varchar(max)
		SELECT @primary=intLength FROM tblGLAccountStructure WHERE strType=''Primary''
		SELECT @seg=intLength FROM tblGLAccountStructure WHERE strType=''Segment''

		SELECT @sql2=''update tblGLReallocationTemp set strAccountId=convert(varchar(''+rtrim(convert(VARCHAR(10),@primary))+''),intPrimary)+''+''''''''+''-''+''''''''+''+convert(varchar(''+rtrim(convert(varchar(10),@seg))+''),Right(''+''''''''+''0000000000''+''''''''+''+rtrim(ltrim(intSecondary)),''+CONVERT(VARCHAR(10),@seg)+''))''
		EXEC (@sql2)            
						
		UPDATE R SET R.intAccountId=A.intAccountId FROM tblGLReallocationTemp R
			INNER JOIN tblGLAccount A on R.strAccountId=A.strAccountId COLLATE SQL_Latin1_General_CP1_CS_AS
					
		INSERT tblGLAccountReallocationDetail (intAccountReallocationId,intAccountId,dblPercentage,intConcurrencyId)
			SELECT intAccountReallocationId,T.intAccountId,decPercentage,1 FROM tblGLReallocationTemp T inner join
				tblGLAccount A on T.intAccountId = A.intAccountId ORDER BY intAccountReallocationId
		COMMIT TRANSACTION
		SELECT ''Success''
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE()
	END CATCH')
END



