CREATE PROCEDURE testi21Database.[test fnMultiply]
AS 
BEGIN
	BEGIN 
		-- Arrange
		DECLARE @x AS NUMERIC(38, 20) 
		DECLARE @y AS NUMERIC(38, 20)
		DECLARE @result AS NUMERIC(38, 20) 
		DECLARE @expected AS NUMERIC(38, 20)
	END

	BEGIN 
		SET @x = 1153.22000000000000000000
		SET @y = 0.00900000000000000000
		SET @expected = 10.37898000000000000000
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 1.'
	END

	BEGIN 
		SET @x = 25.00000000000000000000
		SET @y = 44.09250000000000000000
		SET @expected = 1102.31250000000000000000
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 2.'
	END

	BEGIN 
		SET @x = -25.00000000000000000000
		SET @y = 44.09250000000000000000
		SET @expected = -1102.31250000000000000000
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 3.'
	END

	BEGIN 
		SET @x = 12345678.00000000000000000000
		SET @y = 0.00900000000000000000
		SET @expected = 111111.10200000000000000000
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 4.'
	END

	BEGIN 
		SET @x = -0.62847506473090700000 
		SET @y = 0.00900000000000000000 
		SET @expected = -0.00565627558257816300 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 5.'
	END

	BEGIN 
		SET @x = 2204.62000000000000000000 
		SET @y = 40.00000000000000000000 
		SET @expected = 88184.80000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 6.'
	END

	BEGIN 
		SET @x = 2204.62400000000000000000 
		SET @y = 40.00000000000000000000 
		SET @expected = 88184.96000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 7.'
	END

	BEGIN 
		SET @x = 25.00000000000000000000 
		SET @y = 0.45359200000000000000 
		SET @expected = 11.33980000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 8.'
	END

	BEGIN 
		SET @x = 12.51000000000000000000 
		SET @y = 50.00000000000000000000 
		SET @expected = 625.50000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 9.'
	END

	BEGIN 
		SET @x = 625.50000000000000000000 
		SET @y = 0.45359200000000000000 
		SET @expected = 283.72179600000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 10.'
	END

	BEGIN 
		SET @x = 0.06900000000000000000 
		SET @y = 1.00000000000000000000 
		SET @expected = 0.06900000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 11.'
	END

	BEGIN 
		SET @x = 0.06900000000000000000 
		SET @y = 200.00000000000000000000 
		SET @expected = 13.80000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 12.'
	END

	BEGIN 
		SET @x = 0.56698985088166900000 
		SET @y = 50.00000000000000000000 
		SET @expected = 28.34949254408345000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 13.'
	END

	BEGIN 
		SET @x = 1.00000000000000000000 
		SET @y = 0.00045359237000000000 
		SET @expected = 0.00045359237000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 14.'
	END

	BEGIN 
		SET @x = 250.75000000000000000000 
		SET @y = 7.00000000000000000000 
		SET @expected = 1755.25000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 15.'
	END

	BEGIN 
		SET @x = 350.75000000000000000000 
		SET @y = 35.82142857142857143200 
		SET @expected = 12564.36607142857127825000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 16.'
	END

	BEGIN 
		SET @x = 1000.00000000000000000000 
		SET @y = 3000.00000000000000000000 
		SET @expected = 3000000.00000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 17.'
	END

	BEGIN 
		SET @x = 1.00000000000000000000 
		SET @y = 0.01785714285714285714 
		SET @expected = 0.01785714285714285700 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 18.'
	END

	BEGIN 
		SET @x = 0.01785714285714285714 
		SET @y = 1.00000000000000000000 
		SET @expected = 0.01785714285714285700 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 19.'
	END

	BEGIN 
		SET @x = 0.01785714285714285714 
		SET @y = 0.01785714285714285714 
		SET @expected = 0.00031887755102040816 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 20.'
	END

	BEGIN 
		SET @x = 56.00000000000000000000 
		SET @y = 1.00000000000000000000 
		SET @expected = 56.00000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 21.'
	END

	BEGIN 
		SET @x = 1.00000000000000000000 
		SET @y = 1.00000000000000000000 
		SET @expected = 1.00000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 22.'
	END

	BEGIN 
		SET @x = 1.00000000000000000000 
		SET @y = 0.01785714285714285000 
		SET @expected = 0.01785714285714285000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 23.'
	END
	
	BEGIN 
		SET @x = 0.00000000000000000000 
		SET @y = 7.00000000000000000000 
		SET @expected = 0.00000000000000000000
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 24.'
	END

	BEGIN 
		SET @x = 1300.00000000000000000000 
		SET @y = 120.00000000000000000000 
		SET @expected = 156000.00000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 25.'
	END

	BEGIN 
		SET @x = 0.19958051803845009398 
		SET @y = 55.11560000000000000000 
		SET @expected = 10.99999999999999978040 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 26.'
	END

	BEGIN 
		SET @x = 0.19958051803845010000 
		SET @y = 55.11560000000000000000 
		SET @expected = 11.00000000000000033156 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 27.'
	END

	BEGIN 
		SET @x = 11.00000000000000000000 
		SET @y = 55.11560000000000000000 
		SET @expected = 606.27160000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 28.'
	END

	BEGIN 
		SET @x = 16534.68000000000000000000 
		SET @y = 300.00000000000000000000 
		SET @expected = 4960404.00000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 29.'
	END

	BEGIN 
		SET @x = 55.11560000000000000000 
		SET @y = 42.83165100000000000000 
		SET @expected = 2360.69214385560000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 30.'
	END

	BEGIN 
		SET @x = 42.83165100000000000000 
		SET @y = 55.11560000000000000000 
		SET @expected = 2360.69214385560000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 31.'
	END

	BEGIN 
		SET @x = NULL 
		SET @y = 55.11560000000000000000 
		SET @expected = NULL 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 32.'
	END

	BEGIN 
		SET @x = 42.83165100000000000000 
		SET @y = NULL 
		SET @expected = NULL 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 33.'
	END

	BEGIN 
		SET @x = -1.00000000000000000000 
		SET @y = 55.11560000000000000000 
		SET @expected = -55.11560000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 34.'
	END

	BEGIN 
		SET @x = -1.00000000000000000000 
		SET @y = 9.99999999990000000000 
		SET @expected = -9.99999999990000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 35.'
	END

	BEGIN 
		SET @x = -500.00000000000000000000 
		SET @y = 0.02000000000000000000 
		SET @expected = -10.00000000000000000000 
		SELECT @result = dbo.fnMultiply(@x, @y)

		-- Assert the result is true
		EXEC tSQLt.AssertEquals @expected, @result, 'Multiply failed on scenario 36.'
	END
END