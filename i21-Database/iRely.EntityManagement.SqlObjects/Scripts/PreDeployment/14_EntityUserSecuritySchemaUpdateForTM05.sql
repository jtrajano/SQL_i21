
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
print 'updating tblTMDispatch '

	set @maxevent = 0
	set @minatureevent = 0
	set @cmdevent = ''
	set @CurStatementTM1 = ''
	set @FinalDestinationCommand = ''
	--delete from @FinalDestination

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblTMDispatch' and [COLUMN_NAME] = 'intUserID')
	BEGIN

		set @cmdevent = 'select @maxevent = max(intDispatchID) from tblTMDispatch'
		exec sp_executesql @cmdevent,N'@maxevent int output', @maxevent OUTPUT
		
		INSERT INTO @AlterTables
		SELECT
			'ALTER TABLE ' + R.TABLE_NAME + ' DROP CONSTRAINT [' + R.CONSTRAINT_NAME + ']'  Stement
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
		INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
			ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
			AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
			AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
			ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
			AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
			AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
		WHERE U.TABLE_NAME = 'tblTMDispatch' 

		

		
		set @minatureevent = 0
		while(@minatureevent < @maxevent)
		begin
			set @cmdevent = '				
			IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblTMDispatch'' and [COLUMN_NAME] = ''intUserID'')
			BEGIN		
						
				DECLARE @minId int				
				declare @COUNTS			INT
				declare @cmdevent			nvarchar(max)
		
				SET @COUNTS = ' + cast(@eventcount as nvarchar)+ '
				select @minId = ' + cast(@minatureevent as nvarchar)+ '

				SET @cmdevent = ''UPDATE tblTMDispatch SET intUserID = A.intEntityUserSecurityId
					FROM tblSMUserSecurity A
					WHERE tblTMDispatch.intUserID = A.intUserSecurityIdOld
						AND A.intUserSecurityIdOld IS NOT NULL 
						AND intDispatchID > '' + cast(@minId as nvarchar) + '' and intDispatchID <= '' + cast((@minId + @COUNTS ) as nvarchar)
		
				--PRINT @minId
				SET @FinalDestinationCommand =  @cmdevent				

				SET @minId  = @minId + @COUNTS		
				
			END
			'
			set @FinalDestinationCommand = ''
			exec sp_executesql @cmdevent,N'@FinalDestinationCommand nvarchar(max) output', @FinalDestinationCommand OUTPUT
			--exec(@cmdevent)
			if @FinalDestinationCommand <> ''
			begin
				insert into @FinalDestination
				select @FinalDestinationCommand
			end		
				
			set @minatureevent = @minatureevent + @eventcount
		end		

		--WHILE EXISTS(SELECT TOP 1 1 FROM @FinalDestination)
		--BEGIN
		--	SET @CurStatementTM1 = ''
		--	SELECT TOP 1 @CurStatementTM1 = cmd  FROM @FinalDestination			
			
		--	EXEC (@CurStatementTM1)		

		--	DELETE FROM @FinalDestination WHERE cmd = @CurStatementTM1
		--END
		
	END	

END


	
