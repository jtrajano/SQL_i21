GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMImportPaymentMethod')
	DROP PROCEDURE uspSMImportPaymentMethod
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN

	EXEC('CREATE PROCEDURE uspSMImportPaymentMethod
			@Checking	bit = 0,
			@UserId		int = 0,
			@Total		int = 0 OUTPUT
		AS
		BEGIN

		DECLARE @RecordsToProcess table(strPaymentMethod nvarchar(12), strGLAccount decimal(16,8), strPrintOption nvarchar(50), strPaymentMethodCode nvarchar(3))
		DECLARE @PrintOptionY nvarchar(50), @PrintOptionN nvarchar(50), @PrintOptionC nvarchar(50)

		SELECT
			@PrintOptionY	= ''Print on Deposit Slip''
			,@PrintOptionN	= ''Don''''t Print on Deposit Slip''
			,@PrintOptionC	= ''Cash Summary on Deposit Slip''

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


		IF(@Checking = 1)
			BEGIN
				SELECT
					@Total = COUNT(P.[strPaymentMethodCode])		
				FROM
					@RecordsToProcess P
				LEFT JOIN
					tblGLCOACrossReference GL
						ON P.strGLAccount = GL.strExternalId
				LEFT OUTER JOIN
					tblSMPaymentMethod PM
						ON P.[strPaymentMethodCode] COLLATE Latin1_General_CI_AS = PM.[strPaymentMethodCode] 
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
			P.[strPaymentMethod]
			,1
			,P.[strPaymentMethodCode]
			,P.[strPaymentMethodCode]
			,ISNULL(GL.[inti21Id],0)
			,P.[strPrintOption] 
			,0
		FROM
			@RecordsToProcess P
		LEFT JOIN
			tblGLCOACrossReference GL
				ON P.strGLAccount = GL.strExternalId
		LEFT OUTER JOIN
			tblSMPaymentMethod PM
				ON P.[strPaymentMethodCode] COLLATE Latin1_General_CI_AS = PM.[strPaymentMethodCode] 
		WHERE
			PM.[strPaymentMethodCode] IS NULL
		ORDER BY
			P.[strPaymentMethodCode]


		END')
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
	EXEC('CREATE PROCEDURE uspSMImportPaymentMethod
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
					ON P.[pttyp_pay_type] COLLATE Latin1_General_CI_AS = PM.[strPaymentMethodCode] 
			WHERE
				PM.[strPaymentMethodCode] IS NULL
			ORDER BY
				P.[pttyp_pay_type]

			END')
END