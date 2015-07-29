CREATE PROCEDURE [dbo].[uspAPCreateBillDetailTaxes]
	@intBillDetailId INT
AS
BEGIN

	DECLARE @purchaseTaxMasterId INT;
	DECLARE @billShipFromLocation INT;
	DECLARE @country NVARCHAR(100) = NULL;
	DECLARE @state NVARCHAR(100) = NULL;
	DECLARE @county NVARCHAR(100) = NULL;
	DECLARE @city NVARCHAR(100) = NULL;
	DECLARE @transactionDate DATETIME;
	DECLARE @taxes TABLE(
		[intTaxGroupMasterId] INT NOT NULL, 
		[intTaxGroupId] INT NOT NULL, 
		[intTaxCodeId] INT NOT NULL, 
		[intTaxClassId] INT NOT NULL, 
		[strTaxableByOtherTaxes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[strCalculationMethod] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
		[strTaxCode] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
		[dblRate] NUMERIC(18, 6) NULL, 
		[intAccountId] INT NULL, 
		[dblTax] NUMERIC(18, 6) NULL, 
		[dblAdjustedTax] NUMERIC(18, 6) NULL, 
		[ysnTaxAdjusted] BIT NULL DEFAULT ((0)), 
		[ysnSeparateOnBill] BIT NULL DEFAULT ((0)), 
		[ysnCheckoffTax] BIT NULL DEFAULT ((0))
	)

	SELECT
		@purchaseTaxMasterId = C.intPurchaseTaxGroupId
		,@billShipFromLocation = A.intShipFromId
		,@transactionDate = A.dtmDate
	FROM tblAPBill A
		INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
		INNER JOIN tblICItem C ON B.intItemId = C.intItemId
	WHERE B.intBillDetailId = @intBillDetailId

	SELECT
		@country = A.strCountry
		,@state = A.strState
		,@county = NULL
		,@city = A.strCity
	FROM tblEntityLocation A
	WHERE A.intEntityLocationId = @billShipFromLocation

	IF(@purchaseTaxMasterId > 0)
	BEGIN

		INSERT INTO @taxes
		SELECT * FROM dbo.fnAPCreateTaxes(@purchaseTaxMasterId, @country, @state, @county, @city, @transactionDate);

		IF(@@ROWCOUNT > 0)
		BEGIN
			INSERT INTO tblAPBillDetailTax(
				[intBillDetailId]		, 
				[intTaxGroupMasterId]	, 
				[intTaxGroupId]			, 
				[intTaxCodeId]			, 
				[intTaxClassId]			, 
				[strTaxableByOtherTaxes], 
				[strCalculationMethod]	, 
				[dblRate]				, 
				[intAccountId]			, 
				[dblTax]				, 
				[dblAdjustedTax]		, 
				[ysnTaxAdjusted]		, 
				[ysnSeparateOnBill]		, 
				[ysnCheckOffTax]
			)
			SELECT
				[intBillDetailId]		=	@intBillDetailId, 
				[intTaxGroupMasterId]	=	A.intTaxGroupMasterId, 
				[intTaxGroupId]			=	A.intTaxGroupId, 
				[intTaxCodeId]			=	A.intTaxCodeId, 
				[intTaxClassId]			=	A.intTaxClassId, 
				[strTaxableByOtherTaxes]=	A.strTaxableByOtherTaxes, 
				[strCalculationMethod]	=	A.strCalculationMethod, 
				[dblRate]				=	A.dblRate, 
				[intAccountId]			=	A.intAccountId, 
				[dblTax]				=	A.dblTax, 
				[dblAdjustedTax]		=	A.dblAdjustedTax, 
				[ysnTaxAdjusted]		=	A.ysnTaxAdjusted, 
				[ysnSeparateOnBill]		=	A.ysnSeparateOnBill, 
				[ysnCheckOffTax]		=	A.ysnCheckoffTax
			FROM @taxes A

		END

	END

END