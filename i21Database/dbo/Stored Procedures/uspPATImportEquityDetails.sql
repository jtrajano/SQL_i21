CREATE PROCEDURE [dbo].[uspPATImportEquityDetails]
	@checking BIT = 0,
	@total INT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


	DECLARE @customerEquityTable TABLE(
		[intTempId] INT IDENTITY PRIMARY KEY,
		[intCustomerId] INT NOT NULL,
		[intFiscalYearId] INT NOT NULL, 
		[strEquityType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intRefundTypeId] INT NOT NULL, 
		[dblEquity] NUMERIC(18 ,6) NULL DEFAULT 0
	)

	DECLARE @PatEquCus char (10),
			@Patccyy smallint,
			@RefundType tinyint, 
			@UndistEqu decimal(9, 2), 
			@undistRes decimal(9, 2),
			@PatEquCusID int,
			@RefundID int,
			@EquityType NVARCHAR(50);
 
	DECLARE CusEquity_cursor CURSOR FOR 
	SELECT pahst_cus_no, pahst_ccyy, pahst_rfd_type, pahst_undist_equity, pahst_undist_res FROM pahstmst

	OPEN CusEquity_cursor

	FETCH NEXT FROM CusEquity_cursor into @PatEquCus, @Patccyy, @RefundType, @UndistEqu, @undistRes 

	WHILE @@FETCH_STATUS = 0  
	BEGIN   

		SET @PatEquCusID = (SELECT intEntityId from dbo.vyuEMEntity where strEntityNo = @PatEquCus and strType = 'Customer')

		SET @RefundID = (SELECT intRefundTypeId FROM tblPATRefundRate where 
		strRefundType = @RefundType)

		If @UndistEqu != 0
		BEGIN

			SET @EquityType = 'Undistributed'

			INSERT INTO @customerEquityTable(intCustomerId, intFiscalYearId, strEquityType,  intRefundTypeId, dblEquity)
			VALUES (@PatEquCusID, @Patccyy, @EquityType, @RefundID, @UndistEqu) 

		END


		If @undistRes != 0
		BEGIN

			SET @EquityType = 'Reserve'

			INSERT INTO @customerEquityTable(intCustomerId, intFiscalYearId, strEquityType,  intRefundTypeId, dblEquity)
			VALUES (@PatEquCusID, @Patccyy, @EquityType, @RefundID, @UndistEqu) 

		END

	FETCH NEXT FROM CusEquity_cursor into @PatEquCus, @Patccyy, @RefundType, @UndistEqu, @undistRes 

	END

	CLOSE CusEquity_cursor
	DEALLOCATE CusEquity_cursor

	------------------- BEGIN - RETURN COUNT TO BE IMPORTED ----------------------------
	IF(@checking = 1)
	BEGIN
		SELECT @total = COUNT(*) FROM @customerEquityTable tempCE
		RETURN @total;
	END
	------------------- END - RETURN COUNT TO BE IMPORTED ----------------------------


	------------------- BEGIN - INSERT ORIGIN ROWS INTO CUSTOMER EQUITY TABLE ----------------------------
	INSERT INTO [dbo].[tblPATCustomerEquity](intCustomerId, intFiscalYearId, strEquityType, intRefundTypeId, dblEquity)
	SELECT intCustomerId,intFiscalYearId, strEquityType, intRefundTypeId, dblEquity
	FROM @customerEquityTable
	------------------- END - INSERT ORIGIN ROWS INTO CUSTOMER EQUITY TABLE ----------------------------

END