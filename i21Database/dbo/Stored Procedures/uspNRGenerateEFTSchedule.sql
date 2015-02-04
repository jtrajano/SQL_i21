CREATE PROCEDURE [dbo].[uspNRGenerateEFTSchedule]

AS
BEGIN TRY
	SET NOCOUNT ON;

	DECLARE @ErrMsg nvarchar(max)
	
	DECLARE @tbl AS TABLE (CUS_KEY VARCHAR(10)) 
	INSERT  into @tbl 
	SELECT efeft_eft_no FROM efeftmst 
	  WHERE efeft_eft_type_cv = 'C' 
	  --AND efeft_src_sys = 'NR' 
	  AND efeft_active_yn = 'Y' 
	  order by efeft_eft_no

	--Select * from @tbl
--A COLLATE SQL_Latin1_General_CP1_CS_AS = B COLLATE SQL_Latin1_General_CP1_CS_AS

	DECLARE @SchTbl AS TABLE (RowNum Int, intCustomerId Int, intNoteId Int)

	INSERT INTO @SchTbl SELECT distinct ROW_NUMBER() Over (Order By N.intCustomerId), N.intCustomerId, N.intNoteId 
	FROM @tbl C  
	JOIN dbo.tblARCustomer Cus ON C.CUS_KEY COLLATE Latin1_General_CI_AS = Cus.strCustomerNumber COLLATE Latin1_General_CI_AS
	JOIN dbo.tblNRNote N ON N.intCustomerId = Cus.intCustomerId AND N.strNoteType = 'Scheduled Invoice'

	Select * from @SchTbl

	DECLARE @PriorDaysNoteGenerated Int

	SELECT @PriorDaysNoteGenerated = strValue FROM dbo.tblSMPreferences WHERE strPreference = 'NRNumberOfDaysPriorNoteBeGenerated'

	DECLARE @Cnt Int, @RowNum Int

	Select @Cnt=COUNT(RowNum) from @SchTbl

	SET @RowNum = 1

	DECLARE @GenerateSchedule AS TABLE (intCustmerId Int, intNoteId Int, NoteNumber nvarchar(10), intScheduleTransId Int, GenerateType varchar(50))

		INSERT INTO @GenerateSchedule
		SELECT N.intCustomerId, N.intNoteId, strNoteNumber, ST.intScheduleTransId, 'GenerateInvoice'
		FROM dbo.tblNRNote N
		JOIN dbo.tblNRScheduleTransaction ST ON ST.intNoteId = N.intNoteId
		WHERE CAST(CONVERT(nvarchar(10), Dateadd(D, ISNULL(@PriorDaysNoteGenerated,1) * (-1), ST.dtmExpectedPayDate),101) AS DATETIME) = CAST(CONVERT(nvarchar(10), GETDATE(),101) AS DATETIME)
		AND ISNULL(ST.dtmPayGeneratedOn,'') = ''
		
		
		INSERT INTO @GenerateSchedule
		SELECT N.intCustomerId, N.intNoteId, strNoteNumber, ST.intScheduleTransId, 'GenerateLate' 
		FROM dbo.tblNRNote N
		JOIN dbo.tblNRScheduleTransaction ST ON ST.intNoteId = N.intNoteId
		WHERE CAST(CONVERT(nvarchar(10), Dateadd(D, ISNULL(N.intSchdGracePeriod,1), ST.dtmExpectedPayDate),101) AS DATETIME) <= CAST(CONVERT(nvarchar(10), GETDATE(),101) AS DATETIME)
		--AND SM.Schd_ID = @SchdID 
		AND ISNULL(ST.dtmPaidOn,'') = '' and ISNULL(ST.dblLateFeeGenerated,0) = 0
		
			
	WHILE (@Cnt >= @RowNum)
	BEGIN

		INSERT INTO @GenerateSchedule
		Select N.intCustomerId, N.intNoteId, strNoteNumber, ST.intScheduleTransId, 'GeneratePayment' 
		FROM @SchTbl S
		JOIN dbo.tblNRNote N ON N.intNoteId = S.intNoteId AND N.intCustomerId = S.intCustomerId AND S.RowNum = @RowNum
		JOIN dbo.tblNRScheduleTransaction ST ON ST.intNoteId = N.intNoteId
		WHERE CAST(CONVERT(nvarchar(10), ST.dtmExpectedPayDate,101) AS DATETIME) = CAST(CONVERT(nvarchar(10), GETDATE(),101) AS DATETIME)
		AND ISNULL(ST.dtmPaidOn,'') = '' 
		
		SET @RowNum = @RowNum + 1

	END

	Select * from @GenerateSchedule
	
	DECLARE @intCustmerId Int, @intNoteId Int, @NoteNumber nvarchar(10), @intScheduleTransId Int, @GenerateType varchar(50)
			,@dblTransAmount numeric(18,6), @strSchdLateAppliedOn nvarchar(50)
			
	DECLARE CurSchdTrans CURSOR FOR
	SELECT * from @GenerateSchedule
	
	OPEN CurSchdTrans
	  
	FETCH NEXT FROM CurSchdTrans INTO 
	@intCustmerId, @intNoteId, @NoteNumber, @intScheduleTransId, @GenerateType 
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		IF @GenerateType = 'GenerateInvoice'
		BEGIN
			EXEC dbo.uspNRCreateEFTGLJournalEntry @intNoteId, @intScheduleTransId,  @GenerateType, 0 
			UPDATE dbo.tblNRScheduleTransaction SET dtmPayGeneratedOn = GETDATE() WHERE intScheduleTransId = @intScheduleTransId
		END
		
		If @GenerateType = 'GeneratePayment'
		BEGIN
			IF ISNULL((Select dtmPayGeneratedOn from dbo.tblNRScheduleTransaction Where intScheduleTransId = @intScheduleTransId),'')=''
			BEGIN
				SET @GenerateType = 'GenerateInvoice'
				EXEC dbo.uspNRCreateEFTGLJournalEntry @intNoteId, @intScheduleTransId,  @GenerateType, 0 
				UPDATE dbo.tblNRScheduleTransaction SET dtmPayGeneratedOn = GETDATE() WHERE intScheduleTransId = @intScheduleTransId
			END
			SET @GenerateType = 'GeneratePayment'
			EXEC dbo.uspNRCreateEFTGLJournalEntry @intNoteId, @intScheduleTransId,  @GenerateType, 0 
			
			DECLARE @strCbkno nvarchar(20), @strEftrxRefNo nvarchar(50), @eftrx_effect_date int, @CusNo nvarchar(50), @strLocNo nvarchar(10)
					, @eftrx_ivc_rev_dt int, @intLocationId int, @intEntityId int
			Select @strCbkno = efctl_cbk_no from efctlmst	
			SELECT @strEftrxRefNo = apcbk_next_eft_no from apcbkmst Where apcbk_no = @strCbkno
			SELECT @CusNo = strCustomerNumber From dbo.tblARCustomer WHere intCustomerId = @intCustmerId
			
			SELECT @strLocNo = CL.strLocationNumber, @intLocationId = CL.intCompanyLocationId, @intEntityId = intEntityId 
			FROM dbo.tblSMCompanyLocation CL
			JOIN dbo.tblSMUserSecurity US ON US.intCompanyLocationId = CL.intCompanyLocationId
			WHERE US.strUserName = 'SSIADMIN'
			
			SET @eftrx_effect_date = CONVERT(nvarchar(10), Getdate(), 112)
			
			SELECT @eftrx_ivc_rev_dt = CONVERT(nvarchar(10), dtmCreated, 112) FROM dbo.tblNRNote Where intNoteId = @intNoteId
			
			SELECT @dblTransAmount = dblBalance FROM dbo.tblNRScheduleTransaction WHere intScheduleTransId = @intScheduleTransId
			
			-- INSERT into eft transaction table
			INSERT INTO [dbo].[eftrxmst]
           ([eftrx_effect_date]		,[eftrx_cbk_no]			,[eftrx_eft_no]			,[eftrx_ref_no]			,[eftrx_src_sys]		,[eftrx_pull_type]
           ,[eftrx_ivc_no]			,[eftrx_ivc_loc_no]		,[eftrx_seq_no]			,[eftrx_budget_month]	,[eftrx_stmt_date]		,[eftrx_orig_amt]
           ,[eftrx_disc_amt]		,[eftrx_eft_amt]		,[eftrx_eft_tran_code]	,[eftrx_crd_seq_no]		,[eftrx_cr_memo_amt]	,[eftrx_cr_memo_ivc_no]
           ,[eftrx_cr_memo_orig_amt],[eftrx_cr_memo_acct_no],[eftrx_new_cr_memo_yn]	,[eftrx_cr_dm_ivc_di]	,[eftrx_cr_dm_tic_no]   ,[eftrx_cr_memo_loc_no]	
           ,[eftrx_ivc_rev_dt]		,[eftrx_updated_yn]		,[eftrx_user_id]		,[eftrx_user_rev_dt]
           )
			VALUES
           (@eftrx_effect_date		, @strCbkno				,@CusNo					,@strEftrxRefNo			,'NR'					,'IV'
           ,@NoteNumber				,ISNULL(@strLocNo,'')	,0						,0						,0						,0
           ,0						,@dblTransAmount        ,0						,0						,NULL					,NULL
           ,NULL					,NULL					,NULL					,NULL					,NULL					,NULL
           ,@eftrx_ivc_rev_dt       ,' '					,'SSIADMIN'				,@eftrx_effect_date
           )
           
           DECLARE @strSQL nvarchar(max)
           
           SET @strSQL = '<NoteID>' + CAST(@intNoteId as nvarchar(20)) + '</NoteID>'
			SET @strSQL = @strSQL + '<WriteOff>False</WriteOff>'

			SET @strSQL = @strSQL + '<NoteHistory>'

			SET @strSQL = @strSQL + '<NoteHistoryDetail>'
			SET @strSQL = @strSQL + '<NoteHistoryID>0</NoteHistoryID>'
			SET @strSQL = @strSQL + '<HistoryDate>' + CAST(GETDATE() as nvarchar(20)) + '</HistoryDate>'
			SET @strSQL = @strSQL + '<HistoryTypeID>4</HistoryTypeID>'
			SET @strSQL = @strSQL + '<Amount>' + CAST(@dblTransAmount as nvarchar(50)) + '</Amount>'
			SET @strSQL = @strSQL + '<PayOffBalance>0</PayOffBalance>'
			SET @strSQL = @strSQL + '<InvoiceNumber>0</InvoiceNumber>'
			SET @strSQL = @strSQL + '<InvoiceDate>' + CAST(GETDATE() as nvarchar(20)) + '</InvoiceDate>'
			SET @strSQL = @strSQL + '<Location>' + CAST(ISNULL(@intLocationId, '') as nvarchar(20)) + '</Location>'
			SET @strSQL = @strSQL + '<BatchNumber></BatchNumber>'
			SET @strSQL = @strSQL + '<Days>0</Days>'
			SET @strSQL = @strSQL + '<AmountAppliedToPrincipal>0</AmountAppliedToPrincipal>'
			SET @strSQL = @strSQL + '<AmountAppliesToInterest>0</AmountAppliesToInterest>'
			SET @strSQL = @strSQL + '<AsOf>' + CONVERT(nvarchar(20), Getdate(), 101) + '</AsOf>'
			SET @strSQL = @strSQL + '<Principal>0</Principal>'
			SET @strSQL = @strSQL + '<CheckNumber>AutoSchedule</CheckNumber>'


			SET @strSQL = @strSQL + '<UserId>' + CAST(@intEntityId as nvarchar(20)) + '</UserId>'
			SET @strSQL = @strSQL + '<LastUpdateDate>' + CAST(GETDATE() as nvarchar(20)) + '</LastUpdateDate>'
			SET @strSQL = @strSQL + '<InterestToDate></InterestToDate>'
			SET @strSQL = @strSQL + '<Comments>' + 'AutoSchedule' + '</Comments>'

			SET @strSQL = @strSQL + '</NoteHistoryDetail>'

			SET @strSQL = @strSQL + '</NoteHistory>'

			SET @strSQL = '<root>' + @strSQL + '</root> '
			
			EXEC dbo.uspNRCreateNoteTransaction @strSQL
			
			UPDATE dbo.tblNRScheduleTransaction 
			SET dtmPaidOn = GETDATE(), dblPayAmt = @dblTransAmount
			WHERE intScheduleTransId = @intScheduleTransId
			
		END
		
		If @GenerateType = 'GenerateLate'
		BEGIN
			SELECT @strSchdLateAppliedOn = strSchdLateAppliedOn FROM dbo.tblNRNote Where intNoteId = @intNoteId 
			IF (SELECT strSchdLateFeeUnit FROM dbo.tblNRNote Where intNoteId = @intNoteId) = '$'
			BEGIN
				SET @dblTransAmount = (Select dblSchdLateFee from dbo.tblNRNote Where intNoteId = @intNoteId)
			END
			ELSE
			BEGIN
				IF @strSchdLateAppliedOn = 'Outstanding Balance'
				BEGIN
					SET @dblTransAmount = ((Select dblBalance from dbo.tblNRScheduleTransaction Where intScheduleTransId = @intScheduleTransId)*(Select dblSchdLateFee from dbo.tblNRNote Where intNoteId = @intNoteId)/100)
				END
				ELSE IF @strSchdLateAppliedOn = 'Principal'
				BEGIN
					SET @dblTransAmount = ((Select dblPrincipal from dbo.tblNRScheduleTransaction Where intScheduleTransId = @intScheduleTransId)*(Select dblSchdLateFee from dbo.tblNRNote Where intNoteId = @intNoteId)/100)
				END
				ELSE IF @strSchdLateAppliedOn = 'Interest'
				BEGIN
					SET @dblTransAmount = ((Select dblInterest from dbo.tblNRScheduleTransaction Where intScheduleTransId = @intScheduleTransId)*(Select dblSchdLateFee from dbo.tblNRNote Where intNoteId = @intNoteId)/100)
				END			
			END
			EXEC dbo.uspNRCreateEFTGLJournalEntry @intNoteId, @intScheduleTransId,  @GenerateType, @dblTransAmount 
			UPDATE dbo.tblNRScheduleTransaction SET dblLateFeeGenerated = @dblTransAmount, dtmLateFeeGeneratedOn = GETDATE() WHERE intScheduleTransId = @intScheduleTransId
			
		END
		
		FETCH NEXT FROM CurSchdTrans INTO 
		@intCustmerId, @intNoteId, @NoteNumber, @intScheduleTransId, @GenerateType 	
	END
	
	CLOSE CurSchdTrans
	DEALLOCATE CurSchdTrans

	COMMIT TRANSACTION	

END TRY
BEGIN CATCH
IF XACT_STATE() != 0 ROLLBACK TRANSACTION 
SET @ErrMsg = ERROR_MESSAGE() 
RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
END CATCH
