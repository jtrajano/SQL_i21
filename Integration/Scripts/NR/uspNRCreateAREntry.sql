GO
IF EXISTS 
(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ptpyemst]') AND type IN (N'U'))
OR EXISTS
(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[agpyemst]') AND type IN (N'U'))
BEGIN 

	EXEC('
		IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspNRCreateAREntry'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspNRCreateAREntry];
	')

	EXEC('
		CREATE PROCEDURE [dbo].[uspNRCreateAREntry]
		@intNoteTransId Int
		AS
		BEGIN

			DECLARE @strCustomerNumber nvarchar(50), @strInvoiceNumber nvarchar(50), @strInvoiceLocation nvarchar(50)
				  , @intNoteId Int, @dblAmount numeric(18,6), @strCrType nvarchar(50), @strRefNo nvarchar(50)
				  , @strRevDt nvarchar(25), @intcrdSeqNo int, @strCheckNo nvarchar(25), @strBatchNo nvarchar(50)
				  , @strInvoiceLocationNo nvarchar(100), @strLocation nvarchar(20), @strLocationNo nvarchar(100)
				  , @strPayType nvarchar(50), @strUserID nvarchar(50)
			DECLARE @intSeqNo int, @strRevDate nvarchar(50), @strSysRevTime nvarchar(20), @strRevTime nvarchar(20)	
			DECLARE @intCustomerId int, @blnSwitchOrigini21 bit, @strOriginSystem nvarchar(5), @strVersionNumber nvarchar(6)
				  , @intCreditAccountId int, @strAccountId nvarchar(30)
			
			SELECT @intNoteId = intNoteId 
			, @strInvoiceNumber = strInvoiceNo
			, @strInvoiceLocation = strInvoiceLocation
			, @strRefNo = strRefNo
			, @strBatchNo = strBatchNumber
			, @strLocation = strLocation
			, @strPayType = strPayType
			, @strUserID = intLastModifiedUserId 
			, @dblAmount = dblTransAmount
			FROM dbo.tblNRNoteTransaction Where intNoteTransId = @intNoteTransId
			SELECT @blnSwitchOrigini21 = strValue FROM dbo.tblSMPreferences WHERE strPreference = ''nrSwitchOrigini21''
			SELECT @strOriginSystem = strValue FROM dbo.tblSMPreferences WHERE strPreference = ''nrOriginSystem''			
			SELECT @strVersionNumber = strValue FROM dbo.tblSMPreferences WHERE strPreference = ''nrVersionNumber''						
			SELECT @intCustomerId = intCustomerId FROM dbo.tblNRNote WHERE intNoteId = @intNoteId
			SELECT @intCreditAccountId = strValue FROM dbo.tblSMPreferences WHERE strPreference = ''NRGLNotesReceivableAccount''
			SELECT @strAccountId = REPLACE(strAccountId, ''-'', ''.0000'') FROM dbo.tblGLAccount WHERE intAccountId = @intCreditAccountId
			SELECT @strInvoiceLocationNo = ISNULL(strLocationNumber, strLocationName) FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = @strInvoiceLocation
			SELECT @strLocation = strLocationNumber FROM dbo.tblSMCompanyLocation WHERE intCompanyLocationId = @strLocation
						
			
			 --SUBSTRING( REPLACE( CONVERT(varchar, GETDATE(), 101), ''/'', '''' ), 1, 4)--+ REPLACE(CONVERT(varchar(5), GETDATE(), 108), '':'','''') 

			IF @blnSwitchOrigini21 = 1
			BEGIN
				SELECT @strCustomerNumber = strCustomerNumber FROM dbo.tblARCustomer Where intCustomerId = @intCustomerId
				SELECT @strRevDate = CONVERT(varchar, GETDATE(), 112)
				SELECT @strRevTime = CONVERT(varchar, GETDATE(), 114)
				SET @strRevTime = REPLACE(@strRevTime,'':'','''')
								
				IF @strOriginSystem = ''PT''
				BEGIN
					IF @strVersionNumber = ''15.1''
					BEGIN
						SELECT @intSeqNo = MAX(ptpye_no)  FROM ptpyemst WHERE (ptpye_cus_no = @strCustomerNumber) 
							AND (ptpye_inc_ref = @strInvoiceNumber) AND (ptpye_ivc_loc_no = @strInvoiceLocationNo)
						SET @intSeqNo = ISNULL(@intSeqNo,0) + 1
						SET @strRevTime = SUBSTRING(@strRevTime, 1, 6)			
						
						IF @dblAmount < 0
						BEGIN
							SELECT @strCrType = c.ptcrd_type, @strRefNo = c.ptcrd_invc_no, @strRevDate = c.ptcrd_rev_dt, @intcrdSeqNo = c.ptcrd_seq_no
							FROM ptivcmst a 
							LEFT OUTER JOIN ptcrdmst c ON a.ptivc_cus_no = c.ptcrd_cus_no AND a.ptivc_invc_no = c.ptcrd_invc_no 
								AND a.ptivc_loc_no = c.ptcrd_loc_no 
							WHERE a.ptivc_invc_no = @strInvoiceNumber AND a.ptivc_loc_no = @strInvoiceLocationNo
							
							SET @strCheckNo = ''ADJUST''
							SET @dblAmount = @dblAmount * (-1)
						END
						ELSE
						BEGIN
							SET @strCrType = ''P''
							SET @strCheckNo = ''OTHER''		
						END
						
						INSERT INTO [dbo].[ptpyemst]
							   ([ptpye_cus_no]		,[ptpye_inc_ref]	,[ptpye_no]			,[ptpye_rec_type]		,[ptpye_rev_dt]
							   ,[ptpye_check_no]	,[ptpye_amt]		,[ptpye_acct_no]	,[ptpye_cstore_rec_yn]	,[ptpye_fin_chgs_earned]
							   ,[ptpye_ref_no]		,[ptpye_orig_rev_dt],[ptpye_cred_origin],[ptpye_batch_no]		,[ptpye_oth_inc_cd]
							   ,[ptpye_oth_inc_comment],[ptpye_pay_no]	,[ptpye_cr_seq_no]	,[ptpye_loc_no]			,[ptpye_ivc_loc_no]
							   ,[ptpye_cred_ind]	,[ptpye_note]		,[ptpye_pay_type]	,[ptpye_orig_crd_pay_type]
							   ,[ptpye_user_id]		,[ptpye_user_rev_dt],[ptpye_user_time])
						 VALUES
							   (@strCustomerNumber	,@strInvoiceNumber	,@intSeqNo			,@strCrType				,@strRevDate
							   ,@strCheckNo			,@dblAmount			,@strAccountId		,''N''					,0
							   ,@strRefNo			,@strRevDate		,''''					,@strBatchNo			,''''
							   ,''''					,0					,@intcrdSeqNo		,@strLocationNo			,@strInvoiceLocationNo
							   ,''''					,@strRefNo			,@strPayType		,''''
							   ,@strUserID			,@strRevDate		,@strRevTime
							   )
						
					END -- 15.1 END
				END -- PT END
				ELSE
				BEGIN
					IF @strVersionNumber = ''15.1''
					BEGIN
						SELECT @intSeqNo = MAX(agpye_pay_seq_no)  FROM [agpyemst] WHERE (agpye_cus_no = @strCustomerNumber) 
							AND (agpye_inc_ref = @strInvoiceNumber) AND (agpye_ivc_loc_no = @strInvoiceLocationNo)
						SET @intSeqNo = ISNULL(@intSeqNo,0) + 1
						SET @strRevTime = SUBSTRING(@strRevTime, 1, 6)			
						
						IF @dblAmount < 0
						BEGIN
							SELECT @strCrType = c.agcrd_type, @strRefNo = c.agcrd_ref_no, @strRevDate = c.agcrd_rev_dt, @intcrdSeqNo = c.agcrd_seq_no
							FROM agivcmst a 
							LEFT OUTER JOIN agcrdmst c ON a.agivc_bill_to_cus = c.agcrd_cus_no AND a.agivc_ivc_no = c.agcrd_ref_no 
								AND a.agivc_loc_no = c.agcrd_loc_no 
							WHERE a.agivc_ivc_no = @strInvoiceNumber AND a.agivc_loc_no = @strInvoiceLocationNo
							
							SET @strCheckNo = ''ADJUST''
							SET @dblAmount = @dblAmount * (-1)
						END
						ELSE
						BEGIN
							SET @strCrType = ''P''
							SET @strCheckNo = ''OTHER''		
						END
						
						INSERT INTO [dbo].[agpyemst]
							   (agpye_cus_no		,agpye_inc_ref		,agpye_ivc_loc_no			,agpye_seq_no		,agpye_rec_type
							   ,agpye_rev_dt		,agpye_chk_no		,agpye_amt					,agpye_acct_no		,agpye_ref_no
							   ,agpye_orig_rev_dt	,agpye_cred_ind		,agpye_cred_origin			,agpye_batch_no		,agpye_oth_inc_cd
							   ,agpye_note			,agpye_pay_type		,agpye_loc_no				,agpye_pay_seq_no	,agpye_cr_seq_no
							   ,agpye_sys_rev_dt	,agpye_sys_time		,agpye_currency				,agpye_currency_rt	,agpye_currency_cnt
							   ,agpye_user_id		,agpye_user_rev_dt)
						 VALUES
							   (@strCustomerNumber	,@strInvoiceNumber	,@strInvoiceLocationNo		,@intSeqNo			,''P''
							   ,@strRevDate			,@strCheckNo		,@dblAmount					,@strAccountId		,@strRefNo
							   ,@strRevDate			,''''					,''''							,@strBatchNo		,''''
							   ,''''					,@strPayType		,@strLocationNo				,0					,0
							   ,@strRevDate			,@strRevTime		,''''							,0					,''''
							   ,@strUserID			,@strRevDate		
							   )
						
					END -- 15.1 END
				END
			END -- Origin END
			
		END
	')

END
