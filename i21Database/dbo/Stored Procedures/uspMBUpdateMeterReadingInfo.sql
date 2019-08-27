CREATE PROCEDURE [dbo].[uspMBUpdateMeterReadingInfo]
    @intMeterReadingId INT
    ,@intUserId INT
    ,@ysnPost BIT
    ,@intInvoiceId INT
AS
BEGIN	

    UPDATE tblMBMeterReading 
	SET intInvoiceId = @intInvoiceId
        ,ysnPosted = @ysnPost
        ,dtmPostedDate = CASE WHEN @ysnPost = 1 THEN GETDATE() ELSE NULL END
	WHERE intMeterReadingId = @intMeterReadingId

    IF (@ysnPost = 1)
	BEGIN
        -- UPDATE METER READING
		UPDATE tblMBMeterReadingDetail SET tblMBMeterReadingDetail.dblLastReading = AD.dblLastMeterReading
		FROM tblMBMeterReadingDetail RD
		INNER JOIN tblMBMeterReading MR ON RD.intMeterReadingId = MR.intMeterReadingId
		INNER JOIN tblMBMeterAccountDetail AD ON AD.intMeterAccountDetailId = RD.intMeterAccountDetailId
		WHERE RD.intMeterReadingId = @intMeterReadingId
		AND RD.dblLastReading < AD.dblLastMeterReading

		-- UPDATE METER ACCOUNT DETAIL
		UPDATE tblMBMeterAccountDetail SET tblMBMeterAccountDetail.dblLastMeterReading = CASE WHEN MRDetail.dblCurrentReading > MADetail.dblLastMeterReading THEN  MRDetail.dblCurrentReading ELSE MADetail.dblLastMeterReading END
		    , tblMBMeterAccountDetail.dblLastTotalSalesDollar = CASE WHEN MRDetail.dblCurrentDollars > MADetail.dblLastTotalSalesDollar THEN MRDetail.dblCurrentDollars ELSE MADetail.dblLastTotalSalesDollar END
		FROM tblMBMeterAccountDetail MADetail
		LEFT JOIN tblMBMeterReadingDetail MRDetail ON MRDetail.intMeterAccountDetailId = MADetail.intMeterAccountDetailId
		WHERE MRDetail.intMeterReadingId = @intMeterReadingId

    END
    ELSE
    BEGIN
        DECLARE @transactionDate DATETIME = NULL
		DECLARE @meterAccountId INT = NULL

		SELECT @transactionDate = dtmTransaction
			, @meterAccountId = intMeterAccountId
		FROM tblMBMeterReading
		WHERE intMeterReadingId = @intMeterReadingId

		DECLARE @CursorTran AS CURSOR

		SET @CursorTran = CURSOR FOR
		SELECT A.intMeterAccountDetailId
		FROM tblMBMeterAccountDetail A
		WHERE A.intMeterAccountId = @meterAccountId

		DECLARE @intMeterAccountDetailId INT = NULL

		OPEN @CursorTran
		FETCH NEXT FROM @CursorTran INTO @intMeterAccountDetailId
        WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @dblCurrentReading NUMERIC(18,6) = NULL
			DECLARE @dblCurrentDollar NUMERIC(18,6) = NULL

			SELECT TOP 1 @dblCurrentReading = MRD.dblCurrentReading, @dblCurrentDollar = MRD.dblCurrentDollars FROM tblMBMeterReadingDetail MRD
			INNER JOIN tblMBMeterReading MR ON MR.intMeterReadingId = MRD.intMeterReadingId
			WHERE MRD.intMeterAccountDetailId = @intMeterAccountDetailId
			AND MR.dtmTransaction <= @transactionDate
			AND MR.intMeterReadingId < @intMeterReadingId
			ORDER BY MR.intMeterReadingId DESC

			UPDATE tblMBMeterAccountDetail SET dblLastMeterReading = ISNULL(@dblCurrentReading, 0), dblLastTotalSalesDollar = ISNULL(@dblCurrentDollar, 0)
			WHERE intMeterAccountDetailId = @intMeterAccountDetailId

			FETCH NEXT FROM @CursorTran INTO @intMeterAccountDetailId
		END
		CLOSE @CursorTran
		DEALLOCATE @CursorTran

    END
		
END