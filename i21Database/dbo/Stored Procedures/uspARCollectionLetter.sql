CREATE PROCEDURE [dbo].[uspARCollectionLetter]  
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	IF(ISNULL(@xmlParam,'') ='')
	BEGIN
		SELECT *, blbMessage = CONVERT(VARBINARY(MAX),'') FROM vyuARCollectionOverdueReport		
	END
	ELSE
	BEGIN
		DECLARE @idoc						INT
				, @strCustomerIds			NVARCHAR(MAX)		
				, @intLetterId				INT
				, @strLetterId				NVARCHAR(10)  
				, @query					NVARCHAR(MAX)
				, @intEntityCustomerId		INT
				, @blb						VARBINARY(MAX)
				, @originalMsgInHTML		VARCHAR(MAX)
				, @newblb					VARBINARY(MAX)
				, @sqlString				NVARCHAR(MAX)				
				, @intInvoiceId				INT
				, @intLoopCount				INT	
		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlParam
		DECLARE @temp_params TABLE (
					  [fieldname]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
					, [condition]		NVARCHAR(20)   COLLATE Latin1_General_CI_AS    
					, [from]			NVARCHAR(MAX)
					, [to]				NVARCHAR(50) COLLATE Latin1_General_CI_AS
					, [join]			NVARCHAR(10) COLLATE Latin1_General_CI_AS
					, [begingroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
					, [endgroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
					, [datatype]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
					) 
		INSERT INTO 
			@temp_params
		SELECT *
		FROM OPENXML(@idoc, 'xmlparam/filters/filter',2)
		WITH (	
				  [fieldname]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
				, [condition]		NVARCHAR(20) COLLATE Latin1_General_CI_AS
				, [from]			NVARCHAR(MAX)
				, [to]				NVARCHAR(50) COLLATE Latin1_General_CI_AS
				, [join]			NVARCHAR(10) COLLATE Latin1_General_CI_AS
				, [begingroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
				, [endgroup]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
				, [datatype]		NVARCHAR(50) COLLATE Latin1_General_CI_AS
				)
		--SELECT 
		--	@strCustomerIds = [from]
		--FROM 
		--	@temp_params 
		--WHERE 
		--	[fieldname] = 'intEntityCustomerId' 

		SELECT 
			@strCustomerIds = '8|^|'
		FROM 
			@temp_params 
		WHERE 
			[fieldname] = 'intEntityCustomerId' 

		SET @strCustomerIds = REPLACE (@strCustomerIds, '|^|', ',')
		SET @strCustomerIds = REVERSE(SUBSTRING(REVERSE(@strCustomerIds),PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerIds)),LEN(@strCustomerIds) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@strCustomerIds)) - 1)	) )
	
		DECLARE @OriginalMsgInHTMLTable TABLE  (
			msgAsHTML VARCHAR(max)
		);

		SELECT 
			@intLetterId = [from]
		FROM 
			@temp_params 
		WHERE [fieldname] = 'intLetterId'
		
		SET @strLetterId = CAST(@intLetterId AS NVARCHAR(10))

		DECLARE @strMessage VARCHAR(MAX)
		SELECT
			@strMessage = CONVERT(VARCHAR(MAX), blbMessage)
		FROM
			tblSMLetter
		WHERE
			--intLetterId  = @strLetterId
			intLetterId  = 2

		DECLARE @SelectedPlaceHolderTable TABLE  (
			intPlaceHolderId	INT
			, strPlaceHolder	VARCHAR(max)
			, strSourceColumn	NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strPlaceHolderDescription	NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strSourceTable	NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, ysnTable			INT
		);
				
 		DECLARE @SelectedCustomer TABLE  (
			intEntityCustomerId		INT
		);

		IF OBJECT_ID('tempdb..#CustomerPlaceHolder') IS NOT NULL DROP TABLE #CustomerPlaceHolder	
		CREATE TABLE #CustomerPlaceHolder (
			[intPlaceHolderId] [int] NOT NULL,
			[strPlaceHolder]	VARCHAR(MAX),
			[intEntityCustomerId] [int] NOT NULL,
			[strValue] varchar(MAX)
		)

		INSERT INTO 
			@SelectedCustomer
		SELECT 
			* 
		FROM 
			fnGetRowsFromDelimitedValues(@strCustomerIds)

		SELECT 
			@blb = blbMessage 
		FROM 
			tblSMLetter 
		WHERE 
			intLetterId =@strLetterId

		INSERT INTO 
			@OriginalMsgInHTMLTable
		SELECT 
			CONVERT(VARCHAR(MAX), @blb) 

		SELECT 
			@originalMsgInHTML = msgAsHTML 
		FROM 
			@OriginalMsgInHTMLTable
 
		INSERT INTO @SelectedPlaceHolderTable
		(
			intPlaceHolderId
			, strPlaceHolder
			, strSourceColumn 
			, strPlaceHolderDescription
			, strSourceTable
			, ysnTable
		)			
		SELECT 
			intPlaceHolderId
			, strPlaceHolder
			, strSourceColumn
			,strPlaceHolderDescription
			, strSourceTable
			, ysnTable
		FROM 
			tblARLetterPlaceHolder 
		WHERE 
			CHARINDEX ( dbo.fnARRemoveWhiteSpace(strPlaceHolder), dbo.fnARRemoveWhiteSpace(@originalMsgInHTML) ) <> 0
			
		--SELECT * FROM @SelectedPlaceHolderTable
		WHILE EXISTS(SELECT NULL FROM @SelectedCustomer)
		BEGIN
			DECLARE @CustomerId INT
			SELECT TOP 1 @CustomerId = intEntityCustomerId FROM @SelectedCustomer ORDER BY intEntityCustomerId
						
			WHILE EXISTS(SELECT NULL FROM @SelectedPlaceHolderTable)
			BEGIN
				DECLARE @PlaceHolderId	INT
						,@PlaceHolder	VARCHAR(MAX)
						,@SourceColumn	VARCHAR(MAX)
						,@PlaceHolderDescription	VARCHAR(MAX)
						,@SourceTable	VARCHAR(MAX)
						,@Table			BIT
						,@PlaceHolderValue	VARCHAR(MAX)

				SELECT TOP 1 
					 @PlaceHolderId = [intPlaceHolderId]
					,@PlaceHolder	= [strPlaceHolder]
					,@SourceColumn	= [strSourceColumn]
					,@PlaceHolderDescription	= [strPlaceHolderDescription]
					,@SourceTable	= [strSourceTable]
					,@Table			= [ysnTable]
				FROM
					@SelectedPlaceHolderTable 
				ORDER BY [intPlaceHolderId]
				
				IF @Table = 0
				BEGIN
					DECLARE @PHQuery		VARCHAR(MAX)
							,@InsertQuery	VARCHAR(MAX)
				
					SET @PHQuery = 'SELECT TOP 1 ' + @SourceColumn + ' FROM ' + @SourceTable + ' WHERE [intEntityCustomerId] = ' + CAST(@CustomerId AS VARCHAR(200))
									
					SET @InsertQuery= '
										INSERT INTO	#CustomerPlaceHolder(
											[intPlaceHolderId],
											[strPlaceHolder],
											[intEntityCustomerId],
											[strValue]
										)
										SELECT
											[intPlaceHolderId]		= ' + CAST(@PlaceHolderId AS VARCHAR(200)) + '
											,[strPlaceHolder]		= ''' + @PlaceHolder + '''
											,[intEntityCustomerId]	= ' + CAST(@CustomerId AS VARCHAR(200)) + '
											,[strValue]				= '
										+ '(' + @PHQuery + ')'	
					EXEC sp_sqlexec @InsertQuery 			
				END
			ELSE
				BEGIN
					DECLARE @PHQueryTable		VARCHAR(MAX)
							,@InsertQueryTable	VARCHAR(MAX)
							,@HTMLTable			VARCHAR(MAX)											

					IF OBJECT_ID('tempdb..#TempTableColumnHeaders') IS NOT NULL DROP TABLE #TempTableColumnHeaders
					SELECT 
						RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
						,strValues 
					INTO 
						#TempTableColumnHeaders
					FROM 
						fnARGetRowsFromDelimitedValues(@PlaceHolderDescription)
											

					SET @HTMLTable = '<table  id="t01" style="width:100%" border="1"><tbody><tr>'

					DECLARE @ColumnCount	INT
							,@ColumnCounter INT
					SET @ColumnCounter = 1
					SELECT @ColumnCount = COUNT(RowId) FROM #TempTableColumnHeaders
				 
					WHILE (@ColumnCount >= @ColumnCounter)
					BEGIN
						DECLARE @Header VARCHAR(MAX)
						SELECT TOP 1
							@Header = strValues
						FROM
							#TempTableColumnHeaders
						WHERE
							RowId = @ColumnCounter
							
						SET @HTMLTable = @HTMLTable + '<th>' + @Header + '</th>'

						SET @ColumnCounter = @ColumnCounter + 1
					END

					SET @HTMLTable = @HTMLTable + '</tr>'

					IF OBJECT_ID('tempdb..#TempTableColumns') IS NOT NULL DROP TABLE #TempTableColumns
					SELECT 
						RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
						,strValues 
					INTO 
						#TempTableColumns
					FROM 
						fnARGetRowsFromDelimitedValues(@SourceColumn)

					DECLARE @Declaration	VARCHAR(MAX)
							,@Select		VARCHAR(MAX)
					SET @Declaration = ''
					SET @Select = ''
					SET @ColumnCounter = 1
					SELECT @ColumnCount = COUNT(RowId) FROM #TempTableColumns
					 
					WHILE (@ColumnCount >= @ColumnCounter)
					BEGIN
						DECLARE @Colunm VARCHAR(MAX)
						SELECT TOP 1
							@Colunm = strValues
						FROM
							#TempTableColumns
						WHERE
							RowId = @ColumnCounter
							
						SET @Declaration = @Declaration + '@' + @Colunm + ' AS NVARCHAR(200)'  + (CASE WHEN @ColumnCount = @ColumnCounter THEN '' ELSE ',' END)
						SET @Select = @Select + '@' + @Colunm + '= CONVERT(NVARCHAR(200), ' + @Colunm + ')'  + (CASE WHEN @ColumnCount = @ColumnCounter THEN '' ELSE ',' END)
						SET @ColumnCounter = @ColumnCounter + 1
					END
						
					IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL DROP TABLE #TempTable
					CREATE TABLE #TempTable(
						strTableBody VARCHAR(MAX)
					)

					INSERT INTO #TempTable
					SELECT @HTMLTable					 

					SET @PHQueryTable = '
					DECLARE @HTMLTableValue NVARCHAR(MAX)
					IF OBJECT_ID(''tempdb..#Records'') IS NOT NULL DROP TABLE #Records
					SELECT RowId = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), ' + @SourceColumn + ' INTO #Records
					FROM ' + @SourceTable + ' 
					WHERE [intEntityCustomerId] = ' + CAST(@CustomerId AS VARCHAR(200))
					+ ' 

					DECLARE @HTMLTableRows VARCHAR(MAX)
					SET @HTMLTableRows = ''''

					WHILE EXISTS(SELECT NULL FROM #Records)
					BEGIN
						DECLARE @RowId INT,
							' + @Declaration + '
						SELECT TOP 1
							@RowId = RowId,
							' + @Select + '
						FROM 
							#Records
						ORDER BY
							RowId		 

						SET @HTMLTableRows = @HTMLTableRows + ''<tr>''

						DECLARE @ColumnCounter1		INT
								,@ColumnCount1		INT
						SET @ColumnCounter1 = 1
						SELECT @ColumnCount1 = COUNT(RowId) FROM #TempTableColumns
				 
						WHILE (@ColumnCount1 >=  @ColumnCounter1)
						BEGIN
							DECLARE @Colunm1 VARCHAR(MAX)

							SELECT TOP 1
								@Colunm1 = strValues
							FROM
								#TempTableColumns
							WHERE
								RowId = @ColumnCounter1

							DECLARE @SetQuery VARCHAR(MAX)
						
							IF OBJECT_ID(''tempdb..#Field'') IS NOT NULL DROP TABLE #Field
							CREATE TABLE #Field(
							strField VARCHAR(MAX)
							)

							SET @SetQuery = ''INSERT INTO #Field SELECT '' + @Colunm1 +  '' FROM #Records WHERE RowId = '' + CAST(@RowId AS NVARCHAR(100)) 
						
							EXEC sp_sqlexec @SetQuery
							
							SET @HTMLTableRows = @HTMLTableRows + ''<td>'' + (SELECT TOP 1 strField FROM #Field) + ''</td>''

							SET @ColumnCounter1 = @ColumnCounter1 + 1
						END

						SET @HTMLTableRows = @HTMLTableRows + ''</tr>''
						
						DELETE FROM #Records WHERE RowId = @RowId
					END

					UPDATE #TempTable
					SET strTableBody = strTableBody + @HTMLTableRows + ''</tbody></table>'''

					EXEC sp_sqlexec @PHQueryTable 				 
									
					SET @InsertQueryTable= '
										INSERT INTO	#CustomerPlaceHolder(
											[intPlaceHolderId],
											[strPlaceHolder],
											[intEntityCustomerId],
											[strValue]
										)
										SELECT
											[intPlaceHolderId]		= ' + CAST(@PlaceHolderId AS VARCHAR(200)) + '
											,[strPlaceHolder]		= ''' + @PlaceHolder + '''
											,[intEntityCustomerId]	= ' + CAST(@CustomerId AS VARCHAR(200)) + '
											,[strValue]				= ''' +  (SELECT TOP 1 strTableBody FROM #TempTable) 	  + ''''
 

					EXEC sp_sqlexec @InsertQueryTable 	
				END
				
				DELETE FROM @SelectedPlaceHolderTable WHERE  [intPlaceHolderId] = @PlaceHolderId
			END

			DELETE FROM @SelectedCustomer WHERE intEntityCustomerId = @CustomerId 
		END


		DECLARE @PlaceHolderTable AS PlaceHolderTable

		INSERT INTO @PlaceHolderTable(
			intPlaceHolderId
			,strPlaceHolder
			,intEntityCustomerId
			,strPlaceValue
		)
		SELECT
			 intPlaceHolderId		= [intPlaceHolderId]
			,strPlaceHolder			= [strPlaceHolder]
			,intEntityCustomerId	= [intEntityCustomerId]
			,strPlaceValue			= [strValue]
		FROM
			#CustomerPlaceHolder

		INSERT INTO 
			@SelectedCustomer
		SELECT 
			* 
		FROM 
			fnGetRowsFromDelimitedValues(@strCustomerIds)
		SELECT
			SC.*
			,blbMessage = dbo.[fnARConvertLetterMessage](@strMessage, @PlaceHolderTable)
		FROM
			@SelectedCustomer SC
	END

END