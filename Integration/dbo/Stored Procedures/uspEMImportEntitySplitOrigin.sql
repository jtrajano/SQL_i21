CREATE PROCEDURE uspEMImportEntitySplitOrigin
@error_msg nvarchar(max) = N'' OUTPUT,
@success bit output,
@duplicate_msg nvarchar(max) = N'' OUTPUT
AS
BEGIN


SET @success = CAST(1 AS BIT)
SET @duplicate_msg = N'';

DECLARE @InitTranCount INT;
SET @InitTranCount = @@TRANCOUNT
DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspEMImportEntitySplitOrigin' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

 
IF(OBJECT_ID('tmpsplit') IS NOT NULL)
DROP TABLE tmpsplit

SELECT * INTO tmpsplit FROM
(
	SELECT  * FROM
	 sssplmst where NOT EXISTS (

	 SELECT 1 FROM tblEMImportedSplit  where TRIM(customerNumber) =  TRIM(ssspl_bill_to_cus) 
	 AND TRIM(splitNo) = TRIM(ssspl_split_no)

	 )
 ) b
 --VARIABLE DECLARATIONS
 DECLARE @CUSTOMER_BILLTO NVARCHAR(MAX)
 DECLARE @SPLIT_NO NVARCHAR(MAX)
 DECLARE @DESC NVARCHAR(MAX)
 DECLARE @REC_TYPE NVARCHAR(MAX)
 DECLARE @ACRES NUMERIC(18,6)

 DECLARE @splitType NVARCHAR(50)

 DECLARE @CUSTNO1 NVARCHAR(MAX)
 DECLARE @CUSTNO2 NVARCHAR(MAX)
 DECLARE @CUSTNO3 NVARCHAR(MAX)
 DECLARE @CUSTNO4 NVARCHAR(MAX)
 DECLARE @CUSTNO5 NVARCHAR(MAX)
 DECLARE @CUSTNO6 NVARCHAR(MAX)
 DECLARE @CUSTNO7 NVARCHAR(MAX)
 DECLARE @CUSTNO8 NVARCHAR(MAX)
 DECLARE @CUSTNO9 NVARCHAR(MAX)
 DECLARE @CUSTNO10 NVARCHAR(MAX)
 DECLARE @CUSTNO11 NVARCHAR(MAX)
 DECLARE @CUSTNO12 NVARCHAR(MAX)
 
 DECLARE @PCT1 NUMERIC(18,6)
 DECLARE @PCT2 NUMERIC(18,6)
 DECLARE @PCT3 NUMERIC(18,6)
 DECLARE @PCT4 NUMERIC(18,6)
 DECLARE @PCT5 NUMERIC(18,6)
 DECLARE @PCT6 NUMERIC(18,6)
 DECLARE @PCT7 NUMERIC(18,6)
 DECLARE @PCT8 NUMERIC(18,6)
 DECLARE @PCT9 NUMERIC(18,6)
 DECLARE @PCT10 NUMERIC(18,6)
 DECLARE @PCT11 NUMERIC(18,6)
 DECLARE @PCT12 NUMERIC(18,6)

 --begin transaction

IF(OBJECT_ID('tempdb..#splitDetailOrigin') IS NOT NULL) 
drop table #splitDetailOrigin

create table #splitDetailOrigin
(
	id int ,
	splitId INT,
	custNo nvarchar(200),
	splitPercent numeric(18,6),
	strOption nvarchar(100),
	intStorageScheduleType INT

)

 --END DECLARATIONS

 --DECLARE @success BIT = 1;

IF @InitTranCount = 0
	BEGIN
		BEGIN TRANSACTION
	END		
ELSE
	BEGIN
		SAVE TRANSACTION @Savepoint
	END

WHILE exists(select top 1 1 from tmpsplit)
BEGIN
DECLARE @EntityId INT
	
	select top 1 
		@CUSTOMER_BILLTO = TRIM(ssspl_bill_to_cus),
		@SPLIT_NO = ssspl_split_no,
		@DESC = ssspl_desc,
		@REC_TYPE = ssspl_rec_type,
		@ACRES = ssspl_acres,
		@splitType = CASE TRIM(ssspl_rec_type) WHEN 'A' THEN 'Customer'
					WHEN 'G' THEN 'Vendor'
					WHEN 'B' THEN 'Both' END,
		@CUSTNO1 = ssspl_cus_no_1,
		@CUSTNO2 = ssspl_cus_no_2,
		@CUSTNO3  = ssspl_cus_no_3,
		@CUSTNO4 = ssspl_cus_no_4,
		@CUSTNO5 = ssspl_cus_no_5,
		@CUSTNO6 = ssspl_cus_no_6,
		@CUSTNO7 = ssspl_cus_no_7,
		@CUSTNO8 = ssspl_cus_no_8,
		@CUSTNO9 = ssspl_cus_no_9,
		@CUSTNO10 = ssspl_cus_no_10,
		@CUSTNO11 = ssspl_cus_no_11,
		@CUSTNO12 = ssspl_cus_no_12,

		@PCT1 = ssspl_pct_1,
		@PCT2 = ssspl_pct_2,
		@PCT3 = ssspl_pct_3,
		@PCT4 = ssspl_pct_4,
		@PCT5 = ssspl_pct_5,
		@PCT6 = ssspl_pct_6,
		@PCT7 = ssspl_pct_7,
		@PCT8 = ssspl_pct_8,
		@PCT9 = ssspl_pct_9,
		@PCT10 = ssspl_pct_10,
		@PCT11 = ssspl_pct_11,
		@PCT12 = ssspl_pct_12

FROM tmpsplit


SET @EntityId = (select top 1 intEntityId from vyuEMSearch where TRIM(strEntityNo) = @CUSTOMER_BILLTO)

BEGIN TRY

		--IF @InitTranCount = 0
		--	BEGIN
		--		BEGIN TRANSACTION
		--	END		
		--ELSE
		--	BEGIN
		--		SAVE TRANSACTION @Savepoint
		--	END

	

	if(exists(select top 1 1 from vyuEMSearch where TRIM(strEntityNo) = @CUSTOMER_BILLTO))
	begin

	DECLARE @duplicate_entry INT = (SELECT TOP 1 1 from tblEMEntitySplit where strSplitNumber = @SPLIT_NO and intEntityId = @EntityId)

	IF(ISNULL(@duplicate_entry,0) <> 0)
	BEGIN
		SET @duplicate_msg = @duplicate_msg + CHAR(13) + CAST(@SPLIT_NO AS varchar) + '|' + CAST(@EntityId AS varchar)

		DELETE from tmpsplit where TRIM(ssspl_bill_to_cus) = @CUSTOMER_BILLTO AND ssspl_split_no = @SPLIT_NO
		
		INSERT INTO tblEMImportedSplit(customerNumber, splitNo, remarks) VALUES (@CUSTOMER_BILLTO, @SPLIT_NO, 'Skipped. Split already exists')

		CONTINUE;
	END 

	insert into tblEMEntitySplit(intEntityId, strSplitNumber, strDescription, intFarmId, dblAcres, intCategoryId, strSplitType, intConcurrencyId)
							VALUES(@EntityId, @SPLIT_NO, @DESC, NULL,@ACRES, NULL,@splitType, 1 )

	declare @intSplitId INT = (SELECT SCOPE_IDENTITY())
	declare @strOption NVARCHAR(MAX) = N''
	declare @intStorageScheduleType INT = NULL;

INSERT INTO #splitDetailOrigin(id, splitId, custNo,splitPercent, strOption, intStorageScheduleType)

	select 1, @intSplitId,@CUSTNO1,@PCT1, @strOption, @intStorageScheduleType
	where isnull(@CUSTNO1,'') <> '' and 0 != (case when @PCT1 = 0 then 0 else @PCT1 end)  
	union
		select 2, @intSplitId, @CUSTNO2, @PCT2 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO2,'') <> '' and 0 != (case when @PCT2 = 0 then 0 else @PCT2 end)  
	union
		select 3, @intSplitId,@CUSTNO3, @PCT3 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO3,'') <> '' and 0 != (case when @PCT3 = 0 then 0 else @PCT3 end) 
	union
		select 4, @intSplitId,@CUSTNO4, @PCT4 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO4,'') <> '' and 0 != (case when @PCT4 = 0 then 0 else @PCT4 end)  
	union
		select 5, @intSplitId,@CUSTNO5, @PCT5 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO5,'') <> '' and 0 != (case when @PCT5 = 0 then 0 else @PCT5 end) 
	union
		select 6, @intSplitId,@CUSTNO6, @PCT6 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO6,'') <> '' and 0 != (case when @PCT6 = 0 then 0 else @PCT6 end) 
	union
		select 7, @intSplitId,@CUSTNO7, @PCT7 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO7,'') <> '' and 0 != (case when @PCT7 = 0 then 0 else @PCT7 end)  
	union
		select 8, @intSplitId,@CUSTNO8, @PCT8 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO8,'') <> '' and 0 != (case when @PCT8 = 0 then 0 else @PCT8 end) 
	union
		select 9, @intSplitId,@CUSTNO9, @PCT9 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO9,'') <> '' and 0 != (case when @PCT9 = 0 then 0 else @PCT9 end) 
	union
		select 10, @intSplitId,@CUSTNO10, @PCT10 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO10,'') <> '' and 0 != (case when @PCT10 = 0 then 0 else @PCT10 end)  
	union
		select 11, @intSplitId,@CUSTNO11, @PCT11 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO11,'') <> '' and 0 != (case when @PCT11 = 0 then 0 else @PCT11 end) 
	union
		select 12, @intSplitId,@CUSTNO12, @PCT11 ,@strOption, @intStorageScheduleType
		where ISNULL(@CUSTNO12,'') <> '' and 0 != (case when @PCT12 = 0 then 0 else @PCT12 end) 

	--	select * from #splitDetailOrigin
		
	--while exists split detail here
	while exists(select top 1 1 from #splitDetailOrigin)
	begin
		declare @id int;
		declare @splitId int;
		declare @customer nvarchar(200);
		declare @EntityDetailId INT;
		declare @option nvarchar(100);
		declare @storageScheduleId int;
		declare @split_pct decimal(18,6);

		(select top 1 @id = id,
					 @splitId = splitId,
					 @customer = TRIM(custNo),
					 @option = strOption,
					 @split_pct = splitPercent,
					 @storageScheduleId = intStorageScheduleType
		 from #splitDetailOrigin)



		 set @EntityDetailId = (select intEntityId from vyuEMSearch where TRIM(strEntityNo) = @customer)
		 
		 if(ISNULL(@EntityDetailId,0) = 0)
			begin
				SET @error_msg = 'Entity ' + @customer + ' does not exists.'
				SET @success = CAST(0 AS bit);

				GOTO ExitWithRollback
				--raiserror(@error_msg,16,1)
			end

		 --insert detail table
		 INSERT INTO tblEMEntitySplitDetail(intSplitId, intEntityId,dblSplitPercent, strOption, intStorageScheduleTypeId, intConcurrencyId)
			VALUES (
					@intSplitId,
					@EntityDetailId,
					@split_pct,
					@option,
					@storageScheduleId,
					1
				 )
		
		DELETE FROM #splitDetailOrigin WHERE id = @id

	end
		 

	INSERT INTO tblEMImportedSplit(customerNumber, splitNo, remarks) VALUES (@CUSTOMER_BILLTO, @SPLIT_NO, 'Success')

	DELETE from tmpsplit where TRIM(ssspl_bill_to_cus) = @CUSTOMER_BILLTO AND ssspl_split_no = @SPLIT_NO

	--COMMIT TRANSACTION

	end
	else
		begin
			declare @err nvarchar(max) =  'Entity ' + @CUSTOMER_BILLTO + ' does not exists'
			SET @error_msg = @err;

			GOTO ExitWithRollback
			--raiserror(@err, 16,1)
			--break;
		end
	--valdiations
	/**
	 -Check if split is already imported - UNIQUE(Split# & EntityId)
	**/

	END TRY
	BEGIN CATCH
		
		SET @success = CAST(0 AS bit);
		SET @error_msg = ERROR_MESSAGE();
		
		GOTO ExitWithRollback
		
	END CATCH

END

end

--GraceExit:
--return;

ExitWithCommit:
IF @InitTranCount = 0
	BEGIN
		COMMIT TRANSACTION
	END

GOTO GraceExit


ExitWithRollback:

SET @success = CAST(0 AS bit)

IF @InitTranCount = 0
BEGIN
	IF((XACT_STATE()) <> 0 )
		BEGIN
			ROLLBACK TRANSACTION
			
		END
END

ELSE
	BEGIN
		IF((XACT_STATE()) <> 0)
			BEGIN
				ROLLBACK TRANSACTION @Savepoint
			END
	END



GraceExit:
