CREATE PROCEDURE [dbo].[uspNRCreateNoteTransaction]
@XML varchar(max)
AS
BEGIN TRY  
	DECLARE 
	 @idoc int
	,@ErrMsg nvarchar(max)
	,@NoteID Int
	,@isWriteOff bit
	,@NoteTransID Int
	,@TransDate DateTime
	,@TransTypeID Int
	,@Amount Decimal(18,2)
	,@PayOffBalance Decimal(18,2)
	,@InvoiceNumber nvarchar(10)
	,@InvoiceDate DateTime
	,@Location Char(3)
	,@BatchNumber Char(3)
	,@Days Int
	,@AmountAppliedToPrincipal Decimal(18,2)
	,@AmountAppliesToInterest Decimal(18,2)
	,@AsOf DateTime
	,@Principal Decimal(18,2)
	,@CheckNumber nvarchar(10)
	,@UserId nvarchar(10)
	,@LastUpdateDate DateTime
	,@Comments nvarchar(200)
	,@OnPrincipalOrInterest nvarchar(50)
	,@AccountAffected nvarchar(50)
	,@InvoiceLocation nvarchar(20)
	,@ReferenceNumber nvarchar(20)
	,@PaymentType nvarchar(20)
	,@InterestToDate Decimal(18,4)
	,@BulkInterest Int = 0
	, @AsOfForInterestCal DateTime
	,@AdjustmentType nvarchar(200)	
	,@NoteType char(50)
	,@UnPaidInterest Decimal(18,2)
	,@ConcurrencyId int
	
	--,@XML varchar(max)
	
	--return @XML
	
	--Set @XML='<root><NoteID>43</NoteID><WriteOff>False</WriteOff><NoteTrans><NoteHistoryDetail><NoteTransID>0</NoteTransID><TransDate>11/29/2012 5:33:42 PM</TransDate><TransTypeID>7</TransTypeID><Amount>3000</Amount><PayOffBalance>0</PayOffBalance><InvoiceNumber>0</InvoiceNumber><InvoiceDate>11/29/2012 5:33:42 PM</InvoiceDate><Location></Location><BatchNumber></BatchNumber><Days>0</Days><AmountAppliedToPrincipal>0</AmountAppliedToPrincipal><AmountAppliesToInterest>0</AmountAppliesToInterest><AsOf>11/29/2012</AsOf><Principal>0</Principal><CheckNumber></CheckNumber><UserId>NBYRD</UserId><LastUpdateDate>11/29/2012</LastUpdateDate><Comments></Comments><OnPrincipalOrInterest>Principal</OnPrincipalOrInterest><AccountAffected>Clearing Account</AccountAffected><AdjustmentType>INVOICES</AdjustmentType></NoteTransDetail></NoteTrans></root>'
	BEGIN TRANSACTION
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT @NoteID = NoteID,@isWriteOff= WriteOff
	 From OPENXML(@idoc, 'root',2) WITH( NoteID int
	 ,WriteOff bit)
			
	SELECT @isWriteOff = ysnWriteOff, @NoteType = strNoteType FROM dbo.tblNRNote WHERE intNoteId = @NoteID
	
	DECLARE CurTrans CURSOR FOR
	SELECT 
		TransDate
      ,TransTypeID
      ,Amount
      ,PayOffBalance 
      ,InvoiceNumber
      ,InvoiceDate
      ,Location
      ,BatchNumber
      ,[Days]
      ,AmountAppliedToPrincipal
      ,AmountAppliesToInterest
      ,AsOf
      ,Principal
      ,CheckNumber
      ,UserId
      ,LastUpdateDate
      ,Comments
      ,OnPrincipalOrInterest
      ,AccountAffected
      ,InvoiceLocation
      ,ReferenceNumber
      ,PaymentType
      ,AdjustmentType
      ,ConcurrencyId
	FROM OPENXML(@idoc, 'root/NoteTrans/NoteTransDetail',2)
	WITH(
	  TransDate DateTime
      ,TransTypeID Int
      ,Amount Decimal(18,2)
      ,PayOffBalance Decimal(18,2)
      ,InvoiceNumber nvarchar(10)
      ,InvoiceDate DateTime
      ,Location Char(3)
      ,BatchNumber Char(3)
      ,[Days] Int
      ,AmountAppliedToPrincipal Decimal(18,2)
      ,AmountAppliesToInterest Decimal(18,2)
      ,AsOf DateTime
	  ,Principal Decimal(18,2)
	  ,CheckNumber nvarchar(10)
	  ,UserId nvarchar(10)
	  ,LastUpdateDate datetime
	  ,Comments nvarchar(200)
	  ,OnPrincipalOrInterest nvarchar(50)
	  ,AccountAffected nvarchar(50)
	  ,InvoiceLocation nvarchar(20)
	  ,ReferenceNumber nvarchar(20)
	  ,PaymentType nvarchar(20)
	  ,AdjustmentType nvarchar(200)
	  ,ConcurrencyId int)  
	  
	OPEN CurTrans
	  
	FETCH NEXT FROM curTrans INTO 
	 @TransDate 
	,@TransTypeID 
	,@Amount 
	,@PayOffBalance 
	,@InvoiceNumber 
	,@InvoiceDate 
	,@Location 
	,@BatchNumber 
	,@Days 
	,@AmountAppliedToPrincipal 
	,@AmountAppliesToInterest 
	,@AsOf 
	,@Principal 
	,@CheckNumber 
	,@UserId 
	,@LastUpdateDate
	,@Comments
	,@OnPrincipalOrInterest
	,@AccountAffected
	,@InvoiceLocation
	,@ReferenceNumber
	,@PaymentType
	,@AdjustmentType
	,@ConcurrencyId
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		SET @AsOfForInterestCal = @AsOf
		SET @UnPaidInterest = 0
		
		
		DECLARE @PrevAsOfDate DateTime
				,@PrevPrincipal Decimal(18,2)
				,@PrevInterest Decimal(18,2)
				,@PrevPayOffBal Decimal(18,2)
				,@LastTransTypeID Int
				,@PrevUnPaidInterest Decimal(18,2)
				
		If Exists (Select * from dbo.tblNRNoteTransaction Where intNoteId = @NoteID)
		BEGIN
			SELECT top 1 @PrevAsOfDate = dtmAsOfDate, @PrevPrincipal = dblPrincipal, @PrevInterest = dblInterestToDate
			, @PrevPayOffBal = dblPayOffBalance, @LastTransTypeID = intNoteTransTypeId, @PrevUnPaidInterest = dblUnpaidInterest
			FROM dbo.tblNRNoteTransaction WHERE intNoteId = @NoteID Order By intNoteTransId DESC
		END
		
				
		SELECT @NoteType = strNoteType FROM dbo.tblNRNote
	
		IF @TransTypeID = 2 OR @TransTypeID = 1 OR (@TransTypeID = 7 and @OnPrincipalOrInterest = 'Principal')
		BEGIN
			SET @AmountAppliedToPrincipal = (@Amount * (1)) 
			SET @AmountAppliesToInterest = 0 		
		END
	
		IF ((@TransTypeID = 7 and @OnPrincipalOrInterest = 'Interest') OR @TransTypeID = 6)
		BEGIN
			SET @AmountAppliedToPrincipal = 0 
			SET @AmountAppliesToInterest = (@Amount * (1)) 
		END
		
		IF @NoteType = 'Pay Interest First' or @NoteType = 'Scheduled Invoice'
		BEGIN	
			IF (@TransTypeID = 4)
			BEGIN
				IF @Amount > @PrevUnPaidInterest
				BEGIN
					SET @AmountAppliedToPrincipal = (@Amount - @PrevUnPaidInterest) * (-1) 
					SET @AmountAppliesToInterest = (@PrevUnPaidInterest) * (-1)  
				END
				ELSE 
				BEGIN
					SET @AmountAppliedToPrincipal = 0  
					SET @AmountAppliesToInterest = (@Amount) * (-1)  
				END
			END			
		END
		
		IF @NoteType = 'Pay Principal First'
		BEGIN				
			IF (@TransTypeID = 4)
			BEGIN
				IF @Amount > @PrevPrincipal
				BEGIN
					SET @AmountAppliedToPrincipal = (@PrevPrincipal) * (-1)  
					SET @AmountAppliesToInterest = (@Amount - @PrevPrincipal) * (-1)  
				END
				ELSE 
				BEGIN
					SET @AmountAppliedToPrincipal = (@Amount) * (-1)
					SET @AmountAppliesToInterest =  0   
				END
			END			
		END
		
		IF @TransTypeID = 3
		BEGIN
			SET @AmountAppliesToInterest = 0
			SET @AmountAppliedToPrincipal = 0 
		END
		
			
		
		SET @InterestToDate =0
			
		if @PrevAsOfDate = @AsOf
		BEGIN
			Select Top 1 @Days = intTransDays From dbo.tblNRNoteTransaction WHERE intNoteId =  @NoteID Order By intNoteTransId DESC
		END
		ELSE IF @TransTypeID = 6
		BEGIN
			DECLARE @PayNoteTransID Int
		
			SELECT @NoteTransID = intNoteTransId FROM dbo.tblNRNoteTransaction WHERE intNoteId = @NoteID AND intNoteTransTypeId = 4 AND strCheckNumber = @CheckNumber
		
			SELECT TOP 1 @PrevAsOfDate = dtmAsOfDate FROM dbo.tblNRNoteTransaction WHERE intNoteId = @NoteID AND intNoteTransTypeId > (@NoteTransID) --<= @PrvAsOfDate AND TransTypeID = 4 and 	
		
			SET @Days = DATEDIFF(day,@PrevAsOfDate,@AsOf)
			
		END
		ELSE
		BEGIN
			IF @LastTransTypeID = 6 
			SELECT TOP 1 @PrevAsOfDate = dtmAsOfDate From dbo.tblNRNoteTransaction WHERE intNoteId = @NoteID AND intNoteTransTypeId <> 6 ORDER By intNoteTransId DESC
			SET @Days = DATEDIFF(day,@PrevAsOfDate,@AsOf)
		END
			
		IF (@PrevPrincipal + @Amount)<=0
			SET @Principal = 0
		ELSE
			SET @Principal = @PrevPrincipal + @Amount
			
		SET @UnPaidInterest = ISNULL(@PrevUnPaidInterest,0) + ISNULL(@AmountAppliesToInterest,0)	
		
				
		INSERT INTO dbo.tblNRNoteTransaction
		SELECT 
		 @NoteID 
		,@TransDate 
		,@TransTypeID 
		,@Days 
		,@Amount 
		,@Principal 
		,@InterestToDate
		,@UnPaidInterest
		,@PayOffBalance 
		,@InvoiceNumber 
		,@InvoiceDate 
		,@InvoiceLocation
		,@Location 
		,@ReferenceNumber
		,@BatchNumber 
		,@AmountAppliedToPrincipal 
		,@AmountAppliesToInterest 
		,@PaymentType
		,@AsOf 
		,@CheckNumber 
		,@Comments
		,@OnPrincipalOrInterest
		,@AccountAffected
		,@AdjustmentType
		,@UserId 
		,@ConcurrencyId
		--,@PrevAsOfDate 
		--,@ReferenceNumber
		
		--Declare @TransId
	
	FETCH NEXT FROM curTrans INTO 
	 @TransDate 
	,@TransTypeID 
	,@Amount 
	,@PayOffBalance 
	,@InvoiceNumber 
	,@InvoiceDate 
	,@Location 
	,@BatchNumber 
	,@Days 
	,@AmountAppliedToPrincipal 
	,@AmountAppliesToInterest 
	,@AsOf 
	,@Principal 
	,@CheckNumber 
	,@UserId 
	,@LastUpdateDate
	,@Comments
	,@OnPrincipalOrInterest
	,@AccountAffected 
	,@InvoiceLocation
	,@ReferenceNumber
	,@PaymentType
	,@AdjustmentType
	,@ConcurrencyId
	
		
	END
		
	Close CurTrans
	Deallocate CurTrans

		
		SET @InterestToDate = [dbo].[fnCalculateInterestToDate] (@NoteID, @AsOfForInterestCal,@TransTypeID, @CheckNumber)
		
		--IF @TransTypeID = 6 SET @InterestToDate = @InterestToDate * @Amount
			
		DECLARE @LastTransID Int,@AMTAPP_INT DECIMAL(18,2), @InterestCalcDate DateTime,@LastInterest Decimal(18,2)
		, @IntSinceCreation Decimal(18,2),@PrvPayoff Decimal(18,2), @LastUnpaidInt Decimal(18,2)

		 SELECT top 1 @LastTransID = intNoteTransId, @LastTransTypeID = intNoteTransTypeId	FROM dbo.tblNRNoteTransaction WHERE intNoteId = @NoteID Order By intNoteTransId DESC
		
			
		-- added the following condition if current asof date and previous asof dates are same then Interest to date setting as zero
		-- added on 11-dec-2012, issue was figured out from Note number 47,48(NR00047,NR00048)
		IF (@LastTransTypeID=1) 
		BEGIN
			UPDATE dbo.tblNRNoteTransaction SET dblInterestToDate = 0
			WHERE intNoteId = @NoteID AND intNoteTransId <> @LastTransID AND dtmAsOfDate = @AsOfForInterestCal AND intNoteTransTypeId = @LastTransTypeID --and Convert(nvarchar(10),AsOf,101) = CONVERT(nvarchar(10), @AsOfForInterestCal,101)

			IF @AsOf = (select TOP 1 dtmAsOfDate FROM dbo.tblNRNoteTransaction WHERE intNoteId=@NoteID AND intNoteTransTypeId <> @LastTransTypeID ORDER BY dtmAsOfDate DESC,dtmNoteTranDate DESC ,intNoteTransId DESC)
			 SET @InterestToDate =0
		END
		ELSE
		BEGIN
			--UPDATE dbo.tblNRNoteTransaction SET NRHST_INT_DT = 0 WHERE 
			IF  @PrevAsOfDate = @AsOf 
			 --AND NRHST_HIS_TYP_ID = @LastTransTypeID --and Convert(nvarchar(10),AsOf,101) = CONVERT(nvarchar(10), @AsOfForInterestCal,101)
			 SET @InterestToDate =0
		END

		
		UPDATE dbo.tblNRNoteTransaction	SET dblUnpaidInterest = @UnPaidInterest + @InterestToDate WHERE intNoteTransId = @LastTransID
		UPDATE dbo.tblNRNoteTransaction SET dblPayOffBalance = dblPrincipal + dblUnpaidInterest WHERE intNoteTransId = @LastTransID
		
		UPDATE dbo.tblNRNote SET dblNotePrincipal = (SELECT dblPrincipal FROM dbo.tblNRNoteTransaction WHERE intNoteTransId = @LastTransID) WHERE intNoteId = @NoteID
		
	--EXEC [dbo].[Note_Future_Trans_Update] @NoteID=@NoteID
		

	  	COMMIT TRANSACTION	
	  	
	 END TRY   
	   
      
BEGIN CATCH       
 --IF XACT_STATE() != 0 ROLLBACK TRANSACTION    
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH
