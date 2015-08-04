
CREATE PROCEDURE [dbo].[uspCFImportDiscountSchedule]
		@TotalSuccess INT = 0 OUTPUT,
		@TotalFailed INT = 0 OUTPUT

		AS 
	BEGIN
		SET NOCOUNT ON
	
		--====================================================--
		--     ONE TIME DISCOUNT SCHEDULE SYNCHRONIZATION	  --
		--====================================================--
		TRUNCATE TABLE tblCFDiscountScheduleFailedImport
		TRUNCATE TABLE tblCFDiscountScheduleSuccessImport
		SET @TotalSuccess = 0
		SET @TotalFailed = 0

		--1 Time synchronization here
		PRINT '1 Time DISCOUNT SCHEDULE Synchronization'

		DECLARE @originDiscountSchedule NVARCHAR(50)

		DECLARE @Counter						INT = 0
		DECLARE @MasterPk						INT


		--========================--
		--     MASTER FIELDS	  --
		--========================--
		DECLARE @intDiscountScheduleId			INT
		DECLARE @strDiscountSchedule			NVARCHAR(250)
		DECLARE @strDescription					NVARCHAR(250)
		DECLARE @ysnDiscountOnRemotes			BIT
		DECLARE @ysnDiscountOnExtRemotes		BIT

		--========================--
		--     DETAIL FIELDS	  --
		--========================--
		DECLARE @intDiscountSchedDetailId		INT
		DECLARE @intDetailDiscountScheduleId	INT
		DECLARE @intFromQty						INT
		DECLARE @intThruQty						INT
		DECLARE @dblRate						NUMERIC(18,6)

		--========================--
		--	   EXTRA VARIABLES	  --
		--========================--
		DECLARE @From_QTY_1						INT
		DECLARE @From_QTY_2						INT
		DECLARE @From_QTY_3						INT
		DECLARE @From_QTY_4						INT
		DECLARE @From_QTY_5						INT
		DECLARE @From_QTY_6						INT
		DECLARE @From_QTY_7						INT
		DECLARE @From_QTY_8						INT
		DECLARE @From_QTY_9						INT
		DECLARE @From_QTY_10					INT
		DECLARE @From_QTY_11					INT
		DECLARE @From_QTY_12					INT
		DECLARE @From_QTY_13					INT
		DECLARE @From_QTY_14					INT
		DECLARE @From_QTY_15					INT
		DECLARE @From_QTY_16					INT
		DECLARE @From_QTY_17					INT
		DECLARE @From_QTY_18					INT
		DECLARE @From_QTY_19					INT
		DECLARE @From_QTY_20					INT
		DECLARE @To_QTY_1						INT
		DECLARE @To_QTY_2						INT
		DECLARE @To_QTY_3						INT
		DECLARE @To_QTY_4						INT
		DECLARE @To_QTY_5						INT
		DECLARE @To_QTY_6						INT
		DECLARE @To_QTY_7						INT
		DECLARE @To_QTY_8						INT
		DECLARE @To_QTY_9						INT
		DECLARE @To_QTY_10						INT
		DECLARE @To_QTY_11						INT
		DECLARE @To_QTY_12						INT
		DECLARE @To_QTY_13						INT
		DECLARE @To_QTY_14						INT
		DECLARE @To_QTY_15						INT
		DECLARE @To_QTY_16						INT
		DECLARE @To_QTY_17						INT
		DECLARE @To_QTY_18						INT
		DECLARE @To_QTY_19						INT
		DECLARE @To_QTY_20						INT
		DECLARE @Per_Unit_1						NUMERIC(18,6)
		DECLARE @Per_Unit_2						NUMERIC(18,6)
		DECLARE @Per_Unit_3						NUMERIC(18,6)
		DECLARE @Per_Unit_4						NUMERIC(18,6)
		DECLARE @Per_Unit_5						NUMERIC(18,6)
		DECLARE @Per_Unit_6						NUMERIC(18,6)
		DECLARE @Per_Unit_7						NUMERIC(18,6)
		DECLARE @Per_Unit_8						NUMERIC(18,6)
		DECLARE @Per_Unit_9						NUMERIC(18,6)
		DECLARE @Per_Unit_10					NUMERIC(18,6)
		DECLARE @Per_Unit_11					NUMERIC(18,6)
		DECLARE @Per_Unit_12					NUMERIC(18,6)
		DECLARE @Per_Unit_13					NUMERIC(18,6)
		DECLARE @Per_Unit_14					NUMERIC(18,6)
		DECLARE @Per_Unit_15					NUMERIC(18,6)
		DECLARE @Per_Unit_16					NUMERIC(18,6)
		DECLARE @Per_Unit_17					NUMERIC(18,6)
		DECLARE @Per_Unit_18					NUMERIC(18,6)
		DECLARE @Per_Unit_19					NUMERIC(18,6)
		DECLARE @Per_Unit_20					NUMERIC(18,6)
		
    
		--Import only those are not yet imported
		SELECT cfdsc_schd INTO #tmpcfdscmst
			FROM cfdscmst
				WHERE cfdsc_schd COLLATE Latin1_General_CI_AS NOT IN (select strDiscountSchedule from tblCFDiscountSchedule) 

		WHILE (EXISTS(SELECT 1 FROM #tmpcfdscmst))
		BEGIN
				

			SELECT @originDiscountSchedule = cfdsc_schd FROM #tmpcfdscmst

			DECLARE @DetailRecord TABLE (
				intFrom			INT,
				intTo			INT,
				dblPerUnit		NUMERIC(18,6)
			)

			BEGIN TRY
				BEGIN TRANSACTION
				SELECT TOP 1
					@strDiscountSchedule		= RTRIM(LTRIM(cfdsc_schd))
					,@strDescription			= RTRIM(LTRIM(cfdsc_desc))
					,@ysnDiscountOnRemotes		=(case
													when RTRIM(LTRIM(cfdsc_rmt_dsc_yn)) = 'N' then 'FALSE'
													when RTRIM(LTRIM(cfdsc_rmt_dsc_yn)) = 'Y' then 'TRUE'
													else 'FALSE'
												 end)
					,@ysnDiscountOnExtRemotes   =(case
													when RTRIM(LTRIM(cfdsc_ext_rmt_dsc_yn)) = 'N' then 'FALSE'
													when RTRIM(LTRIM(cfdsc_ext_rmt_dsc_yn)) = 'Y' then 'TRUE'
													else 'FALSE'
												end)
					,@From_QTY_1				= 	cfdsc_from_qty_1	
					,@From_QTY_2				= 	cfdsc_from_qty_2	
					,@From_QTY_3				= 	cfdsc_from_qty_3	
					,@From_QTY_4				= 	cfdsc_from_qty_4	
					,@From_QTY_5				= 	cfdsc_from_qty_5	
					,@From_QTY_6				= 	cfdsc_from_qty_6	
					,@From_QTY_7				= 	cfdsc_from_qty_7	
					,@From_QTY_8				= 	cfdsc_from_qty_8	
					,@From_QTY_9				= 	cfdsc_from_qty_9	
					,@From_QTY_10				= 	cfdsc_from_qty_10
					,@From_QTY_11				= 	cfdsc_from_qty_11
					,@From_QTY_12				= 	cfdsc_from_qty_12
					,@From_QTY_13				= 	cfdsc_from_qty_13
					,@From_QTY_14				= 	cfdsc_from_qty_14
					,@From_QTY_15				= 	cfdsc_from_qty_15
					,@From_QTY_16				= 	cfdsc_from_qty_16
					,@From_QTY_17				= 	cfdsc_from_qty_17
					,@From_QTY_18				= 	cfdsc_from_qty_18
					,@From_QTY_19				= 	cfdsc_from_qty_19
					,@From_QTY_20				= 	cfdsc_from_qty_20
					,@To_QTY_1					= 	cfdsc_thru_qty_1
					,@To_QTY_2					= 	cfdsc_thru_qty_2
					,@To_QTY_3					= 	cfdsc_thru_qty_3
					,@To_QTY_4					= 	cfdsc_thru_qty_4
					,@To_QTY_5					= 	cfdsc_thru_qty_5
					,@To_QTY_6					= 	cfdsc_thru_qty_6
					,@To_QTY_7					= 	cfdsc_thru_qty_7
					,@To_QTY_8					= 	cfdsc_thru_qty_8
					,@To_QTY_9					= 	cfdsc_thru_qty_9
					,@To_QTY_10					= 	cfdsc_thru_qty_10
					,@To_QTY_11					= 	cfdsc_thru_qty_11
					,@To_QTY_12					= 	cfdsc_thru_qty_12
					,@To_QTY_13					= 	cfdsc_thru_qty_13
					,@To_QTY_14					= 	cfdsc_thru_qty_14
					,@To_QTY_15					= 	cfdsc_thru_qty_15
					,@To_QTY_16					= 	cfdsc_thru_qty_16
					,@To_QTY_17					= 	cfdsc_thru_qty_17
					,@To_QTY_18					= 	cfdsc_thru_qty_18
					,@To_QTY_19					= 	cfdsc_thru_qty_19
					,@To_QTY_20					= 	cfdsc_thru_qty_20
					,@Per_Unit_1				=	cfdsc_rt_per_un_1	
					,@Per_Unit_2				= 	cfdsc_rt_per_un_2	
					,@Per_Unit_3				= 	cfdsc_rt_per_un_3	
					,@Per_Unit_4				= 	cfdsc_rt_per_un_4	
					,@Per_Unit_5				= 	cfdsc_rt_per_un_5	
					,@Per_Unit_6				= 	cfdsc_rt_per_un_6	
					,@Per_Unit_7				= 	cfdsc_rt_per_un_7	
					,@Per_Unit_8				= 	cfdsc_rt_per_un_8	
					,@Per_Unit_9				= 	cfdsc_rt_per_un_9	
					,@Per_Unit_10				= 	cfdsc_rt_per_un_10
					,@Per_Unit_11				= 	cfdsc_rt_per_un_11
					,@Per_Unit_12				= 	cfdsc_rt_per_un_12
					,@Per_Unit_13				= 	cfdsc_rt_per_un_13
					,@Per_Unit_14				= 	cfdsc_rt_per_un_14
					,@Per_Unit_15				= 	cfdsc_rt_per_un_15
					,@Per_Unit_16				= 	cfdsc_rt_per_un_16
					,@Per_Unit_17				= 	cfdsc_rt_per_un_17
					,@Per_Unit_18				= 	cfdsc_rt_per_un_18
					,@Per_Unit_19				= 	cfdsc_rt_per_un_19
					,@Per_Unit_20				= 	cfdsc_rt_per_un_20
				FROM cfdscmst
				WHERE cfdsc_schd = @originDiscountSchedule
					
				--================================--
				--		INSERT MASTER RECORD	  --
				--================================--
				INSERT [dbo].[tblCFDiscountSchedule](
				 [strDiscountSchedule]	
				,[strDescription]			
				,[ysnDiscountOnRemotes]	
				,[ysnDiscountOnExtRemotes])
				VALUES(
				 @strDiscountSchedule	
				,@strDescription		
				,@ysnDiscountOnRemotes	
				,@ysnDiscountOnExtRemotes)

				--================================--
				--		INSERT DETAIL RECORDS	  --
				--================================--
				SELECT @MasterPk  = SCOPE_IDENTITY();

				IF (@From_QTY_1 != 0 OR @To_QTY_1 != 0 OR @Per_Unit_1 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_1					
					,@To_QTY_1					
					,@Per_Unit_1)
				END

				IF (@From_QTY_2 != 0 OR @To_QTY_2 != 0 OR @Per_Unit_2 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_2					
					,@To_QTY_2					
					,@Per_Unit_2)
				END

				IF (@From_QTY_3 != 0 OR @To_QTY_3 != 0 OR @Per_Unit_3 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_3					
					,@To_QTY_3					
					,@Per_Unit_3)
				END

				IF (@From_QTY_4 != 0 OR @To_QTY_4 != 0 OR @Per_Unit_4 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_4					
					,@To_QTY_4					
					,@Per_Unit_4)
				END


				IF (@From_QTY_5 != 0 OR @To_QTY_5 != 0 OR @Per_Unit_5 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_5					
					,@To_QTY_5					
					,@Per_Unit_5)
				END


				IF (@From_QTY_6 != 0 OR @To_QTY_6 != 0 OR @Per_Unit_6 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_6					
					,@To_QTY_6					
					,@Per_Unit_6)
				END

				IF (@From_QTY_7 != 0 OR @To_QTY_7 != 0 OR @Per_Unit_7 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_7					
					,@To_QTY_7					
					,@Per_Unit_7)
				END

				IF (@From_QTY_8 != 0 OR @To_QTY_8 != 0 OR @Per_Unit_8 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_8					
					,@To_QTY_8					
					,@Per_Unit_8)
				END

				IF (@From_QTY_9 != 0 OR @To_QTY_9 != 0 OR @Per_Unit_9 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_9					
					,@To_QTY_9					
					,@Per_Unit_9)
				END

				IF (@From_QTY_10 != 0 OR @To_QTY_10 != 0 OR @Per_Unit_10 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_10					
					,@To_QTY_10					
					,@Per_Unit_10)
				END

				IF (@From_QTY_11 != 0 OR @To_QTY_11 != 0 OR @Per_Unit_11 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_11					
					,@To_QTY_11					
					,@Per_Unit_11)
				END

				IF (@From_QTY_12 != 0 OR @To_QTY_12 != 0 OR @Per_Unit_12 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_12					
					,@To_QTY_12					
					,@Per_Unit_12)
				END

				IF (@From_QTY_13 != 0 OR @To_QTY_13 != 0 OR @Per_Unit_13 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_13					
					,@To_QTY_13					
					,@Per_Unit_13)
				END

				IF (@From_QTY_14 != 0 OR @To_QTY_14 != 0 OR @Per_Unit_14 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_14					
					,@To_QTY_14					
					,@Per_Unit_14)
				END

				IF (@From_QTY_15 != 0 OR @To_QTY_15 != 0 OR @Per_Unit_15 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_15					
					,@To_QTY_15					
					,@Per_Unit_15)
				END

				IF (@From_QTY_16 != 0 OR @To_QTY_16 != 0 OR @Per_Unit_16 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_16					
					,@To_QTY_16					
					,@Per_Unit_16)
				END

				IF (@From_QTY_17 != 0 OR @To_QTY_17 != 0 OR @Per_Unit_17 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_17					
					,@To_QTY_17					
					,@Per_Unit_17)
				END

				IF (@From_QTY_18 != 0 OR @To_QTY_18 != 0 OR @Per_Unit_18 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_18					
					,@To_QTY_18					
					,@Per_Unit_18)
				END

				IF (@From_QTY_19 != 0 OR @To_QTY_19 != 0 OR @Per_Unit_19 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_19					
					,@To_QTY_19					
					,@Per_Unit_19)
				END

				IF (@From_QTY_20 != 0 OR @To_QTY_20 != 0 OR @Per_Unit_20 != 0)
				BEGIN
					INSERT [dbo].[tblCFDiscountScheduleDetail](
					 [intDiscountScheduleId]
					,[intFromQty]					
					,[intThruQty]					
					,[dblRate])					
					VALUES(
					 @MasterPk
					,@From_QTY_20					
					,@To_QTY_20					
					,@Per_Unit_20)
				END

				COMMIT TRANSACTION
				SET @TotalSuccess += 1;
				INSERT INTO tblCFDiscountScheduleSuccessImport(strDiscountScheduleId)					
				VALUES(@originDiscountSchedule)			
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @TotalFailed += 1;
				INSERT INTO tblCFDiscountScheduleFailedImport(strDiscountScheduleId,strReason)					
				VALUES(@originDiscountSchedule,ERROR_MESSAGE())					
				--PRINT 'Failed to imports' + @originCustomer; --@@ERROR;
				PRINT 'IMPORTING DISCOUNT SCHEDULE' + ERROR_MESSAGE()
				GOTO CONTINUELOOP;
			END CATCH
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END
								
			CONTINUELOOP:
			PRINT @originDiscountSchedule
			DELETE FROM #tmpcfdscmst WHERE cfdsc_schd = @originDiscountSchedule
		
			SET @Counter += 1;

		END
	
		--SET @Total = @Counter

	END