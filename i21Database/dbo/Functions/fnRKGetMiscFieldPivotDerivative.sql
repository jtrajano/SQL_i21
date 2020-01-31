CREATE FUNCTION [dbo].[fnRKGetMiscFieldPivotDerivative]
(
	@MiscFields NVARCHAR(MAX)
)
RETURNS @returntable TABLE
(
	strBuySell NVARCHAR(50)
	, dblContractSize NUMERIC(24, 10)
	, strOptionMonth NVARCHAR(50)
	, dblStrike NUMERIC(24, 10)
	, strOptionType NVARCHAR(50)
	, strInstrumentType NVARCHAR(50)
	, strBrokerAccount NVARCHAR(50)
	, strBroker NVARCHAR(50)
	, intFutOptTransactionHeaderId INT
	, ysnPreCrush BIT
	, strBrokerTradeNo NVARCHAR(50)
)
AS
BEGIN
	--DECLARE @@MiscFields NVARCHAR(MAX) = '{Customer ="strTest"}      {Helper ="new"   }  '

	IF (ISNULL(@MiscFields, '') != '')
	BEGIN
		DECLARE @strTemp NVARCHAR(MAX) = @MiscFields
		DECLARE @intBegin INT = CHARINDEX('{', @strTemp)
			, @intEnd INT
			, @Column NVARCHAR(100)
			, @colBegin INT
			, @colEnd INT
			, @Value NVARCHAR(100)
			, @valBegin INT
			, @valEnd INT
			, @statement NVARCHAR(250)

		DECLARE @tmpTable AS TABLE(strFieldName NVARCHAR(100)
			, strValue NVARCHAR(100))

		WHILE (@intBegin > 0)
		BEGIN
			SET @intEnd = CHARINDEX('}', @strTemp)
		
			SET @statement = TRIM(SUBSTRING(@strTemp, @intBegin + 1, @intEnd - 2))
			SET @colEnd = CHARINDEX('=', @statement)
			SET @Column = TRIM(LEFT(@statement, @colEnd - 1))
		
			SET @valBegin = CHARINDEX('"', @statement, @colEnd) + 1
			SET @valEnd = CHARINDEX('"', @statement, @valBegin)
			SET @Value = TRIM(SUBSTRING(@statement, @valBegin, @valEnd - @valBegin))

			SET @strTemp = TRIM(RIGHT(@strTemp, LEN(@strTemp) - @intEnd))
			SET @intBegin = CHARINDEX('{', @strTemp)

			INSERT @tmpTable
			SELECT @Column, @Value
		END

		INSERT INTO @returntable
		SELECT [strBuySell]
			, [dblContractSize]
			, [strOptionMonth]
			, [dblStrike]
			, [strOptionType]
			, [strInstrumentType]
			, [strBrokerAccount]
			, [strBroker]
			, [intFutOptTransactionHeaderId]
			, [ysnPreCrush]
			, [strBrokerTradeNo]
		FROM (
			SELECT strFieldName
				, strValue 
			FROM @tmpTable
		) t 
		PIVOT(
			MIN(strValue)
			FOR strFieldName IN (strBuySell
				, dblContractSize
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, strBrokerAccount
				, strBroker
				, intFutOptTransactionHeaderId
				, ysnPreCrush
				, strBrokerTradeNo)
		) AS pivot_table
	END

	RETURN
END
