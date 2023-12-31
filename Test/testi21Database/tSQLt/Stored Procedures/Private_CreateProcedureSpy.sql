﻿---Build+
CREATE PROCEDURE tSQLt.Private_CreateProcedureSpy
    @ProcedureObjectId INT,
    @OriginalProcedureName NVARCHAR(MAX),
    @LogTableName NVARCHAR(MAX),
    @CommandToExecute NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @Cmd NVARCHAR(MAX);
    DECLARE @ProcParmList NVARCHAR(MAX),
            @TableColList NVARCHAR(MAX),
            @ProcParmTypeList NVARCHAR(MAX),
            @TableColTypeList NVARCHAR(MAX);
            
    DECLARE @Seperator CHAR(1),
            @ProcParmTypeListSeparater CHAR(1),
            @ParamName sysname,
            @TypeName sysname,
            @IsOutput BIT,
            @IsCursorRef BIT,
			@IsTableType BIT;
      
    SELECT @Seperator = '', @ProcParmTypeListSeparater = '', 
           @ProcParmList = '', @TableColList = '', @ProcParmTypeList = '', @TableColTypeList = '';
      
    DECLARE Parameters CURSOR FOR
	SELECT	p.name, t.TypeName, is_output, is_cursor_ref, tp.is_table_type
			FROM	sys.parameters p CROSS APPLY tSQLt.Private_GetFullTypeName(p.user_type_id,p.max_length,p.precision,p.scale,NULL) t										
					INNER JOIN sys.types tp
						ON p.user_type_id = tp.user_type_id
	WHERE object_id = @ProcedureObjectId;
    
    OPEN Parameters;
    
    FETCH NEXT FROM Parameters INTO @ParamName, @TypeName, @IsOutput, @IsCursorRef, @IsTableType;
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        IF @IsCursorRef = 0
        BEGIN
            SELECT @ProcParmList = @ProcParmList + @Seperator + 
										CASE WHEN @IsTableType = 1
											THEN '(SELECT * FROM ' + @ParamName + ' for xml path(''''))'
											ELSE 
											@ParamName
										END
									, 
                   @TableColList = @TableColList + @Seperator + '[' + STUFF(@ParamName,1,1,'') + ']', 
                   @ProcParmTypeList =	@ProcParmTypeList 
										+ @ProcParmTypeListSeparater 
										+ @ParamName 
										+ ' ' 
										+ @TypeName 
										+ CASE WHEN @IsTableType = 1 THEN ' READONLY ' ELSE ' = NULL ' END
										+ CASE WHEN @IsOutput = 1 THEN ' OUT'  ELSE '' END, 
                   @TableColTypeList = @TableColTypeList + ',[' + STUFF(@ParamName,1,1,'') + '] ' + 
                          CASE	WHEN @IsTableType = 1 -- If parameter is a user-defined table type.
									THEN 'xml'
								WHEN	@TypeName LIKE '%nchar%'
										OR @TypeName LIKE '%nvarchar%'							 
									THEN 'nvarchar(MAX)'
								WHEN @TypeName LIKE '%char%'
									THEN 'varchar(MAX)'
								ELSE @TypeName
                          END + ' NULL';

            SELECT @Seperator = ',';        
            SELECT @ProcParmTypeListSeparater = ',';
        END
        ELSE
        BEGIN
            SELECT @ProcParmTypeList = @ProcParmTypeListSeparater + @ParamName + ' CURSOR VARYING OUTPUT';
            SELECT @ProcParmTypeListSeparater = ',';
        END;
        
        FETCH NEXT FROM Parameters INTO @ParamName, @TypeName, @IsOutput, @IsCursorRef, @IsTableType;
    END;
    
    CLOSE Parameters;
    DEALLOCATE Parameters;
    
    DECLARE @InsertStmt NVARCHAR(MAX);
    SELECT @InsertStmt = 'INSERT INTO ' + @LogTableName + 
                         CASE WHEN @TableColList = '' THEN ' DEFAULT VALUES'
                              ELSE ' (' + @TableColList + ') SELECT ' + @ProcParmList
                         END + ';';
                         
    SELECT @Cmd = 'CREATE TABLE ' + @LogTableName + ' (_id_ int IDENTITY(1,1) PRIMARY KEY CLUSTERED ' + @TableColTypeList + ');';
    EXEC(@Cmd);

    SELECT @Cmd = 'CREATE PROCEDURE ' + @OriginalProcedureName + ' ' + @ProcParmTypeList + 
                  ' AS BEGIN ' + 
                     @InsertStmt + 
                     ISNULL(@CommandToExecute, '') + ';' +
                  ' END;';
    EXEC(@Cmd);

    RETURN 0;
END;
---Build-
