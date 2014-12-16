-- =============================================
-- Author:		Trajano, Jeffrey
-- Create date: 12-11-2014
-- Description:	Updates the GL account structure
-- =============================================
CREATE PROCEDURE [dbo].[uspGLUpdateAccountIDStructure] 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @cnt INT
	DECLARE @divider varchar(3)
	SELECT @cnt = COUNT(1) FROM tblGLAccountStructure WHERE strType <> 'Divider' 
	SELECT @divider = strMask FROM tblGLAccountStructure WHERE strType = 'Divider' 
	DECLARE @i INT = 0
	DECLARE @x INT = 0
	DECLARE @y INT = 0
	DECLARE @modifiedSorting BIT = 0
	DECLARE @transaction varchar(30)

	BEGIN TRY
			BEGIN TRANSACTION
			DECLARE cursor_accountId CURSOR FOR SELECT intAccountId FROM tblGLAccount 
			DECLARE @_accountId INT,@newAccountId varchar(30),@newAccountDesc varchar(150),@segmentId varchar(30),@segmentDesc varchar(100)
			OPEN cursor_accountId
			FETCH NEXT FROM cursor_accountId INTO @_accountId
			WHILE @@FETCH_STATUS = 0
			BEGIN
					SET @newAccountId = ''
					SET @newAccountDesc = ''
					SET @i = 1
					WHILE  @i <= @cnt
					BEGIN
						SELECT @y = intAccountStructureId FROM (SELECT ROW_NUMBER() OVER (ORDER BY intSort ASC) AS rownumber,intAccountStructureId FROM tblGLAccountStructure
						WHERE strType <> 'Divider') AS foo
						WHERE rownumber = @i
						
						SELECT @segmentId = x.strCode,@segmentDesc = x.strDescription FROM tblGLAccountSegment x
						LEFT JOIN tblGLAccountSegmentMapping p on
						x.intAccountSegmentId = p.intAccountSegmentId
						WHERE x.intAccountStructureId = @y
						and p.intAccountId = @_accountId
						
						SET @newAccountId += @segmentId + @divider
						SET @newAccountDesc += @segmentDesc + @divider
						SET @i = @i +1
					END
					SELECT @newAccountId = SUBSTRING(@newAccountId,0, LEN(@newAccountId)),
					@newAccountDesc = SUBSTRING(@newAccountDesc,0, LEN(@newAccountDesc))
					
				UPDATE tblGLAccount SET strAccountId = @newAccountId, strDescription =@newAccountDesc  WHERE intAccountId = @_accountId
				FETCH NEXT FROM cursor_accountId INTO @_accountId
			END
			CLOSE cursor_accountId
			DEALLOCATE cursor_accountId
			COMMIT TRANSACTION
			SELECT 'success'
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END
