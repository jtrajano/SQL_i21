GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMSyncPaymentMethod')
	DROP PROCEDURE uspSMSyncPaymentMethod
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN

	EXEC('CREATE PROCEDURE uspSMSyncPaymentMethod
				@ToOrigin			bit				= 0
				,@PaymentCodes		nvarchar(MAX)	= ''all''
				,@AddedCount		int				= 0 OUTPUT
				,@UpdatedCount		int				= 0 OUTPUT
			AS
			BEGIN

			DECLARE @RecordsToProcess table(strPaymentMethod nvarchar(12), strGLAccount decimal(16,8), strPrintOption nvarchar(50), strPaymentMethodCode nvarchar(3))
			DECLARE @RecordsToAdd table(strPaymentMethodCode varchar(3), strPaymentMethod varchar(30))
			DECLARE @RecordsToUpdate table(strPaymentMethodCode varchar(3), strPaymentMethod varchar(30))

			DELETE FROM @RecordsToProcess
			DELETE FROM @RecordsToAdd
			DELETE FROM @RecordsToUpdate

			DECLARE @PrintOptionY nvarchar(50), @PrintOptionN nvarchar(50), @PrintOptionC nvarchar(50)

			SELECT
				@PrintOptionY	= ''Print on Deposit Slip''
				,@PrintOptionN	= ''Don''''t Print on Deposit Slip''
				,@PrintOptionC	= ''Cash Summary on Deposit Slip''


			IF(@ToOrigin = 0)
				BEGIN
					INSERT INTO @RecordsToProcess
					SELECT
						[agct2_pay_desc_1]			AS [strPaymentMethod]
						,[agct2_pay_gl_acct_1]		AS [strGLAccount]
						,(CASE UPPER([agct2_pay_ind_1])
							WHEN ''Y'' THEN @PrintOptionY
							WHEN ''N'' THEN @PrintOptionN
							WHEN ''C'' THEN @PrintOptionC
							END)					AS [strPrintOption]
						,''001''						AS [strPaymentMethodCode]
					FROM
						agctlmst
					WHERE agct2_pay_desc_1 is not null	

					UNION

					SELECT
						[agct2_pay_desc_2]			AS [strPaymentMethod]
						,[agct2_pay_gl_acct_2]		AS [strGLAccount]
						,(CASE UPPER([agct2_pay_ind_2])
							WHEN ''Y'' THEN @PrintOptionY
							WHEN ''N'' THEN @PrintOptionN
							WHEN ''C'' THEN @PrintOptionC
							END)					AS [strPrintOption]
						,''002''						AS [strPaymentMethodCode]
					FROM
						agctlmst
					WHERE agct2_pay_desc_2 is not null	


					UNION

					SELECT
						[agct2_pay_desc_3]			AS [strPaymentMethod]
						,[agct2_pay_gl_acct_3]		AS [strGLAccount]
						,(CASE UPPER([agct2_pay_ind_3])
							WHEN ''Y'' THEN @PrintOptionY
							WHEN ''N'' THEN @PrintOptionN
							WHEN ''C'' THEN @PrintOptionC
							END)					AS [strPrintOption]
						,''003''						AS [strPaymentMethodCode]
					FROM
						agctlmst
					WHERE agct2_pay_desc_3 is not null	

					UNION

					SELECT
						[agct2_pay_desc_4]			AS [strPaymentMethod]
						,[agct2_pay_gl_acct_4]		AS [strGLAccount]
						,(CASE UPPER([agct2_pay_ind_4])
							WHEN ''Y'' THEN @PrintOptionY
							WHEN ''N'' THEN @PrintOptionN
							WHEN ''C'' THEN @PrintOptionC
							END)					AS [strPrintOption]
						,''004''						AS [strPaymentMethodCode]
					FROM
						agctlmst
					WHERE agct2_pay_desc_4 is not null	

					UNION

					SELECT
						[agct2_pay_desc_5]			AS [strPaymentMethod]
						,[agct2_pay_gl_acct_5]		AS [strGLAccount]
						,(CASE UPPER([agct2_pay_ind_5])
							WHEN ''Y'' THEN @PrintOptionY
							WHEN ''N'' THEN @PrintOptionN
							WHEN ''C'' THEN @PrintOptionC
							END)					AS [strPrintOption]
						,''005''						AS [strPaymentMethodCode]
					FROM
						agctlmst
					WHERE agct2_pay_desc_5 is not null	

					UNION

					SELECT
						[agct2_pay_desc_6]			AS [strPaymentMethod]
						,[agct2_pay_gl_acct_6]		AS [strGLAccount]
						,(CASE UPPER([agct2_pay_ind_6])
							WHEN ''Y'' THEN @PrintOptionY
							WHEN ''N'' THEN @PrintOptionN
							WHEN ''C'' THEN @PrintOptionC
							END)					AS [strPrintOption]
						,''006''						AS [strPaymentMethodCode]
					FROM
						agctlmst
					WHERE agct2_pay_desc_6 is not null	

					UNION

					SELECT
						[agct2_pay_desc_7]			AS [strPaymentMethod]
						,[agct2_pay_gl_acct_7]		AS [strGLAccount]
						,(CASE UPPER([agct2_pay_ind_7])
							WHEN ''Y'' THEN @PrintOptionY
							WHEN ''N'' THEN @PrintOptionN
							WHEN ''C'' THEN @PrintOptionC
							END)					AS [strPrintOption]
						,''007''						AS [strPaymentMethodCode]
					FROM
						agctlmst
					WHERE agct2_pay_desc_7 is not null	

					UNION

					SELECT
						[agct2_pay_desc_8]			AS [strPaymentMethod]
						,[agct2_pay_gl_acct_8]		AS [strGLAccount]
						,(CASE UPPER([agct2_pay_ind_8])
							WHEN ''Y'' THEN @PrintOptionY
							WHEN ''N'' THEN @PrintOptionN
							WHEN ''C'' THEN @PrintOptionC
							END)					AS [strPrintOption]
						,''008''						AS [strPaymentMethodCode]
					FROM
						agctlmst
					WHERE agct2_pay_desc_8 is not null	

					UNION

					SELECT
						[agct2_pay_desc_9]			AS [strPaymentMethod]
						,[agct2_pay_gl_acct_9]		AS [strGLAccount]
						,(CASE UPPER([agct2_pay_ind_9])
							WHEN ''Y'' THEN @PrintOptionY
							WHEN ''N'' THEN @PrintOptionN
							WHEN ''C'' THEN @PrintOptionC
							END)					AS [strPrintOption]
						,''009''						AS [strPaymentMethodCode]
					FROM
						agctlmst
					WHERE agct2_pay_desc_9 is not null
				END


			IF(LOWER(@PaymentCodes) = ''all'')
				BEGIN
					IF (@ToOrigin = 1)
						INSERT INTO @RecordsToProcess(strPaymentMethodCode, strPaymentMethod)
						SELECT [strPaymentMethodCode], [strPaymentMethod]
						FROM tblSMPaymentMethod										
				END
			ELSE
				BEGIN
					IF (@ToOrigin = 1)			
						INSERT INTO @RecordsToProcess(strPaymentMethodCode, strPaymentMethod)
						SELECT PM.[strPaymentMethodCode], PM.[strPaymentMethod]
						FROM fnGetRowsFromDelimitedValues(@PaymentCodes) T
						INNER JOIN tblSMPaymentMethod PM ON T.[intID] = PM.[strPaymentMethodCode]
					ELSE
						DELETE FROM @RecordsToProcess
						WHERE
							strPaymentMethodCode NOT IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@PaymentCodes))
				END		
				
			IF (@ToOrigin = 1)
				SET @AddedCount = 0
			ELSE
				INSERT INTO @RecordsToAdd
				SELECT P.[strPaymentMethodCode], P.[strPaymentMethod]
				FROM @RecordsToProcess P
				LEFT OUTER JOIN tblSMPaymentMethod PM ON P.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
				WHERE PM.[strPaymentMethodCode] IS NULL		
				
				
				
				
			INSERT INTO @RecordsToUpdate
			SELECT P.[strPaymentMethodCode], P.[strPaymentMethod]
			FROM @RecordsToProcess P
			LEFT JOIN @RecordsToAdd A ON P.[strPaymentMethodCode] = A.[strPaymentMethodCode]
			WHERE A.[strPaymentMethodCode] IS NULL					
				

			IF(@ToOrigin = 1)
				BEGIN	
					DECLARE @UpdateCountTemp int
					UPDATE agctlmst
					SET
						[agct2_pay_desc_1] = SUBSTRING(RTRIM(LTRIM(PM.[strPaymentMethod])),0,29)
						,[agct2_pay_ind_1] = 
							(CASE PM.[strPrintOption]
								WHEN @PrintOptionY THEN	''Y'' 
								WHEN @PrintOptionN THEN ''N''
								WHEN @PrintOptionC THEN ''C''
							END)
						,[agct2_pay_gl_acct_1] = GL.strExternalId
					FROM
						@RecordsToUpdate U
					INNER JOIN
						tblSMPaymentMethod PM
							ON U.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON PM.intAccountId = GL.inti21Id 				 
					WHERE
						agct2_pay_desc_1 is not null
						AND U.[strPaymentMethodCode] = ''001'' 
						
					SET @UpdateCountTemp = @UpdateCountTemp + @@ROWCOUNT
						
					UPDATE agctlmst
					SET
						[agct2_pay_desc_2] = SUBSTRING(RTRIM(LTRIM(PM.[strPaymentMethod])),0,29)
						,[agct2_pay_ind_2] = 
							(CASE PM.[strPrintOption]
								WHEN @PrintOptionY THEN	''Y'' 
								WHEN @PrintOptionN THEN ''N''
								WHEN @PrintOptionC THEN ''C''
							END)
						,[agct2_pay_gl_acct_2] = GL.strExternalId
					FROM
						@RecordsToUpdate U
					INNER JOIN
						tblSMPaymentMethod PM
							ON U.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON PM.intAccountId = GL.inti21Id 				 
					WHERE
						agct2_pay_desc_2 is not null
						AND U.[strPaymentMethodCode] = ''002'' 
						
					SET @UpdateCountTemp = @UpdateCountTemp + @@ROWCOUNT		
						
					UPDATE agctlmst
					SET
						[agct2_pay_desc_3] = SUBSTRING(RTRIM(LTRIM(PM.[strPaymentMethod])),0,29)
						,[agct2_pay_ind_3] = 
							(CASE PM.[strPrintOption]
								WHEN @PrintOptionY THEN	''Y'' 
								WHEN @PrintOptionN THEN ''N''
								WHEN @PrintOptionC THEN ''C''
							END)
						,[agct2_pay_gl_acct_3] = GL.strExternalId
					FROM
						@RecordsToUpdate U
					INNER JOIN
						tblSMPaymentMethod PM
							ON U.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON PM.intAccountId = GL.inti21Id 				 
					WHERE
						agct2_pay_desc_3 is not null
						AND U.[strPaymentMethodCode] = ''003'' 	
						
					SET @UpdateCountTemp = @UpdateCountTemp + @@ROWCOUNT	
					
					UPDATE agctlmst
					SET
						[agct2_pay_desc_4] = SUBSTRING(RTRIM(LTRIM(PM.[strPaymentMethod])),0,29)
						,[agct2_pay_ind_4] = 
							(CASE PM.[strPrintOption]
								WHEN @PrintOptionY THEN	''Y'' 
								WHEN @PrintOptionN THEN ''N''
								WHEN @PrintOptionC THEN ''C''
							END)
						,[agct2_pay_gl_acct_4] = GL.strExternalId
					FROM
						@RecordsToUpdate U
					INNER JOIN
						tblSMPaymentMethod PM
							ON U.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON PM.intAccountId = GL.inti21Id 				 
					WHERE
						agct2_pay_desc_4 is not null
						AND U.[strPaymentMethodCode] = ''004'' 	
						
					SET @UpdateCountTemp = @UpdateCountTemp + @@ROWCOUNT	
					
					UPDATE agctlmst
					SET
						[agct2_pay_desc_5] = SUBSTRING(RTRIM(LTRIM(PM.[strPaymentMethod])),0,29)
						,[agct2_pay_ind_5] = 
							(CASE PM.[strPrintOption]
								WHEN @PrintOptionY THEN	''Y'' 
								WHEN @PrintOptionN THEN ''N''
								WHEN @PrintOptionC THEN ''C''
							END)
						,[agct2_pay_gl_acct_5] = GL.strExternalId
					FROM
						@RecordsToUpdate U
					INNER JOIN
						tblSMPaymentMethod PM
							ON U.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON PM.intAccountId = GL.inti21Id 				 
					WHERE
						agct2_pay_desc_5 is not null
						AND U.[strPaymentMethodCode] = ''005'' 	
						
					SET @UpdateCountTemp = @UpdateCountTemp + @@ROWCOUNT	
					
					UPDATE agctlmst
					SET
						[agct2_pay_desc_6] = SUBSTRING(RTRIM(LTRIM(PM.[strPaymentMethod])),0,29)
						,[agct2_pay_ind_6] = 
							(CASE PM.[strPrintOption]
								WHEN @PrintOptionY THEN	''Y'' 
								WHEN @PrintOptionN THEN ''N''
								WHEN @PrintOptionC THEN ''C''
							END)
						,[agct2_pay_gl_acct_6] = GL.strExternalId
					FROM
						@RecordsToUpdate U
					INNER JOIN
						tblSMPaymentMethod PM
							ON U.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON PM.intAccountId = GL.inti21Id 				 
					WHERE
						agct2_pay_desc_6 is not null
						AND U.[strPaymentMethodCode] = ''006'' 	
						
					SET @UpdateCountTemp = @UpdateCountTemp + @@ROWCOUNT			
					
					UPDATE agctlmst
					SET
						[agct2_pay_desc_7] = SUBSTRING(RTRIM(LTRIM(PM.[strPaymentMethod])),0,29)
						,[agct2_pay_ind_7] = 
							(CASE PM.[strPrintOption]
								WHEN @PrintOptionY THEN	''Y'' 
								WHEN @PrintOptionN THEN ''N''
								WHEN @PrintOptionC THEN ''C''
							END)
						,[agct2_pay_gl_acct_7] = GL.strExternalId
					FROM
						@RecordsToUpdate U
					INNER JOIN
						tblSMPaymentMethod PM
							ON U.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON PM.intAccountId = GL.inti21Id 				 
					WHERE
						agct2_pay_desc_7 is not null
						AND U.[strPaymentMethodCode] = ''007'' 	
						
					SET @UpdateCountTemp = @UpdateCountTemp + @@ROWCOUNT	
					
					UPDATE agctlmst
					SET
						[agct2_pay_desc_8] = SUBSTRING(RTRIM(LTRIM(PM.[strPaymentMethod])),0,29)
						,[agct2_pay_ind_8] = 
							(CASE PM.[strPrintOption]
								WHEN @PrintOptionY THEN	''Y'' 
								WHEN @PrintOptionN THEN ''N''
								WHEN @PrintOptionC THEN ''C''
							END)
						,[agct2_pay_gl_acct_8] = GL.strExternalId
					FROM
						@RecordsToUpdate U
					INNER JOIN
						tblSMPaymentMethod PM
							ON U.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON PM.intAccountId = GL.inti21Id 				 
					WHERE
						agct2_pay_desc_8 is not null
						AND U.[strPaymentMethodCode] = ''008'' 	
						
					SET @UpdateCountTemp = @UpdateCountTemp + @@ROWCOUNT		
					
					UPDATE agctlmst
					SET
						[agct2_pay_desc_9] = SUBSTRING(RTRIM(LTRIM(PM.[strPaymentMethod])),0,29)
						,[agct2_pay_ind_9] = 
							(CASE PM.[strPrintOption]
								WHEN @PrintOptionY THEN	''Y'' 
								WHEN @PrintOptionN THEN ''N''
								WHEN @PrintOptionC THEN ''C''
							END)
						,[agct2_pay_gl_acct_9] = GL.strExternalId
					FROM
						@RecordsToUpdate U
					INNER JOIN
						tblSMPaymentMethod PM
							ON U.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON PM.intAccountId = GL.inti21Id 				 
					WHERE
						agct2_pay_desc_9 is not null
						AND U.[strPaymentMethodCode] = ''009'' 	
						
					SET @UpdateCountTemp = @UpdateCountTemp + @@ROWCOUNT
					SET @UpdatedCount = @UpdateCountTemp			
						
						
				END
			ELSE
				BEGIN
				
					INSERT INTO [tblSMPaymentMethod]
						([strPaymentMethod]
						,[ysnActive]
						,[intSort]           
						,[strPaymentMethodCode]
						,[intAccountId]
						,[strPrintOption]
						,[intConcurrencyId])
					SELECT
						RTRIM(LTRIM(P.[strPaymentMethod]))
						,1
						,P.[strPaymentMethodCode]
						,P.[strPaymentMethodCode]
						,ISNULL(GL.[inti21Id],0)
						,P.[strPrintOption] 
						,0
					FROM
						@RecordsToProcess P
					INNER JOIN
						@RecordsToAdd A
							ON P.[strPaymentMethodCode] = A.[strPaymentMethodCode] 			
					LEFT JOIN
						tblGLCOACrossReference GL
							ON P.[strGLAccount] = GL.[strExternalId]
					LEFT OUTER JOIN
						tblSMPaymentMethod PM
							ON P.[strPaymentMethodCode] = PM.[strPaymentMethodCode]
					WHERE
						PM.[strPaymentMethodCode] IS NULL
					ORDER BY
						P.[strPaymentMethodCode]
						
					SET @AddedCount = @@ROWCOUNT	
					
					
					UPDATE [tblSMPaymentMethod]
					SET
						[strPaymentMethod] = RTRIM(LTRIM(P.[strPaymentMethod]))
						,[ysnActive] = [ysnActive]
						,[intSort] = [intSort]
						,[strPaymentMethodCode] = A.[strPaymentMethodCode]
						,[intAccountId] = ISNULL(GL.[inti21Id],0)
						,[strPrintOption] = P.[strPrintOption] 
					FROM
						@RecordsToProcess P
					INNER JOIN
						@RecordsToUpdate A
							ON P.[strPaymentMethodCode] = A.[strPaymentMethodCode]
					LEFT JOIN
						tblGLCOACrossReference GL
							ON P.[strGLAccount] = GL.[strExternalId]				
					WHERE
						 [tblSMPaymentMethod].[strPaymentMethodCode] = A.[strPaymentMethodCode]  
						 
						 
					SET @UpdatedCount = @@ROWCOUNT			 
					
				
				END


			END')
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
	EXEC('CREATE PROCEDURE uspSMSyncPaymentMethod
				@Checking	bit = 0,
				@UserId		int = 0,
				@Total		int = 0 OUTPUT
			AS
			BEGIN

			IF(@Checking = 1)
				BEGIN
					SELECT
						@Total = COUNT(P.[pttyp_pay_type])
					FROM
						[pttypmst]  P
					LEFT JOIN
						tblGLCOACrossReference GL
							ON P.pttyp_dr_acct_no = GL.strExternalId
					LEFT OUTER JOIN
						tblSMPaymentMethod PM
							ON P.[pttyp_pay_type] = PM.[strPaymentMethodCode]
					WHERE
						PM.[strPaymentMethodCode] IS NULL

					RETURN @Total;
				END	

			INSERT INTO [tblSMPaymentMethod]
				([strPaymentMethod]
				,[ysnActive]
				,[intSort]           
				,[strPaymentMethodCode]
				,[intAccountId]
				,[strPrintOption]
				,[intConcurrencyId])
			SELECT 
				 [pttyp_desc]		--[strPaymentMethod]
				,1					--[ysnActive]
				,1					--[intSort]
				,[pttyp_pay_type]	--[strPaymentMethodCode]
				,GL.[inti21Id]		--[intAccountId]]
				,(CASE UPPER([pttyp_on_deposit_slip_ync])
					WHEN ''Y'' THEN ''Print on Deposit Slip''
					WHEN ''N'' THEN ''Don''''t Print on Deposit Slip''
					WHEN ''C'' THEN ''Cash Summary on Deposit Slip''
					END)			--[strPrintOption]
				,0
			FROM
				[pttypmst]  P
			LEFT JOIN
				tblGLCOACrossReference GL
					ON P.pttyp_dr_acct_no = GL.strExternalId
			LEFT OUTER JOIN
				tblSMPaymentMethod PM
					ON P.[pttyp_pay_type] = PM.[strPaymentMethodCode]
			WHERE
				PM.[strPaymentMethodCode] IS NULL
			ORDER BY
				P.[pttyp_pay_type]

			END')
END